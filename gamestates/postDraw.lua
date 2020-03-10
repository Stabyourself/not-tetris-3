local postDraw = CLASS("postDraw")

function postDraw:draw()
    game.camera:detach()

    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    love.graphics.print("fps: " .. love.timer.getFPS())
    love.graphics.pop()
end

return postDraw
