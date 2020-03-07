local preDraw = class("preDraw")

function preDraw:draw()
    prof.push("draw")
    love.graphics.push()
    love.graphics.translate(xOffset, yOffset)
    love.graphics.scale(SCALE, SCALE)
end

return preDraw