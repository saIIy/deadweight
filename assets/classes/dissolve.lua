-- dissolve.lua
local dissolve = {}
dissolve.__index = dissolve

function dissolve.new(image, x, y, bsize, delay)
    local self = setmetatable({}, dissolve)
    self.image = image
    self.x, self.y = x, y
    self.t = 0
    self.enabled = false
    self.starcount = 0
    self.redup = 0
    self.timer = 0
    self.bsize = bsize or 8
    self.blocks = {}
    self.blendR = 1
    self.blendG = 1
    self.blendB = 1
    self.alpha = 1
    self.delay = delay or 0
    return self
end

function dissolve:execute()
    if self.enabled then return end
    self.enabled = true
    self.timer = 0
    sounds.sfx.dissolve:stop()
    sounds.sfx.dissolve:play()
end

function dissolve:update(dt)
    self.timer = self.timer + dt

    if self.timer > self.delay and not self.enabled and self.delay ~= -1 then
        sounds.sfx.dissolve:stop()
        self.enabled = true
        sounds.sfx.dissolve:play()
    end

    if not self.enabled then return end

    local iw, ih = self.image:getWidth(), self.image:getHeight()

    if self.t == 0 then
        self.xs = math.ceil(iw / self.bsize)
        self.ys = math.ceil(ih / self.bsize)
        for i = 0, self.xs do
            self.blocks[i] = {}
            for j = 0, self.ys do
                local bx = self.x + (i * self.bsize)
                local by = self.y + (j * self.bsize)
                self.blocks[i][j] = {
                    bx = bx,
                    by = by,
                    bspeed = 0,
                    bsin = (4 + (j * 3)) - i
                }
            end
        end
        -- love.audio.play(sound_dissolve) -- optional
    end

    if self.t >= 1 then
        if self.redup < 10 then
            self.redup = self.redup + 0.3
        end

        -- color fade to red
        local mix = self.redup / 10
        self.blendR = 1
        self.blendG = 1 - mix
        self.blendB = 1 - mix

        for i = 0, self.xs do
            for j = 0, self.ys do
                local b = self.blocks[i][j]
                if b.bsin <= 0 then
                    b.bspeed = b.bspeed + 0.25
                end
                b.bx = b.bx + b.bspeed
                b.bsin = b.bsin - 1
            end
        end
    end

    self.t = self.t + 1
end

function dissolve:draw()
    if self.t == 0 then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.image, self.x, self.y)
        return
    end

    if self.enabled then
        love.graphics.setColor(self.blendR, self.blendG, self.blendB, 1)

        for i = 0, self.xs do
            for j = 0, self.ys do
                local b = self.blocks[i][j]
                local sx = i * self.bsize
                local sy = j * self.bsize
                local alpha = 1 - (b.bspeed / 12)
                if alpha > 0 then
                    love.graphics.setColor(self.blendR, self.blendG, self.blendB, alpha)
                    love.graphics.draw(
                        self.image,
                        love.graphics.newQuad(sx, sy, self.bsize, self.bsize, self.image:getDimensions()),
                        b.bx, self.y + (j * self.bsize)
                    )
                end
            end
        end
    end
end

return dissolve
