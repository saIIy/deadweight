function love.load()
    -- luau's table.find
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

    -- luau's math.clamp
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

    -- table debugger
    ---@param t table
    function printTable(t)
        for i, v in pairs(t) do
            if type(v) ~= "table" then
                print("["..i.."] = "..v)
            end
        end
    end

   -- Converts a Tiled hex color (#AARRGGBB or #RRGGBB) to {r, g, b, a}
    ---@param hex string
    ---@return table
    function parseTiledColor(hex)
        if type(hex) ~= "string" or hex == "" then
            return {1, 1, 1, 1}
        end

        hex = hex:gsub("#", "")

        -- Handle 3/4-digit shorthand colors (rare in Tiled)
        if #hex == 3 then
            local r, g, b = hex:match("(%x)(%x)(%x)")
            return {
                tonumber(r .. r, 16) / 255,
                tonumber(g .. g, 16) / 255,
                tonumber(b .. b, 16) / 255,
                1
            }
        elseif #hex == 4 then
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
            -- AARRGGBB (Tiled format)
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

    -- load libraries
    anim8 = require("lib/anim8")
    word_shift = require("lib/word_shift")
    button = require("assets.classes.button")
    sti = require("lib.sti")
    libcamera = require("lib.camera")
    wf = require("lib.windfield")

    -- file management
    ---@param filename string
    function loadFile(filename)
        local datafile = require("src."..filename)

        datafile.load()

        for i, v in pairs(datafile) do
            if type(v) == "function" and i ~= "load" then
                love[i] = v
            end
        end

        print("loaded file \""..filename..".lua\"")
    end

    local sounds = {
        sfx = {
            dissolve = "dissolve.wav",
            select = "select.mp3"
        },

        music = {
            menu = "Start_Menu_music.ogg",
        }
    }

    _G.sounds = {sfx = {}, music = {}}

    for i, v in pairs(sounds.sfx) do
        ---@type love.Source
        _G.sounds.sfx[i] = love.audio.newSource("assets/sounds/sfx/"..v, "static")
    end

    for i, v in pairs(sounds.music) do
        ---@type love.Source
        _G.sounds.music[i] = love.audio.newSource("assets/sounds/music/"..v, "stream")
        _G.sounds.music[i]:setLooping(true)
    end

    ---@param name string
    ---@param list string
    ---@param filename string
    ---@return love.Source
    function loadSound(name, list, filename)
        if not table.find({"music", "sfx"}, list) or sounds[list][name] then return _G.sounds.music.menu end

        local audiotype = "static"
        if list == "music" then audiotype = "stream" end

        _G.sounds[list][name] = love.audio.newSource(table.concat({"assets/sounds", list, filename}, "/"), audiotype)

        return _G.sounds[list][name]
    end

    ---@param sound love.Source
    function playSound(sound)
        sound:stop()
        sound:play()
    end

    function stopAllSounds()
        for _, v in pairs(_G.sounds.music) do
            v:stop()
        end
    end
    
    -- init
    loadFile("splash")
end