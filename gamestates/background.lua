local background = CLASS("background")

local tileImg = love.graphics.newImage("img/border_tiled.png")
tileImg:setWrap("repeat", "repeat")
local tileImgFlashing = love.graphics.newImage("img/border_tiled_flashing.png")
tileImgFlashing:setWrap("repeat", "repeat")

function background:initialize()
    self.active = true
    self.flash = false
end

function background:draw()
    if not self.active then
        return
    end

    local img = tileImg

    if self.flashTimer and self.flashTimer:getTimeLeft() > 0 then
        local flashCycle = self.flashTimer:getTimeLeft()%(FLASHTIMEON+FLASHTIMEOFF)

        if flashCycle < FLASHTIMEON then
            img = tileImgFlashing
        end
    end

    love.graphics.draw(img, self.tileQuad, 0, 0, 0, game.camera.scale)
end

function background:flashStuff()
    self.flashTimer = TIMER.setTimer(function() self.flash = false end, LINECLEARTIME)
end

function background:resize(w, h)
    local x, y = game.camera:worldCoords(0, 0)
    self.tileQuad = love.graphics.newQuad(x, y, w, h, 64, 64)
end

return background
