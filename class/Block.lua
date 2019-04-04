local Block = class("Block")

local img = love.graphics.newImage("img/tiles/0.png")


function Block:initialize(x, y, quad)
    self.x = x
    self.y = y
    self.quad = quad
    self.shape = love.physics.newRectangleShape((x+.5)*PHYSICSSCALE, (y+.5)*PHYSICSSCALE, 1*PHYSICSSCALE, 1*PHYSICSSCALE)
end

function Block:draw()
    love.graphics.draw(img, self.quad, self.x*8, self.y*8)
end

return Block
