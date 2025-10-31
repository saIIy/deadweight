-- # game.lua
-- Main gameplay logic: room loading, transitions, player movement, etc.

local module = {}

-- seed RNG
math.randomseed(os.time())

-- which room to start in (for testing)
local roomToLoad = "room1"

-- room and transition state
local currentRoom = nil
local currentMap = ""
local nextRoom = nil
local nextRoomSpawn = nil
local transitionAlpha = 0
local transitioning = false
local transitionSpeed = 5
local transitionTime = 0

-- save point setup
savePoint = {
    pos = nil,
    animation = anim8.newAnimation(anim8.newGrid(16, 16, 32, 16)('1-2',1), 0.2),
    sprite = love.graphics.newImage("assets/images/savepoint.png", {linear = false, mipmaps = false, dpiscale = 1}),
    interacting = false
}

local saveMenu = require("assets.classes.save_menu")
local save = require("lib.save")

maps = {}

local walls = {}
local doors = {}
local particles = {}

-- clears old room data before loading a new one
function unloadRoom()
    for _,v in pairs(walls) do v:destroy() end
    for _,v in pairs(particles) do v.particles:stop() end

    walls, doors, particles = {}, {}, {}
    savePoint.pos = nil

    if currentRoom and currentRoom.onExit then
        currentRoom:onExit()
    end
end

-- loads a new room and its objects
function loadRoom(name)
    local room = require("assets.rooms." .. name)
    currentMap = name

    if #maps > 4 then
        table.remove(maps, 1)
    end

    if not maps[name] then
        maps[name] = sti("assets/rooms/"..name.."_map.lua")
    end

    unloadRoom()

    if room and room.load then
        room:load()
    end

    -- build walls from map objects
    for _,v in pairs(maps[name].layers.Walls.objects) do
        local wall = world:newBSGRectangleCollider(v.x, v.y, v.width, v.height, 0)
        wall:setType("static")
        table.insert(walls, wall)
    end

    print(room.music)

    -- handle music
    if room.music and not room.music:isPlaying() then
        print("dfdnsfds")
        playSound(room.music)
    end

    -- setup doors
    for _,v in pairs(maps[name].layers.Doors.objects) do
        local door = {}
        door.target_room = v.properties.target_room
        door.target_pos = { x = v.properties.target_x - 8, y = v.properties.target_y - 8 }
        door.size = { width = v.width, height = v.height }
        door.position = { x = v.x, y = v.y }
        table.insert(doors, door)
    end

    -- place player spawn + other objects
    for _,v in pairs(maps[name].layers["Other"].objects) do
        if v.type == "spawn" then
            spawnPoint = v
        elseif v.type == "save" then
            savePoint.pos = {x = v.x + 8, y = v.y + 8}
            savePoint.animation:resume()

            local spcol = world:newBSGRectangleCollider(v.x, v.y, 16, 16, 2)
            spcol:setType("static")
            table.insert(walls, spcol)
        elseif v.type == "particle_emitter" then
            -- setup particles from Tiled properties
            local filepath = "assets/images/" .. (v.properties.image or "assets/images/placeholder.png")
            local img = love.graphics.newImage(filepath)
            local particleSystem = love.graphics.newParticleSystem(img)
            local colors = {
                [1] = parseTiledColor(v.properties.color0),
                [2] = parseTiledColor(v.properties.color1),
            }

            particleSystem:setColors(
                colors[1][1], colors[1][2], colors[1][3], colors[1][4],
                colors[2][1], colors[2][2], colors[2][3], colors[2][4]
            )

            particleSystem:setSpeed(v.properties.speed0, v.properties.speed1)
            particleSystem:setEmissionArea("uniform", v.width / 2, v.height / 2, 0)
            particleSystem:setPosition(v.x + v.width / 2 + 8, v.y + v.height / 2 + 8)
            particleSystem:setParticleLifetime(v.properties.lt0, (v.properties.lt1 or v.properties.lt0))
            particleSystem:setSpread(math.rad(v.properties.spread))
            particleSystem:setSizes(v.properties.scale or 1)

            if v.properties.rate_randomness and v.properties.rate_randomness ~= 0 then
                local rand = math.random(-v.properties.rate_randomness, v.properties.rate_randomness)
                particleSystem:setEmissionRate(v.properties.rate + rand)
            else
                particleSystem:setEmissionRate(v.properties.rate)
            end

            particleSystem:start()
            table.insert(particles, {particles = particleSystem, x = v.x, y = v.y, rand = v.properties.rate_randomness, rate = v.properties.rate})
        end
    end

    -- move player to correct spawn
    if nextRoomSpawn then
        spawnPoint = nextRoomSpawn
    end

    player.collider:setPosition(spawnPoint.x + 8, spawnPoint.y + 8)
    currentRoom = room
end

local transitionPhase = "out"

-- handles switching between rooms with fade effect
function switchRoom(name, pos, face)
    if not transitioning then
        transitioning = true
        transitionPhase = "out"
        nextRoom = name

        if pos then nextRoomSpawn = pos end
        if face then player.face = face end
    end
end

-- disable texture filtering (pixel art)
love.graphics.setDefaultFilter("nearest", "nearest")

-- general game state
game = {
    menu = true,
    paused = false,
    running = false,
    ended = false,
}

-- player setup
player = {
    position = { x = 0, y = 0 },
    speed = 100,
    sprite = love.graphics.newImage("/assets/images/player/player_sprite_sheet.png"),
    grid = anim8.newGrid(20, 38, 80, 152),
    face = "down",
    control = true,
    animspeed = 1,
    moving = false,
    collider = nil,
}

-- animation sets
player.animations = {
    down = anim8.newAnimation(player.grid('1-4',1), 0.2),
    right = anim8.newAnimation(player.grid('1-4',2), 0.2),
    left = anim8.newAnimation(player.grid('1-4',3), 0.2),
    up = anim8.newAnimation(player.grid('1-4',4), 0.2),
}

local escKeyHeld = false
local quitTextAlpha = 0

-- load world, camera, and first room
function module.load()
    local saveData

    if selected_save_slot ~= 0 and selected_save_slot < 4 and save.exists("save_slot_"..selected_save_slot) then
        saveData = save.get("save_slot_"..selected_save_slot)
        roomToLoad = saveData.room
    end

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

    loadRoom(roomToLoad)
end

local keys = { up=false, down=false, left=false, right=false }
local fps = 0

-- main game loop
function module.update(dt)
    -- update particles
    for _,p in ipairs(particles) do
        if p.rand and p.rand ~= 0 then
            local rand = math.random(-p.rand, p.rand)
            p.particles:setEmissionRate(p.rate + rand)
        end
        p.particles:update(dt)
    end

    -- update save point
    if savePoint.pos then
        savePoint.animation:update(dt)
    end

    -- fade in "quitting" text
    if escKeyHeld then
        quitTextAlpha = math.min(quitTextAlpha + 0.007, 1)
    else
        quitTextAlpha = math.max(quitTextAlpha - 0.003, 0)
    end

    -- handle door collisions
    for _,v in pairs(doors) do
        local collider = world:queryRectangleArea(v.position.x, v.position.y, v.size.width, v.size.height, {'Player'})
        if table.find(collider, player.collider) and not transitioning then
            switchRoom(v.target_room, v.target_pos, v.target_face)
        end
    end

    -- read movement keys
    keys.up = love.keyboard.isDown("up") and not savePoint.interacting
    keys.down = love.keyboard.isDown("down") and not savePoint.interacting
    keys.left = love.keyboard.isDown("left") and not savePoint.interacting
    keys.right = love.keyboard.isDown("right") and not savePoint.interacting

    local vx, vy = 0, 0

    -- movement
    if player.control then
        if keys.up and not keys.down then vy = -player.speed end
        if keys.down and not keys.up then vy = player.speed end
        if keys.left and not keys.right then vx = -player.speed end
        if keys.right and not keys.left then vx = player.speed end
    end

    player.collider:setLinearVelocity(vx, vy)
    world:update(dt)

    -- handle room transition fade
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

    -- sprint toggle
    if love.keyboard.isDown("x") or love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        player.animspeed = 1.4
        player.speed = 125
    else
        player.animspeed = 0.8
        player.speed = 70
    end

    -- animation + facing direction logic
    local vx_, vy_ = player.collider:getLinearVelocity()
    player.moving = math.abs(vx_) > 0.1 or math.abs(vy_) > 0.1

    local desiredFace = nil
    if keys.left then desiredFace = "left"
    elseif keys.right then desiredFace = "right"
    elseif keys.up then desiredFace = "up"
    elseif keys.down then desiredFace = "down" end

    if desiredFace and desiredFace ~= player.face then
        player.face = desiredFace
    end

    if player.moving then
        player.animations[player.face]:resume()
        player.animations[player.face]:update(dt*player.animspeed)
    else
        player.animations[player.face]:gotoFrame(2)
        player.animations[player.face]:pause()
    end

    -- update player + camera position
    player.position.x = player.collider:getX()
    player.position.y = player.collider:getY() - 13

    cam:lookAt(player.position.x, player.position.y)
    cam:zoomTo(2)

    -- clamp camera to map bounds
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local mapw = maps[currentMap].width * maps[currentMap].tilewidth
    local maph = maps[currentMap].height * maps[currentMap].tileheight

    cam.x = math.max(w/4, math.min(cam.x, mapw - w/4))
    cam.y = math.max(h/4, math.min(cam.y, maph - h/4))

    cam.x, cam.y = math.floor(cam.x), math.floor(cam.y)
    player.position.x, player.position.y = math.floor(player.position.x), math.floor(player.position.y)
end

-- handle key press events
module.keypressed = function(key)
    if key == "escape" then escKeyHeld = true end

    if saveMenu then saveMenu.keypressed(key) end

    -- save point interaction
    if savePoint.pos then
        local collider = world:queryRectangleArea(savePoint.pos.x - 16, savePoint.pos.y - 16, 32, 32, {'Player'})
        if table.find(collider, player.collider) and (love.keyboard.isDown("z") or love.keyboard.isDown("return")) and not savePoint.interacting then
            savePoint.interacting = true
            -- open save menu
            saveMenu.show(function(slot)
                savePoint.interacting = false
                print("Saved in slot "..slot)
            end,
            {
                player = {},
                room = currentMap
            })
        end
    end

    if not table.find({"up", "down", "left", "right"}, key) then return end

    -- immediately face input direction
    if key == "up" then player.face = "up"
    elseif key == "down" then player.face = "down"
    elseif key == "left" then player.face = "left"
    elseif key == "right" then player.face = "right" end

    player.animations[player.face]:gotoFrame(1)
end

-- handle key release
module.keyreleased = function(key)
    if key == "escape" then escKeyHeld = false end
end

-- draw everything
function module.draw()
    love.graphics.setColor(1,1,1)

    if currentRoom then
        cam:attach()
            -- draw map layers except collisions and triggers
            for _,v in pairs(maps[currentMap].layers) do
                if v.visible and not table.find({"Walls", "Other", "Doors"}, v.name) then
                    maps[currentMap]:drawLayer(v)
                end
            end

            -- draw particles and objects
            for _,p in pairs(particles) do
                love.graphics.draw(p.particles)
            end
            
            if savePoint.pos then
                savePoint.animation:draw(savePoint.sprite, savePoint.pos.x, savePoint.pos.y, 0, 1, 1, 8, 8)
            end

            player.animations[player.face]:draw(player.sprite, player.position.x, player.position.y, 0, 1, 1, 10, 19)
        cam:detach()

        if currentRoom.draw then currentRoom:draw() end
    end

    if saveMenu then saveMenu.draw() end

    -- fade overlay for transitions
    if transitioning then
        love.graphics.setColor(0, 0, 0, transitionAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- quitting text fade
    love.graphics.setColor(1, 1-quitTextAlpha, 1-quitTextAlpha, quitTextAlpha)
    love.graphics.print("Quitting...", 10, 10)

    if quitTextAlpha >= 1 then
        love.event.quit()
    end
end

return module
