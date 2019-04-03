local Wall = class("Wall")

function Wall:initialize(world, x, y, w, h, friction)
    self.body = love.physics.newBody(world, 0, 0, "static")
    self.body:setUserData(self)

    local shape = love.physics.newEdgeShape(x*PHYSICSSCALE, y*PHYSICSSCALE, (x+w)*PHYSICSSCALE, (y+h)*PHYSICSSCALE)

    local fixture = love.physics.newFixture(self.body, shape)
    fixture:setFriction(friction or 0)
end

return Wall