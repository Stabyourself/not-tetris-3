local Well = class("Well")

local game = require "game"
local Wall = require "class.Wall"
local pieceTypes = require "class.pieceType"
local Piece = require "class.Piece"

function Well:initialize(x, y)
    self.x = x
    self.y = y

    self.world = love.physics.newWorld(0, 50*PHYSICSSCALE)
    self.world:setCallbacks(self.beginContact)

    self.walls = {}
    table.insert(self.walls, Wall:new(self.world, 0, -5, 0, 18)) -- left
    table.insert(self.walls, Wall:new(self.world, 10, -5, 10, 18)) -- right
    table.insert(self.walls, Wall:new(self.world, 0, 18, 10, 18)) -- floor

    self.walls[1].dontDrop = true
    self.walls[2].dontDrop = true

    self.targetAngle = 0

    self.pieces = {}
    self:nextPiece()
end

function Well:update(dt)
    if self.spawnNewPieceNextFrame then
        self:nextPiece()
        self.spawnNewPieceNextFrame = false
    end

    if love.keyboard.isDown("left") then
        self.targetAngle = self.targetAngle - dt*3
    elseif love.keyboard.isDown("right") then
        self.targetAngle = self.targetAngle + dt*3
    end

    if self.activePiece then
        if love.keyboard.isDown("a") then
            self.activePiece:move(-1)
        end

        if love.keyboard.isDown("d") then
            self.activePiece:move(1)
        end

        if not love.keyboard.isDown("s") then
            self.activePiece:limitDownwardVelocity()
        end

        self.activePiece:rotateTo(self.targetAngle)
    end

    self.world:update(dt)
end

function Well:draw()
    love.graphics.draw(backgroundImg)

    -- translate by the world offset for pieces
    love.graphics.push()
    love.graphics.translate(16, 0)

    for _, v in ipairs(self.pieces) do
        v:draw()
    end

    love.graphics.pop()
end

function Well:nextPiece()
    local pieceNum = math.random(1, #pieceTypes)
    local piece = Piece:new(self, pieceTypes[pieceNum], self.targetAngle)

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
            game.gameOver()
            return
        end

        self.spawnNewPieceNextFrame = true
    end
end

return Well
