local postDraw = CLASS("postDraw")

function postDraw:initialize(camera)
    self.camera = camera
end

function postDraw:draw()
    self.camera:detach()

    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    love.graphics.print("fps: " .. love.timer.getFPS())
    love.graphics.pop()
end

return postDraw
