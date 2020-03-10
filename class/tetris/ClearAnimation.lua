ClearAnimation = CLASS("ClearAnimation")

function ClearAnimation:initialize(playfield, row)
    self.playfield = playfield
    self.row = row
    self.t = 0
end

function ClearAnimation:update(dt)
    self.t = self.t + dt
    return self.t >= LINECLEARTIME
end

function ClearAnimation:draw()
    love.graphics.setColor(LINECOLORS[(self.row+1)%2+1])
    local factor = self.t/LINECLEARTIME

    local hw = self.playfield.columns*0.5*BLOCKSCALE
    local bw = hw*(factor)

    local y = (self.row-1)*BLOCKSCALE

    love.graphics.rectangle("fill", hw-bw, y, bw, BLOCKSCALE) -- left
    love.graphics.rectangle("fill", hw, y, bw, BLOCKSCALE) -- right

    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle("fill", hw-bw-.5, y, 1, BLOCKSCALE)
    love.graphics.rectangle("fill", hw+bw-.5, y, 1, BLOCKSCALE)
end

return ClearAnimation
