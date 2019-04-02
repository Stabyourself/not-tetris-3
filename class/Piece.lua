local Piece = class("Piece")

function Piece:initialize(well, pieceType, angle)
    self.well = well
    self.pieceType = pieceType

    self.body = love.physics.newBody(well.world, PIECESTARTX*PHYSICSSCALE, PIECESTARTY*PHYSICSSCALE, "dynamic")
    self.body:setUserData(self)
    self.body:setAngle(angle)
    -- self.body:setBullet(true)

    self.fixtures = {}

    for y = 1, #self.pieceType.map do
        local row = self.pieceType.map[y]

        for x = 1, #row do
            local char = row:sub(x, x)

            if char == "#" then
                local shape = love.physics.newRectangleShape((x-.5-#row/2)*PHYSICSSCALE, (y-.5-#self.pieceType.map/2)*PHYSICSSCALE, 1*PHYSICSSCALE, 1*PHYSICSSCALE)
                table.insert(self.fixtures, love.physics.newFixture(self.body, shape))
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

    love.graphics.draw(self.pieceType.img, 0, 0, 0, 1, 1, self.pieceType.img:getWidth()/2, self.pieceType.img:getHeight()/2)

    love.graphics.pop()
end

function Piece:move(dir)
    self.body:applyForce(MOVEFORCE*PHYSICSSCALE*dir, 0)
end

function Piece:rotateTo(targetAngle)
    -- self.body:setAngle(normalizeAngle(self.body:getAngle()))

    -- local currentVelocity = self.body:getAngularVelocity()
    -- local currentAngle = self.body:getAngle()
    -- local diff = normalizeAngle(targetAngle - currentAngle)

    -- torque = diff*10000-currentVelocity*300

    -- self.body:applyTorque(torque*100000)

    self.body:setAngle(targetAngle)
end

return Piece