function love.load()
    PROF_CAPTURE = true
    prof = require "lib.jprof.jprof"
    require "controls"

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
