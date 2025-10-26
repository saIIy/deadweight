local function Button(text, func, args, size)
    local font = love.graphics.getFont()
    font:setFilter("nearest", "nearest")

    local buttonClass = {
        text = text or "Button",
        func = func or function() print("Yay!") end,
        args = args or {},
        size = size or 1,
        width = font:getWidth(text) * size + 20,
        height = font:getHeight() * size + 10,
        text_pos = {x = 0, y = 0},
    }

    function buttonClass:draw(x, y)
        self.text_pos = {x = x, y = y} or self.text_pos

        -- Draw button text
        love.graphics.setColor(1, 1, 1) -- Text color
        self.text_pos.x = self.text_pos.x
        self.text_pos.y = self.text_pos.y
        love.graphics.print(self.text, self.text_pos.x, self.text_pos.y, 0, size, size)
    end

    return buttonClass
end

return Button