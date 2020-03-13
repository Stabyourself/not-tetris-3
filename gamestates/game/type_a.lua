local _game = require "gamestates.game._game"
local game_a = CLASS("game_a", _game)
local Playfield = require "class.tetris.Playfield"
local NESRandomizer = require "class.tetris.randomizers.NESRandomizer"
local blockGraphicPacks = require "blockGraphicsPackLoader"

local backgroundImg = love.graphics.newImage("img/type_a.png")

function game_a:enter(previous, level)
    _game.enter(self)

    CONTROLSLOADER.loadSP()

    self.randomizer = NESRandomizer:new()
    table.insert(self.playfields, Playfield:new(self, 95, 41, 10.25, 20, CONTROLS[1], self.randomizer, true, blockGraphicPacks.NES, level))
    self.playfields[1].areaIndicatorsX = -11

    self.playfields[1].areaIndicatorsY = 0
    self.playfields[1].areaIndicatorsWidth = 8

    self.playfields[1].nextPieceX = 113
    self.playfields[1].nextPieceY = 79

    self.gameOver = false
end

function game_a:update(dt)
    _game.update(self, dt)

    if self.gameOver then
        if CONTROLS[1]:pressed("start") then
            GAMESTATE.switch(require("gamestates.menu.levelSelect"):new())
        end
    end
end

function game_a:draw()
    love.graphics.draw(backgroundImg)

    love.graphics.print(string.format("lines-%03d", self.playfields[1].lines), 104, 16)

    love.graphics.print(string.format("top\n%06d", 10000), 192, 24)
    love.graphics.print(string.format("score\n%06d", self.playfields[1].score), 192, 48)

    love.graphics.print(string.format("level\n  %02d", self.playfields[1].level), 192, 152)

    _game.draw(self)
end

function game_a:topOut()
    TIMER.setTimer(function() self.gameOver = true end, 3)
end

return game_a
