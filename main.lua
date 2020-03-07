xOffset = 0
yOffset = 0

gamestate = require "lib.gamestate"

function love.load()
    require "variables"

    if FIXEDRNG then
        love.math.setRandomSeed(1)
    end

    PROF_CAPTURE = false
    prof = require "lib.jprof.jprof"
    require "controls"
    controlsLoader.loadSP()

    love.graphics.setDefaultFilter("nearest", "nearest")


    class = require "lib.middleclass"
    frameDebug3 = require "class.FrameDebug3"
    require "lib.util"
    Timer = require "lib.Timer"
    local audioManager = require "lib.audioManager3"

    preDraw = require "gamestates.preDraw"
    postDraw = require "gamestates.postDraw"
    background = require("gamestates.background"):new()

    audioManager.load()

    love.graphics.setLineWidth(1/SCALE*BLOCKSCALE)
    love.physics.setMeter(METER)

    local font = love.graphics.newImageFont("img/font.png", "0123456789abcdefghijklmnopqrstuvwxyz.:/,\"C-_A* !{}?'()+=><#@")
    love.graphics.setFont(font)

    gamestate.switch(require("gamestates.game_A"):new())

    love.resize(love.graphics.getDimensions())
end

function love.resize(w, h)
    local maxScale = math.min(w/WIDTH, h/HEIGHT)

    local scale = math.floor(maxScale)

    SCALE = scale

    xOffset = math.ceil(((w-SCALE*WIDTH)/2)/SCALE)*SCALE
    yOffset = math.ceil(((h-SCALE*HEIGHT)/2)/SCALE)*SCALE

    background:resize(w, h)
end

function love.draw()
    background:draw()
    preDraw:draw()

    gamestate.current():draw()

    postDraw:draw()
end

function love.update(dt)
    prof.push("frame")
    prof.push("update")

    for _, control in ipairs(controls) do
        control:update()
    end

    dt = frameDebug3.update(dt)

    gamestate.current():update(dt)
    background:update(dt)

    Timer.managedUpdate(dt)

    prof.pop("update")

    for i = 1, #debugs do
        if controls[1]:pressed("debug" .. i) then
            _G[debugs[i]] = not _G[debugs[i]]
        end
    end

    if controls[1]:pressed("debug7") then
        gamestate.switch(require("gamestates.game_A"):new())
    end

    if controls[1]:pressed("debug8") then
        gamestate.switch(require("gamestates.game_versus"):new())
    end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
    end

    if key == "," then
        debug.debug()
    end

    if key == "#" then
        frameDebug3.frameAdvance()
    end

    if key == "pause" then
        frameDebug3.pausePlay()
    end
end

function love.quit()
    prof.write("lastrun.mpack")
end
