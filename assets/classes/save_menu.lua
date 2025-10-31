-- # save_menu.lua
local module = {}

-- number of save slots
local slots = 3
local selected = 1
local active = false
local callback = nil  -- function to call when a save is made

-- load font
local font = love.graphics.newFont("assets/fonts/flexi-ibm-vga-true.regular.ttf", 24)

-- positions
local boxX, boxY = 200, 150
local boxW, boxH = 400, 300
local slotH = 50

local game = {}

-- slot data
local save = require("lib.save")  -- save system

local saves = {}

local function loadSlots()
    for i = 1, slots do
        local slotData = save.get("save_slot_"..i, nil)
        local text = slotData and ("Slot " .. i .. " - " .. slotData.room) or ("Slot " .. i .. " - (empty)")
        saves[i] = text
    end
end

-- show menu
function module.show(cb, g)
    active = true
    selected = 1
    callback = cb
    game = g
end

-- hide menu
function module.hide()
    active = false
    callback = nil
end

function module.update(dt)
    if not active then return end
end

function module.keypressed(key)
    if not active then return end

    if key == "up" then
        selected = selected - 1
        if selected < 1 then selected = slots end
        playSound(sounds.sfx.select)
    elseif key == "down" then
        selected = selected + 1
        if selected > slots then selected = 1 end
        playSound(sounds.sfx.select)
    elseif key == "z" then
        -- save to this slot
        save.set("save_slot_" .. selected, {
            room = game.room,
            player = game.player
        })
        print("Game saved in slot " .. selected)
        if callback then callback(selected) end
        playSound(sounds.sfx.save, 0.5)
        loadSlots()
        savePoint.interacting = false
    elseif key == "x" then
        -- cancel
        savePoint.interacting = false
        module.hide()
    end
end

loadSlots()

function module.draw()
    if not active then return end

    love.graphics.setFont(font)
    -- background box
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)
    love.graphics.setColor(1,1,1,1)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH)

    -- draw slots
    for i = 1, slots do
        local text = saves[i]

        if i == selected then
            love.graphics.setColor(1,1,0) -- highlight selected
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.print(text, boxX + 20, boxY + 30 + (i-1)*slotH)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.print("Z = Save  X = Cancel", boxX + 20, boxY + boxH - 40)
end

return module
