local Piece = class("Piece")

local Block = require "class.Block"

function Piece:initialize(playfield, pieceType)
    self.playfield = playfield
    self.pieceType = pieceType

    self.body = love.physics.newBody(playfield.world, PIECESTARTX, PIECESTARTY, "dynamic")
    self.body:setUserData(self)
    self.body:setAngle(0)
    -- self.body:setBullet(true)

    self.blocks = {}

    for x = 1, #self.pieceType.map do
        for y = 1, #self.pieceType.map[x] do
            if self.pieceType.map[x][y] then
                local block = Block:new(self, x-1-#self.pieceType.map/2, y-1-#self.pieceType.map[x]/2, self.pieceType.map[x][y])
                table.insert(self.blocks, block)
            end
        end
    end

    self.body:setLinearVelocity(0, MAXSPEEDY)
    self.active = true
end

function Piece:limitDownwardVelocity()
    local speedX, speedY = self.body:getLinearVelocity()

    if speedY > MAXSPEEDY then
        self.body:setLinearVelocity(speedX, MAXSPEEDY)
    end
end

function Piece:draw()
    love.graphics.push()
    love.graphics.scale(1/PHYSICSSCALE*PIECESCALE, 1/PHYSICSSCALE*PIECESCALE)
    love.graphics.translate(self.body:getPosition())
    love.graphics.rotate(self.body:getAngle())

    for _, block in ipairs(self.blocks) do
        block:draw()
    end

    love.graphics.pop()
end

function Piece:update(dt)
    for _, block in ipairs(self.blocks) do
        block:update(dt)
    end
end

function Piece:movement(dt)
    if love.keyboard.isDown("j") then
        self:rotate(-1)
    end

    if love.keyboard.isDown("k") then
        self:rotate(1)
    end

    -- Horizontal movement
    if love.keyboard.isDown("a") then
        self:move(-1)
    end

    if love.keyboard.isDown("d") then
        self:move(1)
    end

    -- vertical movement
    if not love.keyboard.isDown("s") then
        self:limitDownwardVelocity()
    end
end

function Piece:move(dir)
    self.body:applyForce(MOVEFORCE*dir, 0)
end

function Piece:rotate(dir)
    self.body:applyTorque(ROTATEFORCE*dir, 0)
end

function Piece:removeBlock(removeBlock)
end

function Piece:cut(rows)
    for _, block in ipairs(self.blocks) do
        block:cut(rows)
    end

    for i = #self.blocks, 1, -1 do
        if self.blocks[i].removeMe then
            table.remove(self.blocks, i)
        end
    end
end

return Piece