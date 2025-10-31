-- # assets/classes/save.lua
local save = {}

-- cache saves in memory
local cache = {}

local function getFileName(name)
    return "saves/" .. name .. ".json"
end

function save.set(name, data)
    love.filesystem.createDirectory("saves")
    cache[name] = data
    local json = require("lib.dkjson")
    local contents = json.encode(data)
    love.filesystem.write(getFileName(name), contents)
end

function save.get(name, default)
    printTable(love.filesystem.getInfo(getFileName(name)))
    print(love.filesystem.getRealDirectory(getFileName(name)))
    if cache[name] then return cache[name] end
    local path = getFileName(name)
    if not love.filesystem.getInfo(path) then return default end
    local contents = love.filesystem.read(path)
    local json = require("lib.dkjson")
    local data, _, err = json.decode(contents)
    if not data then
        print("Error loading save:", err)
        return default
    end
    cache[name] = data
    return data
end

function save.exists(name)
    return love.filesystem.getInfo(getFileName(name)) ~= nil
end

function save.delete(name)
    cache[name] = nil
    love.filesystem.remove(getFileName(name))
end

return save
