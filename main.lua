xOffset = 0
yOffset = 0

gamestate = require "lib.gamestate"
class = require "lib.middleclass"
frameDebug3 = require "lib.FrameDebug3"
Timer = require "lib.Timer"

function love.load()
    require "variables"

    if FIXEDRNG then
        love.math.setRandomSeed(1)
    end

    love.graphics.setDefaultFilter("nearest", "nearest")



    require "lib.util"


    local audioManager = require "lib.audioManager3"
    audioManager.load()

    require "controls"
    controlsLoader.loadSP()


    love.graphics.setLineWidth(1/SCALE*BLOCKSCALE)
    love.physics.setMeter(METER)

    preDraw = require("gamestates.preDraw"):new()
    postDraw = require("gamestates.postDraw"):new()
    background = require("gamestates.background"):new()

    local font = love.graphics.newImageFont("img/font.png", [[0123456789abcdefghijklmnopqrstuvwxyz.:/,"C-_A* !{}?'()+=><#@]])
    love.graphics.setFont(font)

    love.resize(love.graphics.getDimensions())


    gamestate.switch(require("gamestates.game.type_a"):new())
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
    dt = frameDebug3.update(dt)

    for _, control in ipairs(controls) do
        control:update()
    end

    Timer.managedUpdate(dt)
    background:update(dt)
    gamestate.current():update(dt)
end

function love.keypressed(key)
    -- just debug stuff!
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
