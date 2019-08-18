local Game = require "gamestates.Game"
local Game_versus = class("Game_versus", Game)
local Playfield = require "class.Playfield"

local backgroundImg = love.graphics.newImage("img/background_versus.png")

function Game_versus:initialize()
    Game.initialize(self)

    table.insert(self.playfields, Playfield:new(15, 41, 10.25, 20))
    table.insert(self.playfields, Playfield:new(159, 41, 10.25, 20))
end

function Game_versus:draw()
    love.graphics.draw(backgroundImg)

    -- p1
    love.graphics.print("line-000", 8, 8)
    love.graphics.print("level-00", 8, 16)
    love.graphics.print("p1-000000", 8, 208)

    -- p2
    love.graphics.print("line-000", 184, 8)
    love.graphics.print("level-02", 184, 16)
    love.graphics.print("000000-p2", 176, 208)

    -- top
    love.graphics.print("top-", 112, 200)
    love.graphics.print("010000", 104, 208)

    Game.draw(self)
end

return Game_versus
