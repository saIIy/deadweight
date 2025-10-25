function love.load()
     love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setTitle("deadweight")
    love.window.setIcon(love.image.newImageData("/assets/images/dw_logo_sun.png"))
    local font = love.graphics.newFont("/assets/fonts/dotumche-pixel.ttf", 14)

    love.graphics.setFont(font)
end

function love.update(dt)

end

function love.draw()
    love.graphics.print("mrrp meow", 400, 300)
end