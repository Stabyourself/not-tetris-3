local NextPieceContainer = CLASS("NextPieceContainer")
local Puyo = require "class.puyo.Puyo"

function NextPieceContainer:initialize(playfield, x, y)
    self.playfield = playfield
    self.x = x
    self.y = y

    self.group = false
end

function NextPieceContainer:draw()
    if self.group then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.scale(Puyo.size*BLOCKSCALE*2, Puyo.size*BLOCKSCALE*2)

        for y = 1, #self.group do
            for x = 1, #self.group[y] do
                if self.group[y][x] then
                    local rx = x-#self.group[y]/2-.5
                    local ry = y-#self.group/2-.5

                    love.graphics.setColor(PUYOCOLORS[self.group[y][x]])

                    love.graphics.circle("fill", rx, ry, 0.5)
                end
            end
        end

        love.graphics.pop()
    end
end

return NextPieceContainer
