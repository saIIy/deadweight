function love.load()
    sti = require('libraries/sti')
    anim8 = require('libraries/anim8')

    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Set the window title
    love.window.setTitle("deadweight")
    love.window.setIcon(love.image.newImageData("/assets/images/dw_logo_sun.png"))
    local font = love.graphics.newFont("/assets/fonts/dotumche-pixel.ttf", 14)

    love.graphics.setFont(font)

    player = {}
    player.x = 400
    player.y = 200
    player.speed = 200
    player.spriteSheet = love.graphics.newImage("/assets/images/player/player_sprite_sheet.png")
    player.grid = anim8.newGrid(20, 38, player.spriteSheet:getWidth(), player.spriteSheet:getHeight(), 0, 0)
    
    player.animations = {
        ["down"] = anim8.newAnimation(player.grid('1-4', 1), 0.2),
        ["right"] = anim8.newAnimation(player.grid('1-4', 2), 0.2),
        ["left"] = anim8.newAnimation(player.grid('1-4', 3), 0.2),
        ["up"] = anim8.newAnimation(player.grid('1-4', 4), 0.2)
    }

    player.anim = player.animations["down"]

    Background = love.graphics.newImage("/assets/images/dw_logo_sun.png")
end

function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        player.anim = player.animations["right"]
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
        player.anim = player.animations["left"]
        isMoving = true
    end

    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
        player.anim = player.animations["up"]
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
        player.anim = player.animations["down"]
        isMoving = true
    end

    if not isMoving then
        player.anim:gotoFrame(2)
    end
    
    player.anim:update(dt)
end

function love.draw()
    love.graphics.draw(Background, 0, 0)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 3, 3, 10, 19)
    love.graphics.print("Use arrow keys to move the player.", 12, 12)
end