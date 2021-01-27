local Puyo = CLASS("Puyo")

Puyo.size = 10/6 / 2 -- radius
Puyo.shape = love.physics.newCircleShape(Puyo.size*PHYSICSSCALE)

Puyo.diameter = Puyo.size*PHYSICSSCALE*2

function Puyo:initialize(playfield, type, offsetX, offsetY, group)
    self.playfield = playfield
    self.type = type

    self.group = group
    self.body = group.body

    Puyo.shape:setPoint((offsetX or 0)*self.diameter, (offsetY or 0)*self.diameter)
    self.fixture = love.physics.newFixture(self.body, Puyo.shape)
    self.fixture:setFriction(0.5)
    self.fixture:setRestitution(0.5)

    self.body:setUserData(self)
    self.body:setAngle(0)

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
    love.graphics.translate(self.fixture:getShape():getPoint())

    love.graphics.setColor(PUYOCOLORS[self.type])
    love.graphics.circle("fill", 0, 0, self.size*PHYSICSSCALE)

    love.graphics.pop()

    -- puyo group debug
    for _, neighbouringPuyo in ipairs(self.neighbouringPuyos) do
        local x1, y1 = self.body:getWorldPoint(self.fixture:getShape():getPoint())

        love.graphics.setLineWidth(30*(1-(neighbouringPuyo.distance-self.diameter) / (PUYODISTANCE-self.diameter) ))
        local x2, y2 = neighbouringPuyo.puyo.body:getWorldPoint(neighbouringPuyo.puyo.fixture:getShape():getPoint())

        love.graphics.line(x1, y1, x2, y2)
    end

    love.graphics.setColor(1, 1, 1)
end

function Puyo:move(dir)
    self.body:applyForce(MOVEFORCE*dir, 0)
end

function Puyo:rotate(dir)
    if dir == 1 then
        if self.body:getAngularVelocity() < PUYOMAXROTATESPEED then
            self.body:applyTorque(PUYOROTATEFORCE*dir, 0)
        end
    elseif dir == -1 then
        if self.body:getAngularVelocity() > -PUYOMAXROTATESPEED then
            self.body:applyTorque(PUYOROTATEFORCE*dir, 0)
        end
    end
end

function Puyo:insertNeighbour(neighbouringPuyo, distance)
    for _, checkingPuyo in ipairs(self.neighbouringPuyos) do
        if checkingPuyo.puyo == neighbouringPuyo then
            return
        end
    end

    table.insert(self.neighbouringPuyos,
        {
            puyo=neighbouringPuyo,
            distance=distance,
        }
    )
end

function Puyo:destroy()
    self.body:destroy()
    self.deleteMe = true
end


return Puyo