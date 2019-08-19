local Randomizer = require "class.Randomizer"

local NESRandomizer = class("NESRandomizer", Randomizer)

function NESRandomizer:initialize()
    Randomizer.initialize(self)
end

function NESRandomizer:generatePiece()
    local piece
    local tried = 0

    repeat
        piece = love.math.random(1, 7)
        tried = tried + 1
    until piece ~= self:getLastPiece() or tried == 2

    table.insert(self.list, piece)

    return piece
end

return NESRandomizer
