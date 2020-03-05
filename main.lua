xOffset = 0
yOffset = 0

local tileImg
local tileImgFlashing
local flashFrame = false

function love.load()
    require "variables"
    PROF_CAPTURE = true
    prof = require "lib.jprof.jprof"
    require "controls"

    love.graphics.setDefaultFilter("nearest", "nearest")

    frameDebug3 = require "class.FrameDebug3"
    require "util"
    class = require "middleclass"
    Timer = require "lib.Timer"
    local Menu = require "gamestates.menu"
    local Game_a = require "gamestates.game_A"

    love.graphics.setLineWidth(1/SCALE*BLOCKSCALE)
    love.physics.setMeter(METER)

    local font = love.graphics.newImageFont("img/font.png", "0123456789abcdefghijklmnopqrstuvwxyz.:/,\"C-_A* !{}?'()+=><#@")
    love.graphics.setFont(font)

    tileImg = love.graphics.newImage("img/border_tiled.png")
    tileImg:setWrap("repeat", "repeat")
    tileImgFlashing = love.graphics.newImage("img/border_tiled_flashing.png")
    tileImgFlashing:setWrap("repeat", "repeat")

    gamestate = require("gamestates.game_A"):new()
    -- gamestate = require("gamestates.menu"):new()
    -- gamestate = require("gamestates.game_versus"):new()
    love.resize( love.graphics.getDimensions())
end

function love.resize( w, h )
    local maxScale = math.min(w/WIDTH, h/HEIGHT)

    local scale = math.floor(maxScale)


    SCALE = scale

    xOffset = math.ceil(((w-SCALE*WIDTH)/2)/SCALE)*SCALE
    yOffset = math.ceil(((h-SCALE*HEIGHT)/2)/SCALE)*SCALE

    tileQuad = love.graphics.newQuad(8, 0, w, h, 64, 64)
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

    if flashTimer and flashTimer:getTimeLeft() > 0 then
        flashFrame = not flashFrame
    end

    for i = 1, #debugs do
        if controls[1]:pressed("debug" .. i) then
            _G[debugs[i]] = not _G[debugs[i]]
        end
    end
end

function love.draw()
    prof.push("draw")

    local xMov = math.floor(xOffset%(8*SCALE))
    local yMov = math.floor(yOffset%(8*SCALE))

    if flashFrame then
        love.graphics.draw(tileImgFlashing, tileQuad, 0, 0, 0, SCALE)
    else
        love.graphics.draw(tileImg, tileQuad, xMov, yMov, 0, SCALE)
    end

    love.graphics.push()
    love.graphics.translate(xOffset, yOffset)
    love.graphics.scale(SCALE, SCALE)

    gamestate:draw()

    love.graphics.pop()

    love.graphics.push()
    love.graphics.scale(SCALE, SCALE)

    love.graphics.print("fps: " .. love.timer.getFPS())
    love.graphics.pop()

	prof.pop("draw")

	prof.pop("frame")
end

function flashStuff()
    flashTimer = Timer.setTimer(function() flashFrame = false end, 0.5)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end

function love.quit()
    prof.write("lastrun.mpack")
end
