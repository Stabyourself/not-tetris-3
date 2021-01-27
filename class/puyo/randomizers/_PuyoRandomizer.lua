local PuyoRandomizer = CLASS("PuyoRandomizer")

function PuyoRandomizer:initialize()
    self.list = {}

    local seed = love.timer.getTime()
    if FIXEDRNG then
        seed = 5450
    end

    self.randomizer = love.math.newRandomGenerator(seed)
end

function PuyoRandomizer:getPiece(i)
    local piece
    if self.list[i] then
        piece = self.list[i]
    else
        piece = self:generatePiece()
    end

    return piece
end

function PuyoRandomizer:generatePiece()
    error("_Randomizer was used to generate a piece. This shouldn't happen.")
    return 4 -- guaranteed to be random.
end

function PuyoRandomizer:getLastPiece()
    return self.list[#self.list]
end

return PuyoRandomizer