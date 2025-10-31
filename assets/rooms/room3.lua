local room = {}

room.music = loadSound("intersection", "music", "Intersection_0.9.ogg")

function room:load()
    love.graphics.setBackgroundColor(1, 1, 1)
end

return room