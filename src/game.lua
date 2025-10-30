-- # game.lua

local module = {}

-- random seed
math.randomseed(os.time())

-- room management
local currentRoom = nil
local nextRoom = nil
local nextRoomSpawn = nil
local transitionAlpha = 0
local transitioning = false
local transitionSpeed = 5
local transitionTime = 0

maps = {}

local walls = {}
local doors = {}

function unloadRoom()
    -- clear existing walls
    for _,v in pairs(walls) do
        v:destroy()
    end

    walls, doors = {}, {}

    if currentRoom and currentRoom.onExit then
        currentRoom:onExit()
    end
end

function loadRoom(name)
    local room = require("assets.rooms." .. name)

    if #maps > 4 then
        table.remove(maps, 1)
    end

    if not maps[name] then
        maps[room.map] = sti("assets/rooms/"..name.."_map.lua")
    end

    print(name)

    -- unload current room
    unloadRoom()

    -- setup new walls
    print(room.map)
    for _,v in pairs(maps[room.map].layers.Walls.objects) do
        local wall = world:newBSGRectangleCollider(v.x, v.y, v.width, v.height, 0)
        wall:setType("static")
        table.insert(walls, wall)
    end

    -- setup new doors
    for _,v in pairs(maps[room.map].layers.Doors.objects) do
        local door = {}
        door.target_room = v.properties.target_room
        door.target_pos = { x = v.properties.target_x, y = v.properties.target_y }
        door.size = { width = v.width, height = v.height }
        door.position = { x = v.x, y = v.y }
        table.insert(doors, door)
    end

    -- position player at spawn point
    for i,v in pairs(maps[room.map].layers["Other"].objects) do
        if v.name == "spawn" then
            spawnPoint = v
        end
    end

    if nextRoomSpawn then
        spawnPoint = nextRoomSpawn
    end

    player.collider:setPosition(spawnPoint.x, spawnPoint.y)
    print("Player spawned at: ", spawnPoint.x, spawnPoint.y)

    room:load()
    currentRoom = room
end

local transitionPhase = "out" -- or "in"

---@param pos {x:number, y:number}|nil
---@param face string|nil
function switchRoom(name, pos, face)
    if not transitioning then
        transitioning = true
        transitionPhase = "out"
        nextRoom = name

        if pos and pos.x and pos.y then
            nextRoomSpawn = pos
        end

        if face then
            player.face = face
        end
    end
end

-- NO BLURRY SHIT
love.graphics.setDefaultFilter("nearest", "nearest")

game = {
    menu = true,
    paused = false,
    running = false,
    ended = false,
}

player = {
    position = { x = 0, y = 0 },
    speed = 100,
    sprite = love.graphics.newImage("/assets/images/player/player_sprite_sheet.png"),
    grid = anim8.newGrid(20, 38, 80, 152),
    face = "down",
    control = true,
    animspeed = 1,
    animations = {
        down = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',1), 0.2),
        right = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',2), 0.2),
        left = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',3), 0.2),
        up = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',4), 0.2),
    },
    moving = false,
    collider = nil,
}

local sounds = {
    sfx = {
        test = love.audio.newSource("/assets/sounds/sfx/bass_drop.mp3", "static"),
    },

    music = {
        test = love.audio.newSource("assets/sounds/music/in_the_snow.ogg", "stream"),
    }
}

local escKeyHeld = false
local quitTextAlpha = 0

function module.load()
    world = wf.newWorld(0, 0, false)

    world:addCollisionClass("Door")
    world:addCollisionClass("Player")

    font = love.graphics.newFont("/assets/fonts/flexi-ibm-vga-true.regular.ttf", 32)
    love.graphics.setFont(font)

    player.collider = world:newBSGRectangleCollider(player.position.x, player.position.y, 10, 10, 0)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player")

    cam = libcamera.new()

    for _,v in pairs(player.animations) do
        v:gotoFrame(2)
        v:pause()
    end

    loadRoom("room1")

    sounds.music.test:play()
    sounds.music.test:setLooping(true)
end

local keys = {
    up = false,
    down = false,
    left = false,
    right = false,
}

local fps = 0

function module.update(dt)
    fps = love.timer.getFPS()

    if escKeyHeld then
        quitTextAlpha = math.min(quitTextAlpha + 0.007, 1)
    else
        quitTextAlpha = math.max(quitTextAlpha - 0.003, 0) 
    end

    for _,v in pairs(doors) do
        local collider = world:queryRectangleArea(v.position.x, v.position.y, v.size.width, v.size.height, {'Player'})
        if table.find(collider, player.collider) and not transitioning then
            printTable(v)
            switchRoom(v.target_room, v.target_pos, v.target_face)
        end
    end

    keys = {
        up = love.keyboard.isDown("up"),
        down = love.keyboard.isDown("down"),
        left = love.keyboard.isDown("left"),
        right = love.keyboard.isDown("right"),
    }
    
    local vx = 0
    local vy = 0

    -- apply movement
    if player.control then
        if keys.up and not keys.down then
            vy = -player.speed
        end

        if keys.down and not keys.up then
            vy = player.speed
        end

        if keys.left and not keys.right then
            vx = -player.speed
        end

        if keys.right and not keys.left then
            vx = player.speed
        end
    end

    player.collider:setLinearVelocity(vx, vy)

    world:update(dt)

     if transitioning then
        vx, vy = 0, 0
        player.control = false

        if transitionPhase == "out" then
            transitionAlpha = transitionAlpha + dt * transitionSpeed
            if transitionAlpha >= 1 and transitionTime >= 1.75 then
                loadRoom(nextRoom)
                nextRoom = nil
                transitionPhase = "in"
            end
        elseif transitionPhase == "in" then
            transitionAlpha = transitionAlpha - dt * transitionSpeed
            if transitionAlpha <= 0 then
                transitionAlpha = 0
                transitioning = false
                transitionTime = 0
            end
        end

        transitionTime = transitionTime + dt * transitionSpeed
    else
        player.control = true
        if currentRoom and currentRoom.update then
            currentRoom:update(dt)
        end
    end

    if love.keyboard.isDown("x") then
        player.animspeed = 1.4
        player.speed = 125
    else
        player.animspeed = 0.8
        player.speed = 70
    end

    -- update moving state
    local vx_, vy_ = player.collider:getLinearVelocity()
    local horiz = math.abs(vx_) > 0.1
    local vert  = math.abs(vy_) > 0.1

    local horiz_input = (keys.left and not keys.right) or (keys.right and not keys.left)
    local vert_input  = (keys.up and not keys.down) or (keys.down and not keys.up)

    player.moving = (horiz or vert)

    -- decide which face should be active when moving
    local desiredFace = nil
    if horiz_input then
        if keys.left then desiredFace = "left"
        elseif keys.right then desiredFace = "right" end
    elseif vert_input then
        if keys.up then desiredFace = "up"
        elseif keys.down then desiredFace = "down" end
    end

    if desiredFace and desiredFace ~= player.face then
        player.face = desiredFace
    end

    if player.moving then
        -- ensure the current face animation is playing and update it
        player.animations[player.face]:resume()
        player.animations[player.face]:update(dt*player.animspeed)
    else
        -- no effective movement: show standing frame and pause
        player.animations[player.face]:gotoFrame(2)
        player.animations[player.face]:pause()
    end
    
    player.position.x = player.collider:getX()
    player.position.y = player.collider:getY() - 13

    cam:lookAt(player.position.x, player.position.y)
    cam:zoomTo(2)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/4 then
        cam.x = w/4
    end

    if cam.y < h/4 then
        cam.y = h/4
    end

    if not currentRoom then
        return
    end

    local mapw = maps[currentRoom.map].width * maps[currentRoom.map].tilewidth
    local maph = maps[currentRoom.map].height * maps[currentRoom.map].tileheight

    if cam.x > mapw - w/4 then
        cam.x = mapw - w/4
    end

    if cam.y > maph - h/4  then
        cam.y = maph - h/4
    end

    cam.x = math.floor(cam.x)
    cam.y = math.floor(cam.y)
    player.position.x = math.floor(player.position.x)
    player.position.y = math.floor(player.position.y)

    print(cam.x, cam.y)
end

module.keypressed = function(key)
    if key == "escape" then
        escKeyHeld = true
    end

    if table.find({"up", "down", "left", "right"}, key) == nil then
        return
    end

    -- only set facing immediately; actual play/pause handled in love.update
    if key == "up" and not keys.down then
        player.face = "up"
    elseif key == "down" and not keys.up then
        player.face = "down"
    elseif key == "left" and not keys.right then
        player.face = "left"
    elseif key == "right" and not keys.left then
        player.face = "right"
    end

    player.animations[player.face]:gotoFrame(1)
end

module.keyreleased = function(key)
    if key == "escape" then
        escKeyHeld = false
    end

    if table.find({"up", "down", "left", "right"}, key) == nil then
        return
    end
end

function module.draw()
    local text = fps .. " FPS"

    love.graphics.setColor(1,1,1)

    if currentRoom then
        cam:attach()
            for i,v in pairs(maps[currentRoom.map].layers) do
                if v.visible and not table.find({"Walls", "Other", "Doors"}, v.name) then
                    maps[currentRoom.map]:drawLayer(v)
                end
            end

            player.animations[player.face]:draw(player.sprite, player.position.x, player.position.y, 0, 1, 1, 10, 19)
        cam:detach()

        if currentRoom.draw then
            currentRoom:draw()
        end
    end

    love.graphics.setColor(0.6, 0, 0)
    love.graphics.print(text, love.graphics:getWidth() - 10, 10, 0, 1, 1, font:getWidth(text) - 2, -2)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print(text, love.graphics:getWidth() - 10, 10, 0, 1, 1, font:getWidth(text))

    if transitioning then
        love.graphics.setColor(0, 0, 0, transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(1, 1-quitTextAlpha, 1-quitTextAlpha, quitTextAlpha)
    love.graphics.print("Quitting...", 10, 10)

    if quitTextAlpha >= 1 then
        love.event.quit()
    end
end

return module