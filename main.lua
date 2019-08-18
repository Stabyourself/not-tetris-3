function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    frameDebug3 = require "class.FrameDebug3"
    require "variables"
    require "util"
    class = require "middleclass"
    Timer = require "class.Timer"
    local Game_a = require "gamestates.game_a"
    local Game_versus = require "gamestates.game_versus"

    love.graphics.setLineWidth(1/SCALE*PIECESCALE)
    love.physics.setMeter(METER)

    local font = love.graphics.newImageFont("img/font.png", "0123456789abcdefghijklmnopqrstuvwxyz.:/,\"C-_A* !{}?'()+=><#")
    love.graphics.setFont(font)

    gamestate = Game_versus:new()
end

function love.update(dt)
    dt = frameDebug3.update(dt)

    gamestate:update(dt)
    Timer.managedUpdate(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    gamestate:draw()

    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "," then
        debug.debug()
    end

    gamestate:keypressed(key)
end

function normalizeAngle(a)
	a = math.fmod(a+math.pi, math.pi*2)-math.pi
    a = math.fmod(a-math.pi, math.pi*2)+math.pi

    return a
end