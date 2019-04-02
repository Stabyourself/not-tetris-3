local Wall = class("Wall")

function Wall:initialize(world, x, y, w, h)
    self.body = love.physics.newBody(world, 0, 0, "static")
    self.body:setUserData(self)

    local shape = love.physics.newEdgeShape(x*PHYSICSSCALE, y*PHYSICSSCALE, w*PHYSICSSCALE, h*PHYSICSSCALE)

    love.physics.newFixture(self.body, shape)
end

return Wall