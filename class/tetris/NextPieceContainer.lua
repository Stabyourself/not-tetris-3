local NextPieceContainer = CLASS("NextPieceContainer")
local blockQuads = {}

for i = 1, 3 do
    blockQuads[i] = love.graphics.newQuad((i-1)*10+1, 1, 8, 8, 30, 10)
end

function NextPieceContainer:initialize(playfield, x, y)
    self.playfield = playfield
    self.x = x
    self.y = y

    self.pieceType = false
end

function NextPieceContainer:draw()
    if self.pieceType then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)

        for x = 1, #self.pieceType.map do
            for y = 1, #self.pieceType.map[x] do
                if self.pieceType.map[x][y] then
                    local rx = x-1-#self.pieceType.map/2
                    local ry = y-1-#self.pieceType.map[x]/2

                    love.graphics.draw(self.playfield:getBlockGraphic(), blockQuads[self.pieceType.map[x][y]], rx*BLOCKSCALE, ry*BLOCKSCALE)
                end
            end
        end

        love.graphics.pop()
    end
end

return NextPieceContainer
