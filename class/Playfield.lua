local Playfield = class("Playfield")

local game = require "game"
local Wall = require "class.Wall"
local pieceTypes = require "class.pieceType"
local Piece = require "class.Piece"

function Playfield:initialize(x, y, columns, rows)
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows

    self.lineCoverage = {}

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(self.beginContact)

    self.walls = {}
    table.insert(self.walls, Wall:new(self.world, 0, -5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- left
    table.insert(self.walls, Wall:new(self.world, self.columns*PHYSICSSCALE, -5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- right
    table.insert(self.walls, Wall:new(self.world, 0, self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION)) -- floor

    self.walls[1].dontDrop = true
    self.walls[2].dontDrop = true

    self.worldUpdateBuffer = 0

    self.rowOverlay = true

    self.pieces = {}
    self:nextPiece()
end

function Playfield:update(dt)
    if self.spawnNewPieceNextFrame then
        self:nextPiece()
        self.spawnNewPieceNextFrame = false
    end

    -- world is updated in fixed steps to prevent fps-dependency (box2d behaves differently with different deltas, even if the total is the same)
    self.worldUpdateBuffer = self.worldUpdateBuffer + dt

    while self.worldUpdateBuffer >= WORLDUPDATEINTERVAL do
        if self.activePiece then
            self.activePiece:movement(WORLDUPDATEINTERVAL)
        end

        self.world:update(WORLDUPDATEINTERVAL)
        self.worldUpdateBuffer = self.worldUpdateBuffer - WORLDUPDATEINTERVAL
    end

    self:updateLines()
end

function Playfield:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- overlay
    if self.rowOverlay then
        love.graphics.setColor(1, 1, 1, 0.2)

        for i = 2+math.fmod(self.rows, 1), self.rows, 2 do
            love.graphics.rectangle("fill", 0, (i-1)*PIECESCALE, self.columns*PIECESCALE, PIECESCALE)
        end

        love.graphics.setColor(1, 1, 1)
    end

    for _, v in ipairs(self.pieces) do
        v:draw()
    end

    if DEBUGDRAW then
        love.graphics.setColor(1, 0, 0)
        for _, piece in ipairs(self.pieces) do
            love.graphics.push()
            love.graphics.scale(1/PHYSICSSCALE*PIECESCALE, 1/PHYSICSSCALE*PIECESCALE)
            love.graphics.translate(piece.body:getPosition())
            love.graphics.rotate(piece.body:getAngle())

            for _, fixture in ipairs(piece.body:getFixtures()) do -- this is good code, I promise
                love.graphics.polygon("line", fixture:getShape():getPoints())
            end

            love.graphics.pop()
        end
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.pop()
end

function Playfield:updateLines()
    for i = 1, self.rows do
        self.lineCoverage[i] = 0
    end

    for _, piece in ipairs(self.pieces) do
        for _, block in ipairs(piece.blocks) do
            -- doing all of this inline because I expect this to be performance-important code
            -- can be broken up later

            local topRow, bottomRow
            local points = {piece.body:getWorldPoints(block.shape:getPoints())}

            print_r(points)
        end
    end
end

function Playfield:nextPiece()
    local pieceNum = love.math.random(1, #pieceTypes)
    local piece = Piece:new(self, pieceTypes[pieceNum])

    self.activePiece = piece

    table.insert(self.pieces, piece)
end

function Playfield:gameOver()
    self.activePiece = nil
end

function Playfield.beginContact(a, b)
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

        if piece.body:getY() < 0 then
            self:gameOver()
            return
        end

        self.spawnNewPieceNextFrame = true
    end
end

return Playfield
