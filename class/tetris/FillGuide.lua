FillGuide = CLASS("FillGuide")

function FillGuide:initialize(w)
    self.w = w

    self.fill = 0
    self.targetFill = self.fill
end

function FillGuide:update(dt)
    if self.fill < self.targetFill then
        self.fill = math.min(self.targetFill, self.fill+(self.targetFill-self.fill)*dt*20)
    else
        self.fill = math.max(self.targetFill, self.fill+(self.targetFill-self.fill)*dt*20)
    end
end

function FillGuide:draw(x, y, w)
    -- if row%2 == 0 then
    --     love.graphics.setColor(LINECOLORS[2])
    -- else
    --     love.graphics.setColor(0, 0, 0)
    -- end
    -- love.graphics.rectangle("fill", x, y, math.sign(w)*BLOCKSCALE, BLOCKSCALE)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x, y, self.fill*w, BLOCKSCALE)
end

function FillGuide:smoothSet(i)
    self.targetFill = i
end

return FillGuide
