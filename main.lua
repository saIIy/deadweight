-- # main.lua

function love.load()
    selected_save_slot = 0

    -- table.find (Luau-style)
    ---@param table table
    ---@param element any
    ---@return number|nil
    function table.find(table, element)
        for index, value in pairs(table) do
            if value == element then
                return index
            end
        end
        return nil
    end

    -- math.clamp (Luau-style)
    ---@param n number
    ---@param min number
    ---@param max number
    ---@return number
    function math.clamp(n, min, max)
        if n > max then
            return max
        elseif n < min then
            return min
        else
            return n
        end
    end

    -- prints all non-table values in a table
    ---@param t table
    function printTable(t)
        if not t then print(nil) return end
        for i, v in pairs(t) do
            if type(v) ~= "table" then
                print("["..i.."] = "..v)
            end
        end
    end

    -- converts a Tiled hex color to {r, g, b, a}
    ---@param hex string
    ---@return table
    function parseTiledColor(hex)
        if type(hex) ~= "string" or hex == "" then
            return {1, 1, 1, 1}
        end

        hex = hex:gsub("#", "")

        if #hex == 3 then
            -- RGB
            local r, g, b = hex:match("(%x)(%x)(%x)")
            return {
                tonumber(r .. r, 16) / 255,
                tonumber(g .. g, 16) / 255,
                tonumber(b .. b, 16) / 255,
                1
            }
        elseif #hex == 4 then
            -- ARGB
            local a, r, g, b = hex:match("(%x)(%x)(%x)(%x)")
            return {
                tonumber(r .. r, 16) / 255,
                tonumber(g .. g, 16) / 255,
                tonumber(b .. b, 16) / 255,
                tonumber(a .. a, 16) / 255
            }
        elseif #hex == 6 then
            -- RRGGBB
            local r, g, b = hex:match("(%x%x)(%x%x)(%x%x)")
            return {
                tonumber(r, 16) / 255,
                tonumber(g, 16) / 255,
                tonumber(b, 16) / 255,
                1
            }
        elseif #hex == 8 then
            -- AARRGGBB
            local a, r, g, b = hex:match("(%x%x)(%x%x)(%x%x)(%x%x)")
            return {
                tonumber(r, 16) / 255,
                tonumber(g, 16) / 255,
                tonumber(b, 16) / 255,
                tonumber(a, 16) / 255
            }
        else
            return {1, 1, 1, 1}
        end
    end

    -- load required libraries
    anim8 = require("lib.anim8")
    word_shift = require("lib.word_shift")
    sti = require("lib.sti")
    libcamera = require("lib.camera")
    wf = require("lib.windfield")

    -- load and bind functions from a file in src/
    ---@param filename string
    function loadFile(filename)
        local datafile = require("src."..filename)

        if datafile.load then
            datafile.load()
        end

        for i, v in pairs(datafile) do
            if type(v) == "function" and i ~= "load" then
                love[i] = v

                if not datafile.update then
                    love.update = function () end
                end

                if not datafile.draw then
                    love.update = function () end
                end
            end
        end

        print("loaded file \""..filename..".lua\"")
    end

    -- list of sound files
    local sounds = {
        sfx = {
            dissolve = "dissolve.wav",
            select = "select.mp3",
            save = "savepoint.mp3"
        },

        music = {
            menu = {"Start_Menu_music.ogg", 0.5},
        }
    }

    _G.sounds = {sfx = {}, music = {}}

    -- load SFX
    for i, v in pairs(sounds.sfx) do
        _G.sounds.sfx[i] = love.audio.newSource("assets/sounds/sfx/"..v, "static")
    end

    -- load music
    for i, v in pairs(sounds.music) do
        _G.sounds.music[i] = love.audio.newSource("assets/sounds/music/"..v[1], "stream")
        _G.sounds.music[i]:setVolume(v[2] or 1)
        _G.sounds.music[i]:setLooping(true)
    end

    -- helper for loading a new sound
    ---@param name string
    ---@param list string
    ---@param filename string
    ---@return love.Source
    function loadSound(name, list, filename, volume)
        if not table.find({"music", "sfx"}, list) then
            return _G.sounds.music.menu
        end

        if _G.sounds[list][name] then
            return _G.sounds[list][name]
        end

        local audiotype = "static"
        if list == "music" then audiotype = "stream" end

        _G.sounds[list][name] = love.audio.newSource(table.concat({"assets/sounds", list, filename}, "/"), audiotype)
        _G.sounds[list][name]:setLooping(true)
        _G.sounds[list][name]:setVolume(volume or 1)

        return _G.sounds[list][name]
    end

    -- plays a sound from the given source
    ---@param sound love.Source
    function playSound(sound, volume)
        local oldv = sound:getVolume()
        sound:stop()
        sound:setVolume(volume or oldv)
        sound:play()
    end

    -- stops all background music
    function stopAllSounds()
        for _, v in pairs(_G.sounds.music) do
            v:stop()
        end
    end
    
    -- start splash screen file
    loadFile("splash")
end
