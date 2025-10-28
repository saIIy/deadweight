-- luau's table.find
function table.find(table, element)
    for index, value in pairs(table) do
        if value == element then
            return index
        end
    end
    return nil
end

-- luau's math.clamp
function math.clamp(n, min, max)
    if n > max then
        return max
    elseif n < min then
        return min
    else
        return n
    end
end

-- table debugger
---@param t table
function printTable(t)
    for i, v in pairs(t) do
        if type(v) ~= "table" then
            print("["..i.."] = "..v)
        end
    end
end

-- load libraries
anim8 = require("lib/anim8")
word_shift = require("lib/word_shift")
button = require("assets.classes.button")
sti = require("lib.sti")
libcamera = require("lib.camera")
wf = require("lib.windfield")

-- file management
function loadFile(filename)
    local datafile = require("src."..filename)

    for i, v in pairs(datafile) do
        if type(v) == "function" then
            love[i] = v
        end
    end
end

-- init
loadFile("game")