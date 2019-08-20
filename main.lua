xOffset = 0
yOffset = 0

function love.load()
    require "variables"
    autoScale()
    PROF_CAPTURE = false
    prof = require "lib.jprof.jprof"
    require "controls"

    love.graphics.setDefaultFilter("nearest", "nearest")

    frameDebug3 = require "class.FrameDebug3"
    require "util"
    class = require "middleclass"
    Timer = require "lib.Timer"
    local Menu = require "gamestates.menu"
    local Game_a = require "gamestates.game_a"

    love.graphics.setLineWidth(1/SCALE*BLOCKSCALE)
    love.physics.setMeter(METER)

    local font = love.graphics.newImageFont("img/font.png", "0123456789abcdefghijklmnopqrstuvwxyz.:/,\"C-_A* !{}?'()+=><#@")
    love.graphics.setFont(font)

    gamestate = require("gamestates.menu"):new()
    -- gamestate = require("gamestates.game_versus"):new()
end

function autoScale()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local maxScale = math.min(width/WIDTH, height/HEIGHT)

    local scale = math.floor(maxScale)


    SCALE = scale

    xOffset = (scale*WIDTH-width)/2+width/2
    yOffset = 100
end

function love.update(dt)
    prof.push("frame")
    prof.push("update")

    for i = 1, 2 do
        controls[i]:update()
    end

    dt = frameDebug3.update(dt)

    gamestate:update(dt)
    Timer.managedUpdate(dt)

    prof.pop("update")
end

function love.draw()
    prof.push("draw")

    love.graphics.push()
    love.graphics.translate(xOffset, yOffset)
    love.graphics.scale(SCALE, SCALE)

    gamestate:draw()

    love.graphics.pop()

	prof.pop("draw")

	prof.pop("frame")
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

    if key == "," then
        debug.debug()
    end

    if key == "1" then
        gamestate:sendGarbage(gamestate.playfields[1], 1)
    end
end

function love.quit()
    prof.write("lastrun.mpack")
end
