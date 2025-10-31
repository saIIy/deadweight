-- # menu.lua
-- Undertale-style main menu with directional movement, save slots, and reset confirmation

local module = {}
local menu = {}

menu.options = { "Continue", "Reset", "Exit" }
menu.selected = 1
menu.active = true

local save = require("lib.save")

local slots = 3
local saveSlots = {}
local currentSlot = 1
local confirmingReset = false

local function loadSlots()
    for i = 1, slots do
        local slotData = save.get("save_slot_" .. i, nil)
        local text = slotData and ("Slot " .. i .. " - " .. slotData.room) or ("Slot " .. i .. " - (empty)")
        saveSlots[i] = { text = text, name = "save_slot_" .. i }
    end
end

menu.layout = {
    { 2, 3 },
    { 1 }
}

---@type love.Image
local logo

function module.load()
    love.graphics.setFont(love.graphics.newFont("assets/fonts/flexi-ibm-vga-true.regular.ttf", 32))
    playSound(sounds.music.menu)
    loadSlots()
    logo = love.graphics.newImage("assets/images/dw_logo_4.png", { dpiscale = 3 })
end

function module.keypressed(key)
    if not menu.active then return end

    if confirmingReset then
        if key == "z" or key == "return" then
            local slot = saveSlots[currentSlot].name
            if save.exists(slot) then
                print("Deleting " .. slot)
                save.delete(slot)
                --playSound(sounds.sfx.delete)
                loadSlots()
            else
                print("No save found for " .. slot)
            end
            confirmingReset = false
        elseif key == "x" or key == "escape" then
            confirmingReset = false
            --playSound(sounds.sfx.cancel)
        end
        return
    end

    local function getPosition(index)
        for r, row in ipairs(menu.layout) do
            for c, v in ipairs(row) do
                if v == index then return r, c end
            end
        end
    end

    local row, col = getPosition(menu.selected)

    if key == "left" then
        if menu.selected == 1 then
            currentSlot = currentSlot - 1
            if currentSlot < 1 then currentSlot = #saveSlots end
        else
            col = col - 1
            if col < 1 then col = #menu.layout[row] end
            menu.selected = menu.layout[row][col]
        end

    elseif key == "right" then
        if menu.selected == 1 then
            currentSlot = currentSlot + 1
            if currentSlot > #saveSlots then currentSlot = 1 end
        else
            col = col + 1
            if col > #menu.layout[row] then col = 1 end
            menu.selected = menu.layout[row][col]
        end

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

    if key == "left" or key == "right" or key == "up" or key == "down" then
        playSound(sounds.sfx.select)
    end
end

function menu:confirm()
    local choice = self.options[self.selected]
    if choice == "Continue" then
        local slot = saveSlots[currentSlot].name
        if save.exists(slot) then
            stopAllSounds()
            print("Loading " .. slot)
            selected_save_slot = currentSlot
        else
            print("No save data in " .. slot)
            print("Creating new file...")
        end
        stopAllSounds()
        loadFile("game")
    elseif choice == "Reset" then
        local slot = saveSlots[currentSlot]
        confirmingReset = true
        print("Confirm delete for " .. slot.name)
        --playSound(sounds.sfx.warning)

    elseif choice == "Exit" then
        love.event.quit()
    end
end

function module.draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local font = love.graphics.getFont()
    local lineHeight = 60
    local startY = h / 2 - (#menu.layout * lineHeight) / 2

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

            if option == "Continue" and i == menu.selected then
                local slotText = "<- "..saveSlots[currentSlot].text.." ->"
                love.graphics.setColor(0.9, 0.9, 0.9)
                love.graphics.print(slotText, (w - font:getWidth(slotText)) / 2, startY + (r - 1) * lineHeight + 50)
            end

            startX = startX + font:getWidth(option) + 60
        end
    end

    -- confirmation popup
    if confirmingReset then
        local msg = "Delete " .. saveSlots[currentSlot].text .. "?"
        local sub = "Z = Yes   X = No"
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(msg, (w - font:getWidth(msg)) / 2, h / 2 - 20)
        love.graphics.print(sub, (w - font:getWidth(sub)) / 2, h / 2 + 20)
    end

    love.graphics.setColor(1, 1, 1)
end

return module
