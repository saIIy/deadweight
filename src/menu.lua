-- # menu.lua
-- Simple 4-directional Undertale-style menu with keypress-based movement

local module = {}

local menu = {}
menu.options = { "Continue", "Reset", "Exit" }
menu.selected = 1
menu.active = true

---@type love.Image
local logo

-- layout grid (top row = Start + Options, bottom row = Exit)
menu.layout = {
    { 1, 2 },
    { 3 }
}

function module.load()
    love.graphics.setFont(love.graphics.newFont("assets/fonts/flexi-ibm-vga-true.regular.ttf", 32))
    playSound(sounds.music.menu)
    logo = love.graphics.newImage("assets/images/dw_logo_4.png", {dpiscale=3})
end

-- handle navigation + confirm in one place
function module.keypressed(key)
    if not menu.active then return end

    local function getPosition(index)
        for r, row in ipairs(menu.layout) do
            for c, v in ipairs(row) do
                if v == index then
                    return r, c
                end
            end
        end
    end

    local row, col = getPosition(menu.selected)

    if key == "left" then
        col = col - 1
        if col < 1 then col = #menu.layout[row] end
        menu.selected = menu.layout[row][col]

    elseif key == "right" then
        col = col + 1
        if col > #menu.layout[row] then col = 1 end
        menu.selected = menu.layout[row][col]

    elseif key == "up" then
        row = row - 1
        if row < 1 then row = #menu.layout end
        menu.selected = menu.layout[row][math.min(col, #menu.layout[row])]

    elseif key == "down" then
        row = row + 1
        if row > #menu.layout then row = 1 end
        menu.selected = menu.layout[row][math.min(col, #menu.layout[row])]

    elseif key == "z" or key == "return" then
        menu:confirm()
    end

    if table.find({"left", "right", "up", "down"}, key) then
        playSound(sounds.sfx.select)
    end
end

function menu:confirm()
    local choice = self.options[self.selected]
    if choice == "Continue" then
        stopAllSounds()
        loadFile("game")
    elseif choice == "Reset" then
        print("resetted owo") -- placeholder
    elseif choice == "Exit" then
        love.event.quit()
    end
end

function module.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local font = love.graphics.getFont()
    local lineHeight = 60
    local startY = h / 2 - (#menu.layout * lineHeight) / 2

    love.graphics.draw(logo, w/2 - logo:getWidth()/2, -20, 0)

    for r, row in ipairs(menu.layout) do
        local totalWidth = 0
        for _, i in ipairs(row) do
            totalWidth = totalWidth + font:getWidth(menu.options[i]) + 60
        end
        totalWidth = totalWidth - 60
        local startX = (w - totalWidth) / 2

        for c, i in ipairs(row) do
            local option = menu.options[i]
            if i == menu.selected then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.print(option, startX, startY + (r - 1) * lineHeight)
            startX = startX + font:getWidth(option) + 60
        end
    end

    love.graphics.setColor(1, 1, 1)
end

return module
