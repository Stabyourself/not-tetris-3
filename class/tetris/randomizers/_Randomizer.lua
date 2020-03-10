local Randomizer = CLASS("_Randomizer")

local mirrorTable = {
    1, 6, 5, 4, 3, 2, 7
}

function Randomizer:initialize()
    self.list = {}
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

function Randomizer:getLastPiece()
    return self.list[#self.list]
end

return Randomizer