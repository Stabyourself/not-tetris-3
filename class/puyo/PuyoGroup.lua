local PuyoGroup = CLASS("PuyoGroup")
local Puyo = require "class.puyo.Puyo"

function PuyoGroup:initialize(playfield, puyoColors)
    self.playfield = playfield

    self.body = love.physics.newBody(playfield.world, PIECESTARTX, PIECESTARTY, "dynamic")

    self.puyos = {}
    for y = 1, #puyoColors do
        for x = 1, #puyoColors[y] do
            if puyoColors[y][x] then
                local offX = x - #puyoColors[y]/2-.5
                local offY = y - #puyoColors/2-.5
                table.insert(self.puyos, Puyo:new(self.playfield, puyoColors[y][x], offX, offY, self))
            end
        end
    end
end

function PuyoGroup:split()
    for _, puyo in ipairs(self.puyos) do
        local x, y = puyo.body:getWorldPoint(puyo.fixture:getShape():getPoint())

        local vx, vy = puyo.body:getLinearVelocity()
        local friction = puyo.fixture:getFriction()
        local restitution = puyo.fixture:getRestitution()

        puyo.body = love.physics.newBody(self.playfield.world, x, y, "dynamic")
        puyo.body:setLinearVelocity(vx, vy)
        puyo.body:setUserData(puyo)

        Puyo.shape:setPoint(0, 0)
        puyo.fixture:destroy()

        puyo.fixture = love.physics.newFixture(puyo.body, Puyo.shape)
        puyo.fixture:setRestitution(restitution)
        puyo.fixture:setFriction(friction)
    end

    self.body:destroy()
end

return PuyoGroup
