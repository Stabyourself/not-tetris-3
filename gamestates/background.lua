local background = class("background")

local tileImg = love.graphics.newImage("img/border_tiled.png")
tileImg:setWrap("repeat", "repeat")
local tileImgFlashing = love.graphics.newImage("img/border_tiled_flashing.png")
tileImgFlashing:setWrap("repeat", "repeat")

function background:draw()
    local img = tileImg

    if flashBackground then
        img = tileImgFlashing
    end

    love.graphics.draw(img, self.tileQuad, 0, 0, 0, SCALE)
end

function background:update(dt)
    if self.flashTimer and self.flashTimer:getTimeLeft() > 0 then
        local flashCycle = self.flashTimer:getTimeLeft()%(flashOnTime+flashOffTime)

        if flashCycle < flashOnTime then
            flashBackground = true
        else
            flashBackground = false
        end
    end
end

function background:flashStuff()
    self.flashTimer = Timer.setTimer(function() flashBackground = false end, LINECLEARTIME)
end

function background:resize(w, h)
    self.tileQuad = love.graphics.newQuad(-xOffset/SCALE, -yOffset/SCALE, w, h, 64, 64)
end

return background
