local preDraw
local postDraw
local background

function love.load()
    -- general setup
    game = {} -- container of evil globals
    require "variables"

    love.graphics.setDefaultFilter("nearest", "nearest")

    love.graphics.setLineWidth(4)

    love.physics.setMeter(METER)

    local font = love.graphics.newImageFont("img/font.png", [[0123456789abcdefghijklmnopqrstuvwxyz.:/,"C-_A* !{}?'()+=><#@]])
    love.graphics.setFont(font)


    -- loading libs
    util = require "lib.util"
    GAMESTATE = require "lib.gamestate"
    CLASS = require "lib.middleclass"
    FRAMEDEBUG3 = require "lib.FrameDebug3"
    TIMER = require "lib.Timer"

    local audioManager = require "lib.audioManager3"
    audioManager.load()

    require "controls"
    CONTROLSLOADER.loadSP()

    -- creating gamestate stuff
    game.camera = require("lib.camera")() -- is this good code?

    preDraw = require("gamestates.preDraw"):new() -- is this? I honestly don't know lmao
    postDraw = require("gamestates.postDraw"):new()
    background = require("gamestates.background"):new()
    game.background = background

    -- let everything adjust to the window before we start
    love.resize(love.graphics.getDimensions())

    -- aight cool let's go
    local intro = require("gamestates.intro.intro"):new(WIDTH, HEIGHT, 1)

    intro.onFinish = function()
        game.background.active = true
        GAMESTATE.switch(require("gamestates.menu.levelSelect"):new())
    end

    -- GAMESTATE.switch(intro)

    GAMESTATE.switch(require("gamestates.game.type_a"):new())
end

function love.resize(w, h)
    local maxScale = math.min(w/WIDTH, h/HEIGHT)
    game.scale = math.floor(maxScale)

    game.camera:zoomTo(game.scale)
    game.camera:lookAt(WIDTH/2, HEIGHT/2)

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

function love.keypressed(key, scancode)
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

    if GAMESTATE.current().keypressed then
        GAMESTATE.current():keypressed(key, scancode)
    end
end

function love.batonpressed(player, button)
    if GAMESTATE.current().batonpressed then
        GAMESTATE.current():batonpressed(player, button)
    end
end
