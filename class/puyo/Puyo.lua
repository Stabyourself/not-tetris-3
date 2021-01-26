local Puyo = CLASS("Puyo")

Puyo.size = 10/6 / 2 -- radius

Puyo.shape = love.physics.newCircleShape(Puyo.size*PHYSICSSCALE)

function Puyo:initialize(playfield, group)
    self.playfield = playfield
    self.group = group

    self.body = love.physics.newBody(playfield.world, PIECESTARTX, PIECESTARTY, "dynamic")
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setFriction(1)

    self.body:setUserData(self)
    self.body:setAngle(0)
    -- self.body:setBullet(true)

    self.body:setLinearVelocity(0, self.playfield:getMaxSpeedY())
    self.active = true

    self.neighbouringPuyos = {}
end

--- Stops the piece from falling too fast, based on the level usually
function Puyo:limitDownwardVelocity()
    local speedX, speedY = self.body:getLinearVelocity()

    if speedY > self.playfield:getMaxSpeedY() then
        self.body:setLinearVelocity(speedX, self.playfield:getMaxSpeedY())
    end
end

function Puyo:update(dt)

end

function Puyo:draw()
    love.graphics.push()
    love.graphics.translate(self.body:getPosition())
    love.graphics.rotate(self.body:getAngle())

    love.graphics.setColor(self.playfield.colors[self.group])
    love.graphics.circle("fill", 0, 0, self.size*PHYSICSSCALE)

    love.graphics.setColor(1, 1, 1)

    love.graphics.pop()

    -- puyo group debug
    for _, neighbouringPuyo in ipairs(self.neighbouringPuyos) do
        local x1, y1 = self.body:getPosition()
        local x2, y2 = neighbouringPuyo.body:getPosition()

        love.graphics.line(x1, y1, x2, y2)
    end
end

function Puyo:move(dir)
    self.body:applyForce(MOVEFORCE*dir, 0)
end

function Puyo:rotate(dir)
    self.body:applyTorque(ROTATEFORCE*dir, 0)
end

function Puyo:insertNeighbour(neighbouringPuyo)
    for _, checkingPuyo in ipairs(self.neighbouringPuyos) do
        if checkingPuyo == neighbouringPuyo then
            return
        end
    end

    table.insert(self.neighbouringPuyos, neighbouringPuyo)
end

function Puyo:destroy()
    self.body:destroy()
    self.deleteMe = true
end


return Puyo