local postDraw = class("postDraw")

function postDraw:draw()
    love.graphics.pop()

    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    love.graphics.print("fps: " .. love.timer.getFPS())
    love.graphics.pop()
end

return postDraw
