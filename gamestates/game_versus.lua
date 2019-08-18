local Game = require "gamestates.Game"
local Game_versus = class("Game_versus", Game)
local Playfield = require "class.Playfield"

local backgroundImg = love.graphics.newImage("img/background_versus.png")

function Game_versus:initialize()
    Game.initialize(self)

    table.insert(self.playfields, Playfield:new(self, 15, 41, 10.25, 20, controls[1]))
    table.insert(self.playfields, Playfield:new(self, 159, 41, 10.25, 20, controls[2]))

    self.playfields[1].areaIndicatorsX = (self.playfields[1].columns+1)*PIECESCALE
    self.playfields[1].areaIndicatorsY = 0
    self.playfields[1].areaIndicatorsWidth = -8

    self.playfields[2].areaIndicatorsX = -PIECESCALE
    self.playfields[2].areaIndicatorsY = 0
    self.playfields[2].areaIndicatorsWidth = 8
end

function Game_versus:draw()
    love.graphics.draw(backgroundImg)

    -- p1
    love.graphics.print(string.format("line-%03d", self.playfields[1].lines), 8, 8)
    love.graphics.print(string.format("level-%02d", self.playfields[1].level), 8, 16)
    love.graphics.print(string.format("p1-%06d", self.playfields[1].score), 12, 208)

    -- p2
    love.graphics.print(string.format("line-%03d", self.playfields[2].lines), 184, 8)
    love.graphics.print(string.format("level-%02d", self.playfields[2].level), 184, 16)
    love.graphics.print(string.format("%06d-p2", self.playfields[2].score), 172, 208)

    -- top
    love.graphics.print("top-", 112, 200)
    love.graphics.print("010000", 104, 208)

    Game.draw(self)
end

function Game_versus:sendGarbage(fromPlayfield, count)
    local toPly
    if fromPlayfield == self.playfields[1] then
        toPly = 2
    elseif fromPlayfield == self.playfields[2] then
        toPly = 1
    end

    self.playfields[toPly]:receiveGarbage(count)
end

return Game_versus
