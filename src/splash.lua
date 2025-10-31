-- # splash.lua
-- this handles the startup splash screens before the main menu loads

local module = {}

-- load the dissolve effect and splash/warning images
local dissolve = require("assets.classes.dissolve")
local splash = dissolve.new(
    love.graphics.newImage("assets/images/splash/scnsplashscreen2.png", { dpiscale = 1.8 }),
    0, 0, 24, 4
)
local tw = dissolve.new(
    love.graphics.newImage("assets/images/splash/warnin.png", { dpiscale = 1.8 }),
    0, 0, 24, -1
)

local twEnabled = false  -- whether the warning screen is active
local timer = 0          -- tracks how long since user pressed a key
local pressed = false    -- whether the player has pressed a key

-- updates splash animations and handles transitions
function module.update(dt)
    splash:update(dt)
    tw:update(dt)

    -- when the first splash finishes, enable the warning screen
    if splash.timer > 5 and not twEnabled then
        twEnabled = true
    end

    -- after a short delay, move to the main menu
    if twEnabled and timer > 2 then
        loadFile("menu")
    end

    if pressed then
        timer = timer + dt
    end
end

-- draw both splash layers
function module.draw()
    tw:draw()
    splash:draw()
end

-- start transition when player presses a key
function module.keypressed()
    if twEnabled then
        tw:execute()
        pressed = true
    end
end

return module
