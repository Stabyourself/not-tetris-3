local Block = class("Block")

local img = love.graphics.newImage("img/tiles/0.png")

function Block:initialize(x, y, quad)
    self.x = x
    self.y = y
    self.quad = quad

    if DIAMONDADD > 0 then
        error("DIAMONDADD support broke.")
        self.shape = love.physics.newPolygonShape(
            x+DIAMONDADD, y, -- clockwise, starting top leftish
            x+1-DIAMONDADD, y,
            x+1, y+DIAMONDADD,
            x+1, y+1-DIAMONDADD,
            x+1-DIAMONDADD, y+1,
            x+DIAMONDADD, y+1,
            x, y+1-DIAMONDADD,
            x, y+DIAMONDADD
        )
    else
        self.shape = love.physics.newRectangleShape((x+.5)*PHYSICSSCALE, (y+.5)*PHYSICSSCALE, PHYSICSSCALE, PHYSICSSCALE)
    end
end

function Block:draw()
    love.graphics.draw(img, self.quad, self.x*PHYSICSSCALE, self.y*PHYSICSSCALE, 0, PHYSICSSCALE/PIECESCALE)
end

return Block
