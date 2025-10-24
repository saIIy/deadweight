function love.load()
    sti = require('libraries/sti')

    -- Set the window title
    love.window.setTitle("deadweight")

    -- Load an image
    image = love.graphics.newImage("/assets/images/dw_logo_sun.png")

    -- Initialize position
    x = 100
    y = 100
end