function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    font = love.graphics.newFont("/assets/fonts/dotumche-pixel.ttf", 26)
    love.graphics.setFont(font)
end

function love.update(dt)
    fps = love.timer.getFPS()
end

function love.draw()
    local text = fps .. " FPS"

    love.graphics.setColor(0.6, 0, 0)
    love.graphics.print(text, love.graphics:getWidth() - 10, 10, 0, 1, 1, font:getWidth(text) - 2, -2)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print(text, love.graphics:getWidth() - 10, 10, 0, 1, 1, font:getWidth(text))
end