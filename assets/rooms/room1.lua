local room = {}

room.music = loadSound("intersection", "music", "Intersection_0.9.ogg")

function room:load()
    love.graphics.setBackgroundColor(1, 1, 1)
end

function room:draw()

end

function room:update(dt)
    -- Room-specific update logic can go here
end

return room