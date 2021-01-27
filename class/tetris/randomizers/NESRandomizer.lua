local _TetrisRandomizer = require "class.tetris.randomizers._TetrisRandomizer"

local NESRandomizer = CLASS("NESRandomizer", _TetrisRandomizer)

function NESRandomizer:generatePiece()
    local piece
    local tried = 0

    repeat
        piece = self.randomizer:random(1, 7)
        tried = tried + 1
    until piece ~= self:getLastPiece() or tried == 2

    table.insert(self.list, piece)

    return piece
end

return NESRandomizer
