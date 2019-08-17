function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    frameDebug3 = require "class.FrameDebug3"
    require "variables"
    require "util"
    class = require "middleclass"
    local game = require "game"

    love.graphics.setLineWidth(1/SCALE*PIECESCALE)
    love.physics.setMeter(METER)

    backgroundImg = love.graphics.newImage("img/background.png")

    game.load()
end

function love.update(dt)
    dt = frameDebug3.update(dt)

    gamestate.update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    gamestate.draw()

    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "," then
        debug.debug()
    end

    gamestate.keypressed(key)
end

function normalizeAngle(a)
	a = math.fmod(a+math.pi, math.pi*2)-math.pi
    a = math.fmod(a-math.pi, math.pi*2)+math.pi

    return a
end