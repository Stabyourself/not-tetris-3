local Piece = class("Piece")

function Piece:initialize(well, pieceType)
    self.well = well
    self.pieceType = pieceType

    self.body = love.physics.newBody(well.world, (self.well.x+PIECESTARTX)*PHYSICSSCALE, (self.well.y+PIECESTARTY)*PHYSICSSCALE, "dynamic")
    self.body:setUserData(self)
    self.body:setAngle(0)
    self.body:setBullet(true)

    self.fixtures = {}

    for x = 1, #self.pieceType.map do
        for y = 1, #self.pieceType.map[x] do
            if self.pieceType.map[x][y] then
                local shape = love.physics.newRectangleShape((x-.5-#self.pieceType.map/2)*PHYSICSSCALE, (y-.5-#self.pieceType.map[x]/2)*PHYSICSSCALE, 1*PHYSICSSCALE, 1*PHYSICSSCALE)
                local fixture = love.physics.newFixture(self.body, shape)
                fixture:setFriction(PIECEFRICTION)
                table.insert(self.fixtures, fixture)
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
    love.graphics.translate(self.body:getX()*PIECESCALE/PHYSICSSCALE, self.body:getY()*PIECESCALE/PHYSICSSCALE)
    love.graphics.rotate(self.body:getAngle())

    self.pieceType:draw()

    love.graphics.pop()
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
    self.body:applyForce(MOVEFORCE*PHYSICSSCALE*dir, 0)
end

function Piece:rotate(dir)
    self.body:applyTorque(ROTATEFORCE*PHYSICSSCALE*dir, 0)
end

return Piece