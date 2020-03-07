local postDraw = class("postDraw")

function postDraw:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    love.graphics.print("fps: " .. love.timer.getFPS())
    love.graphics.pop()
	prof.pop("draw")
	prof.pop("frame")
end

return postDraw
