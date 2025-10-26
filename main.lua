function table.find(table, element)
    for index, value in pairs(table) do
        if value == element then
            return index
        end
    end
    return nil
end

anim8 = require("lib/anim8")
word_shift = require("lib/word_shift")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    font = love.graphics.newFont("/assets/fonts/flexi-ibm-vga-true.regular.ttf", 32)
    love.graphics.setFont(font)

    player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        speed = 200,
        sprite = love.graphics.newImage("/assets/images/player/player_sprite_sheet.png"),
        grid = anim8.newGrid(20, 38, 80, 152),
        face = "down",
        animations = {
            down = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',1), 0.2),
            right = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',2), 0.2),
            left = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',3), 0.2),
            up = anim8.newAnimation(anim8.newGrid(20, 38, 80, 152)('1-4',4), 0.2),
        },
        moving = false,
    }

    for _,v in pairs(player.animations) do
        v:gotoFrame(2)
        v:pause()
    end
end

local keys = {
    up = false,
    down = false,
    left = false,
    right = false,
}

local fps = 0

function love.update(dt)
    keys = {
        up = love.keyboard.isDown("up"),
        down = love.keyboard.isDown("down"),
        left = love.keyboard.isDown("left"),
        right = love.keyboard.isDown("right"),
    }

    fps = love.timer.getFPS()

    -- determine exclusive horizontal / vertical movement (cancel opposing keys)
    local horiz = (keys.left ~= keys.right) and (keys.left or keys.right)
    local vert  = (keys.up ~= keys.down) and (keys.up or keys.down)

    -- apply movement
    if keys.up and not keys.down then
        player.y = player.y - player.speed * dt
    end

    if keys.down and not keys.up then
        player.y = player.y + player.speed * dt
    end

    if keys.left and not keys.right then
        player.x = player.x - player.speed * dt
    end

    if keys.right and not keys.left then
        player.x = player.x + player.speed * dt
    end

    -- update moving state
    player.moving = horiz or vert

    -- decide which face should be active when moving
    local desiredFace = nil
    if horiz then
        if keys.right then desiredFace = "right"
        elseif keys.left then desiredFace = "left" end
    elseif vert then
        if keys.up then desiredFace = "up"
        elseif keys.down then desiredFace = "down" end
    end

    if player.moving then
        -- switch face if needed and restart its animation
        if desiredFace and desiredFace ~= player.face then
            player.face = desiredFace
        end
        -- ensure the current face animation is playing and update it
        player.animations[player.face]:resume()
        player.animations[player.face]:update(dt)
    else
        -- no effective movement: show standing frame and pause
        player.animations[player.face]:gotoFrame(2)
        player.animations[player.face]:pause()
    end
end

love.keypressed = function(key)
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

love.keyreleased = function(key)
    if table.find({"up", "down", "left", "right"}, key) == nil then
        return
    end
    -- no direct animation changes here; love.update will detect remaining keys and act
end

function love.draw()
    local text = fps .. " FPS"

    love.graphics.setColor(0.6, 0, 0)
    love.graphics.print(text, love.graphics:getWidth() - 10, 10, 0, 1, 1, font:getWidth(text) - 2, -2)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print(text, love.graphics:getWidth() - 10, 10, 0, 1, 1, font:getWidth(text))

    love.graphics.print(word_shift.wordCycle({"test 1", "test 2", "mrrp meow"}, true), 10, 10)

    love.graphics.setColor(1,1,1)

    player.animations[player.face]:draw(player.sprite, player.x, player.y, 0, 2, 2)
end