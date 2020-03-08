local game = require "gamestates.game"
local game_a = class("game_a", game)
local Playfield = require "class.tetris.Playfield"
local NESRandomizer = require "class.tetris.randomizers.NESRandomizer"
local blockGraphicPacks = require "blockGraphicsPackLoader"

local backgroundImg = love.graphics.newImage("img/background.png")

function game_a:enter()
    self.randomizer = NESRandomizer:new()

    game.init(self)

    controlsLoader.loadSP()
    table.insert(self.playfields, Playfield:new(self, 95, 41, 10.25, 20, controls[1], self.randomizer, true, blockGraphicPacks.NES))
    self.playfields[1].areaIndicatorsX = -10

    self.playfields[1].areaIndicatorsY = 0
    self.playfields[1].areaIndicatorsWidth = 8

    self.playfields[1].nextPieceX = 113
    self.playfields[1].nextPieceY = 79
end

function game_a:draw()
    love.graphics.draw(backgroundImg)

    love.graphics.print(string.format("lines-%03d", self.playfields[1].lines), 104, 16)
    love.graphics.print(string.format("level\n  %02d", self.playfields[1].level), 192, 152)
    love.graphics.print(string.format("score\n%06d", self.playfields[1].score), 192, 48)

    game.draw(self)
end

return game_a
