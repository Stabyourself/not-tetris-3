local game = {}
local Playfield

function game.load()
    Playfield = require "class.Playfield"
    gamestate = game

    game.playfields = {}
    table.insert(game.playfields, Playfield:new(95, 41, 10.25, 20))
end

function game.update(dt)
    updateGroup(game.playfields, dt)
end

function game.draw()
    love.graphics.draw(backgroundImg)

    for _, playfield in ipairs(game.playfields) do
        playfield:draw()
    end

    love.graphics.print(love.timer.getFPS())
end

function game.keypressed()

end

return game
