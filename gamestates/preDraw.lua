local preDraw = CLASS("preDraw")

function preDraw:draw()
    game.camera:attach()
end

return preDraw
