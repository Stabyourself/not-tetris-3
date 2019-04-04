local Well = class("Well")

local game = require "game"
local Wall = require "class.Wall"
local pieceTypes = require "class.pieceType"
local Piece = require "class.Piece"

function Well:initialize(x, y, columns, rows)
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(self.beginContact)

    self.walls = {}
    table.insert(self.walls, Wall:new(self.world, self.x, self.y-5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- left
    table.insert(self.walls, Wall:new(self.world, self.x+self.columns*PHYSICSSCALE, self.y-5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- right
    table.insert(self.walls, Wall:new(self.world, self.x, self.y+self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION)) -- floor

    self.walls[1].dontDrop = true
    self.walls[2].dontDrop = true

    self.worldUpdateBuffer = 0

    self.pieces = {}
    self:nextPiece()
end

function Well:update(dt)
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
end

function Well:draw()
    love.graphics.draw(backgroundImg)

    for _, v in ipairs(self.pieces) do
        v:draw()
    end
end

function Well:nextPiece()
    local pieceNum = love.math.random(1, #pieceTypes)
    local piece = Piece:new(self, pieceTypes[pieceNum])

    self.activePiece = piece

    table.insert(self.pieces, piece)
end

function Well:gameOver()
    self.activePiece = nil
end

function Well.beginContact(a, b)
    local aObject = a:getBody():getUserData()
    local bObject = b:getBody():getUserData()

    local piece = false

    if aObject and aObject:isInstanceOf(Piece) and aObject == aObject.well.activePiece then
        piece = aObject
        otherObject = bObject
    end

    if bObject and bObject:isInstanceOf(Piece) and bObject == bObject.well.activePiece then
        piece = bObject
        otherObject = aObject
    end

    if piece and not otherObject.dontDrop then
        self = piece.well

        -- some velocity check here maybe

        if piece.body:getY() < 0 then
            self:gameOver()
            return
        end

        self.spawnNewPieceNextFrame = true
    end
end

return Well
