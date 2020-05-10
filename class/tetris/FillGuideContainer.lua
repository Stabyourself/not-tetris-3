local FillGuideContainer = CLASS("FillGuideContainer")
local FillGuide = require "class.tetris.FillGuide"

function FillGuideContainer:initialize(playfield, x, y, w)
    self.playfield = playfield
    self.x = x
    self.y = y
    self.w = w

    self.fillGuides = {}
    for row = 1, self.playfield.rows do
        self.fillGuides[row] = FillGuide:new()
    end
end

function FillGuideContainer:update(dt)
    util.updateGroup(self.fillGuides, dt)
end

function FillGuideContainer:draw()
    for row = 1, self.playfield.rows do
        self.fillGuides[row]:draw(self.x, self.y+(row-1)*BLOCKSCALE, self.w)
    end
end

return FillGuideContainer
