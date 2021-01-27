local _TetrisRandomizer = require "class.puyo.randomizers._PuyoRandomizer"

local PuyoRandomizer = CLASS("PuyoRandomizer", _TetrisRandomizer)

function PuyoRandomizer:generatePiece()
    local group = {
        {love.math.random(#PUYOCOLORS)},
        {love.math.random(#PUYOCOLORS)},
    }

    table.insert(self.list, group)

    return group
end

return PuyoRandomizer
