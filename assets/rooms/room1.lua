local room = {}

room.map = "test_map"

function room:load()
    love.graphics.setBackgroundColor(1, 1, 1)
    loadSound("intersection", "music", "Intersection_0.9.ogg")
end

function room:draw()

end

function room:update(dt)
    -- Room-specific update logic can go here
end

return room