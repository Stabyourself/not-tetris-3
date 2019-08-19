local Game = require "gamestates.Game"
local Game_versus = class("Game_versus", Game)
local Playfield = require "class.Playfield"
local NESRandomizer = require "class.NESRandomizer"

local tileImg = love.graphics.newImage("img/border_tiled.png")
tileImg:setWrap("repeat", "repeat")
local backgroundImg = love.graphics.newImage("img/background_versus.png")

function Game_versus:initialize()
    self.tileQuad = love.graphics.newQuad(8, 0, WIDTH, HEIGHT, 64, 64)
    Game.initialize(self)

    self.randomizer = NESRandomizer:new()

    table.insert(self.playfields, Playfield:new(self, 15, 38, 10.25, 20, controls[1], self.randomizer, false))
    table.insert(self.playfields, Playfield:new(self, 159, 38, 10.25, 20, controls[2], self.randomizer, true))

    self.playfields[1].areaIndicatorsX = (self.playfields[1].columns+1)*BLOCKSCALE+3

    self.playfields[1].areaIndicatorsY = 0
    self.playfields[1].areaIndicatorsWidth = -8

    self.playfields[1].nextPieceX = 89
    self.playfields[1].nextPieceY = -22

    self.playfields[2].areaIndicatorsX = -BLOCKSCALE-3
    self.playfields[2].areaIndicatorsY = 0
    self.playfields[2].areaIndicatorsWidth = 8

    self.playfields[2].nextPieceX = -7
    self.playfields[2].nextPieceY = -22
end

function Game_versus:draw()
    love.graphics.draw(tileImg, self.tileQuad)
    love.graphics.draw(backgroundImg)

    -- p1
    love.graphics.print(string.format("line-%03d", self.playfields[1].lines), 8, 8)
    love.graphics.print(string.format("level-%02d", self.playfields[1].level), 8, 16)
    love.graphics.print(string.format("p1-%06d", self.playfields[1].score), 12, 208)

    -- p2
    love.graphics.print(string.format("%03d-line", self.playfields[2].lines), 184, 8)
    love.graphics.print(string.format("%02d-level", self.playfields[2].level), 184, 16)
    love.graphics.print(string.format("%06d-p2", self.playfields[2].score), 172, 208)

    -- top
    -- love.graphics.printf("top-", 104, 200, 48, "center")
    -- love.graphics.print("010000", 104, 208)

    Game.draw(self)

    if self.showWinner then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("player " .. self.winner .. " wins!", 0, HEIGHT/2-4, WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
    end
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

function Game_versus:topOut(playfield)
    local otherPly
    if playfield == self.playfields[1] then
        otherPly = 2
    elseif playfield == self.playfields[2] then
        otherPly = 1
    end

    if not self.playfields[otherPly].dead then
        self.winner = otherPly

        Timer.setTimer(function()
            self.showWinner = true
            Timer.setTimer(function()
                gamestate = require("gamestates.menu"):new()
            end, 4)
        end, 2)
    end
end

return Game_versus
