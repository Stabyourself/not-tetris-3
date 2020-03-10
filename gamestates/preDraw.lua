local preDraw = CLASS("preDraw")

function preDraw:initialize(camera)
    self.camera = camera
end

function preDraw:draw()
    self.camera:attach()
end

return preDraw
