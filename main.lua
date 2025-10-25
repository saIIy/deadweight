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

function love.update(dt)
    local keys = {
        up = love.keyboard.isDown("up"),
        down = love.keyboard.isDown("down"),
        left = love.keyboard.isDown("left"),
        right = love.keyboard.isDown("right"),
    }

    fps = love.timer.getFPS()

    player.moving = false

    if keys.up then
        player.y = player.y - player.speed * dt
        moving = true
    end

    if keys.down then
        player.y = player.y + player.speed * dt
        moving = true
    end

    if keys.left then
        player.x = player.x - player.speed * dt
        moving = true
    end

    if keys.right then
        player.x = player.x + player.speed * dt
        moving = true
    end

    if (keys.up and keys.down) or (keys.left and keys.right) then
        moving = false
    end

    player.animations[player.face]:update(dt)
end

love.keypressed = function(key)
    if table.find({"up", "down", "left", "right"}, key) == nil then
        return
    end

    if key == "up" then
        player.face = "up"
    elseif key == "down" then
        player.face = "down"
    elseif key == "left" then
        player.face = "left"
    elseif key == "right" then
        player.face = "right"
    end

    player.animations[player.face]:gotoFrame(1)
    player.animations[player.face]:resume()
end

love.keyreleased = function(key)
    if table.find({"up", "down", "left", "right"}, key) and player.moving == false then
        player.animations[player.face]:gotoFrame(2)
        player.animations[player.face]:pause()
    end
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