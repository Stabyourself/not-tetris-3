local Game = require "gamestates.Game"
local Game_a = class("Game_a", Game)
local Playfield = require "class.Playfield"
local NESRandomizer = require "class.randomizers.NESRandomizer"
local blockGraphicPacks = require "blockGraphicsPackLoader"

local backgroundImg = love.graphics.newImage("img/background.png")

function Game_a:initialize()
    self.randomizer = NESRandomizer:new()

    Game.initialize(self)

    table.insert(self.playfields, Playfield:new(self, 95, 41, 10.25, 20, controls[1], self.randomizer, true, blockGraphicPacks.NES))
    self.playfields[1].areaIndicatorsX = -10

    self.playfields[1].areaIndicatorsY = 0
    self.playfields[1].areaIndicatorsWidth = 8

    self.playfields[1].nextPieceX = 113
    self.playfields[1].nextPieceY = 79
end

function Game_a:draw()
    love.graphics.draw(backgroundImg)

    love.graphics.print(string.format("lines-%03d", self.playfields[1].lines), 104, 16)
    love.graphics.print(string.format("level\n  %02d", self.playfields[1].level), 192, 152)
    love.graphics.print(string.format("score\n%06d", self.playfields[1].score), 192, 48)

    Game.draw(self)
end

return Game_a
