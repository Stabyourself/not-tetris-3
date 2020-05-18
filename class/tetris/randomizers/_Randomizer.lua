local Randomizer = CLASS("_Randomizer")

local mirrorTable = {
    1, 6, 5, 4, 3, 2, 7
}

function Randomizer:initialize()
    self.list = {}

    local seed = love.timer.getTime()
    if FIXEDRNG then
        seed = 5450
    end

    self.randomizer = love.math.newRandomGenerator(seed)
end

function Randomizer:getPiece(i, mirrored)
    local piece
    if self.list[i] then
        piece = self.list[i]
    else
        piece = self:generatePiece()
    end

    if mirrored then
        piece = mirrorTable[piece]
    end

    return piece
end

function Randomizer:generatePiece()
    error("_Randomizer was used to generate a piece. This shouldn't happen.")
    return 4 -- guaranteed to be random.
end

function Randomizer:getLastPiece()
    return self.list[#self.list]
end

return Randomizer