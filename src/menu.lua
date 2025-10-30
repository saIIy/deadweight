local module = {}

local menu = {}
menu.options = { "Start Game", "Options", "Exit" }
menu.selected = 1
menu.active = true

function module.load()
    love.graphics.setFont(love.graphics.newFont("assets/fonts/flexi-ibm-vga-true.regular.ttf", 32))
    sounds.music.menu:play()
end

function module.update(dt)
    if not menu.active then return end

    if love.keyboard.isDown("up") then
        if not menu.upPressed then
            menu.selected = menu.selected - 1
            if menu.selected < 1 then menu.selected = #menu.options end
            menu.upPressed = true
            playSound(sounds.sfx.select)
        end
    else
        menu.upPressed = false
    end

    if love.keyboard.isDown("down") then
        if not menu.downPressed then
            menu.selected = menu.selected + 1
            if menu.selected > #menu.options then menu.selected = 1 end
            menu.downPressed = true
            playSound(sounds.sfx.select)
        end
    else
        menu.downPressed = false
    end

    if love.keyboard.isDown("z") then
        if not menu.zPressed then
            menu:confirm()
            menu.zPressed = true
        end
    else
        menu.zPressed = false
    end
end

function menu:confirm()
    local choice = self.options[self.selected]
    if choice == "Start Game" then
        sounds.music.menu:stop()
        loadFile("game")
    elseif choice == "Options" then
        print("Options menu opened!") -- could show sub-menu
    elseif choice == "Exit" then
        love.event.quit()
    end
end

function module.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local startY = h / 2 - (#menu.options * 40) / 2

    for i, option in ipairs(menu.options) do
        if i == menu.selected then
            love.graphics.setColor(1, 1, 0) -- yellow highlight
        else
            love.graphics.setColor(1, 1, 1)
        end
        local textWidth = love.graphics.getFont():getWidth(option)
        love.graphics.print(option, (w - textWidth) / 2, startY + (i - 1) * 50)
    end

    love.graphics.setColor(1, 1, 1)
end

return module