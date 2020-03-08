local _Randomizer = require "class.tetris.randomizers._Randomizer"

local NESRandomizer = class("NESRandomizer", _Randomizer)

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
