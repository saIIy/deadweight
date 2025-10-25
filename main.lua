function love.load()
    anim8 = require("lib/anim8")

    love.graphics.setDefaultFilter("nearest", "nearest")

    font = love.graphics.newFont("/assets/fonts/dotumche-pixel.ttf", 26)
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
        xspd = 0,
        yspd = 0,
    }
end

function love.update(dt)
    fps = love.timer.getFPS()
    player.animations[player.face]:update(dt)
    player.x = player.x + player.xspd * dt
    player.y = player.y + player.yspd * dt

    if love.keyboard.isDown("up") then player.yspd = -player.speed end
    if love.keyboard.isDown("down") then player.yspd = player.speed end
    if love.keyboard.isDown("left") then player.xspd = -player.speed end
    if love.keyboard.isDown("right") then player.xspd = player.speed end

    if not love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
        player.yspd = 0
    end
    if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        player.xspd = 0
    end
end

love.keypressed = function(key)
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
    if key == "up" or key == "down" or key == "left" or key == "right" then
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

    love.graphics.setColor(1,1,1)
    player.animations[player.face]:draw(player.sprite, player.x, player.y, 0, 2, 2)
end