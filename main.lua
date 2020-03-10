local preDraw
local postDraw
local background
local camera

function love.load()
    -- general setup
    require "variables"

    if FIXEDRNG then
        love.math.setRandomSeed(2)
    end

    love.graphics.setDefaultFilter("nearest", "nearest")

    love.graphics.setLineWidth(1)

    love.physics.setMeter(METER)

    local font = love.graphics.newImageFont("img/font.png", [[0123456789abcdefghijklmnopqrstuvwxyz.:/,"C-_A* !{}?'()+=><#@]])
    love.graphics.setFont(font)


    -- loading libs
    require "lib.util"
    GAMESTATE = require "lib.gamestate"
    CLASS = require "lib.middleclass"
    FRAMEDEBUG3 = require "lib.FrameDebug3"
    TIMER = require "lib.Timer"

    local audioManager = require "lib.audioManager3"
    audioManager.load()

    require "controls"
    CONTROLSLOADER.loadSP()

    -- creating gamestate stuff
    camera = require("lib.camera")() -- is this good code?

    preDraw = require("gamestates.preDraw"):new(camera) -- is this? I honestly don't know lmao
    postDraw = require("gamestates.postDraw"):new(camera)
    background = require("gamestates.background"):new(camera)
    BACKGROUND = background -- this'll have to do for now.

    -- let everything adjust to the window before we start
    love.resize(love.graphics.getDimensions())

    -- aight cool let's go
    GAMESTATE.switch(require("gamestates.game.type_a"):new())
end

function love.resize(w, h)
    local maxScale = math.min(w/WIDTH, h/HEIGHT)
    local scale = math.floor(maxScale)

    camera:zoomTo(scale)
    camera:lookAt(WIDTH/2, HEIGHT/2)

    background:resize(w, h)
end

function love.draw()
    background:draw()
    preDraw:draw()

    GAMESTATE.current():draw()

    postDraw:draw()
end

function love.update(dt)
    dt = FRAMEDEBUG3.update(dt)

    for _, control in ipairs(CONTROLS) do
        control:update()
    end

    TIMER.managedUpdate(dt)
    GAMESTATE.current():update(dt)
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
        FRAMEDEBUG3.frameAdvance()
    end

    if key == "pause" then
        FRAMEDEBUG3.pausePlay()
    end
end
