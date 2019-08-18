local Game = require "gamestates.Game"
local Game_a = class("Game_a", Game)
local Playfield = require "class.Playfield"

local backgroundImg = love.graphics.newImage("img/background.png")

function Game_a:initialize()
    Game.initialize(self)

    table.insert(self.playfields, Playfield:new(95, 41, 10.25, 20))
end

function Game_a:draw()
    love.graphics.draw(backgroundImg)

    Game.draw(self)
end

return Game_a
