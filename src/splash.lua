local module = {}

local dissolve = require("assets.classes.dissolve")
local splash = dissolve.new(love.graphics.newImage("assets/images/splash/scnsplashscreen2.png", {dpiscale=1.8}), 0, 0, 24, 4)
local tw = dissolve.new(love.graphics.newImage("assets/images/splash/warnin.png", {dpiscale=1.8}), 0, 0, 24, -1)
local twEnabled = false
local timer = 0
local pressed = false

function module.load()

end

function module.update(dt)
    splash:update(dt)
    tw:update(dt)

    if splash.timer > 5 and not twEnabled then
        twEnabled = true
    end

    if twEnabled and timer > 2 then
        loadFile("menu")
    end

    if pressed then
        timer = timer + dt
    end
end

function module.draw()
    tw:draw()
    splash:draw()
end

function module.keypressed()
    if twEnabled then
        tw:execute()
        pressed = true
    end
end

return module