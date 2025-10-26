local room = {}

room.map = "test_map"

function room:load()
    
end

function room:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.print("This is Room 2", 100, 100)
end

function room:update(dt)
    -- Room-specific update logic can go here
end

return room