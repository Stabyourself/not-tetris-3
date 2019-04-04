local Block = class("Block")

local img = love.graphics.newImage("img/tiles/0.png")

function Block:initialize(x, y, quad)
    self.x = x
    self.y = y
    self.quad = quad
    local S = PHYSICSSCALE
    self.shape = love.physics.newPolygonShape(
        (x+DIAMONDADD)*S, (y)*S, -- clockwise, starting top leftish
        (x+1-DIAMONDADD)*S, (y)*S,
        (x+1)*S, (y+DIAMONDADD)*S,
        (x+1)*S, (y+1-DIAMONDADD)*S,
        (x+1-DIAMONDADD)*S, (y+1)*S,
        (x+DIAMONDADD)*S, (y+1)*S,
        (x)*S, (y+1-DIAMONDADD)*S,
        (x)*S, (y+DIAMONDADD)*S
    )
end

function Block:draw()
    love.graphics.draw(img, self.quad, self.x*8, self.y*8)
end

return Block
