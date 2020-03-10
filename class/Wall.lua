local Wall = CLASS("Wall")

function Wall:initialize(world, x, y, w, h, friction)
    self.body = love.physics.newBody(world, 0, 0, "static")
    self.body:setUserData(self)

    local shape = love.physics.newEdgeShape(x, y, x+w, y+h)

    local fixture = love.physics.newFixture(self.body, shape)
    fixture:setFriction(friction)
end

return Wall