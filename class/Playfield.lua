local Playfield = class("Playfield")

local Wall = require "class.Wall"
local pieceTypes = require "class.PieceType"
local Piece = require "class.Piece"

function Playfield:initialize(x, y, columns, rows)
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(function() end, function() end, function() end, self.postSolve)

    self.walls = {}
    table.insert(self.walls, Wall:new(self.world, 0, -5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- left
    table.insert(self.walls, Wall:new(self.world, self.columns*PHYSICSSCALE, -5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- right
    table.insert(self.walls, Wall:new(self.world, 0, self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION)) -- floor

    self.walls[1].dontDrop = true
    self.walls[2].dontDrop = true

    self.worldUpdateBuffer = WORLDUPDATEINTERVAL

    self.rowOverlay = false
    self.area = {}

    self.pieces = {}
    self:nextPiece()
end

function Playfield:update(dt)
    -- world is updated in fixed steps to prevent fps-dependency (box2d behaves differently with different deltas, even if the total is the same)
    self.worldUpdateBuffer = self.worldUpdateBuffer + dt

    while self.worldUpdateBuffer >= WORLDUPDATEINTERVAL do
        if self.spawnNewPieceNextFrame then
            self:nextPiece()
            self.spawnNewPieceNextFrame = false
        end

        if self.activePiece then
            self.activePiece:movement(WORLDUPDATEINTERVAL)
        end

        self.world:update(WORLDUPDATEINTERVAL)
        self.worldUpdateBuffer = self.worldUpdateBuffer - WORLDUPDATEINTERVAL

        -- print("update!")
        self:updateLines()
        if self.spawnNewPieceNextFrame then
            self:checkClearRow()
        end
    end

    for _, piece in ipairs(self.pieces) do
        piece:update(dt)
    end
end

function Playfield:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- overlay
    if self.rowOverlay then
        love.graphics.setColor(1, 1, 1, 0.2)

        for row = 2+math.fmod(self.rows, 1), self.rows, 2 do
            love.graphics.rectangle("fill", 0, (row-1)*PIECESCALE, self.columns*PIECESCALE, PIECESCALE)
        end

        love.graphics.setColor(1, 1, 1)
    end

    for _, v in ipairs(self.pieces) do
        v:draw()
    end

    if DEBUG_DRAWLINEAREA then
        for row = 1, 20 do
            local factor = self.area[row]/(math.floor(self.columns)*BLOCKSIZE)
            love.graphics.print(string.format("%.2f", factor*100), 0, (row-1)*PIECESCALE, 0, 0.5)
        end
    end

    love.graphics.pop()
end

function Playfield:worldToRow(y)
    return math.floor(y/PHYSICSSCALE)+1
end

function Playfield:rowToWorld(y)
    return y*PHYSICSSCALE
end

function Playfield:addArea(row, area)
    if row > 0 then
        self.area[row] = self.area[row] + area
    end
end

function Playfield:updateLines()
    for row = 1, self.rows do
        self.area[row] = 0
    end

    for _, piece in ipairs(self.pieces) do
        -- if piece ~= self.activePiece then -- don't include the active piece?
            for _, block in ipairs(piece.blocks) do
                block:setSubShapes()
            end
        -- end
    end
end

function Playfield:nextPiece()
    local pieceNum = love.math.random(1, #pieceTypes)
    local piece = Piece.fromPieceType(self, pieceTypes[pieceNum])

    self.activePiece = piece

    table.insert(self.pieces, piece)
end

function Playfield:gameOver()
    self.activePiece = nil
end

function Playfield.postSolve(a, b)
    local aObject = a:getBody():getUserData()
    local bObject = b:getBody():getUserData()

    local piece = false

    if aObject and aObject:isInstanceOf(Piece) and aObject == aObject.playfield.activePiece then
        piece = aObject
        otherObject = bObject
    end

    if bObject and bObject:isInstanceOf(Piece) and bObject == bObject.playfield.activePiece then
        piece = bObject
        otherObject = aObject
    end

    if piece and not otherObject.dontDrop then
        self = piece.playfield

        -- some velocity check here maybe

        if piece.body:getY() < PIECESTARTY+1 then
            self:gameOver()
            return
        end

        self.spawnNewPieceNextFrame = true
        self.activePiece = false
    end
end

function Playfield:addPiece(piece)
    table.insert(self.pieces, piece)
end

function Playfield:clearRow(rows)
    for i = #self.pieces, 1, -1 do
        self.pieces[i]:cut(rows)
    end
end

function Playfield:checkClearRow()
    local toClear = {}

    for row = 1, self.rows do
        local factor = self.area[row]/(math.floor(self.columns)*BLOCKSIZE)

        if factor >= LINECLEARREQUIREMENT then
            table.insert(toClear, row)
        end
    end

    if #toClear > 0 then
        self:clearRow(toClear)
    end
end

function Playfield:keypressed(key, unicode)

end

return Playfield
