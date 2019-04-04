local game = {}
local Well

function game.load()
    Well = require "class.Well"
    gamestate = game

    game.wells = {}
    table.insert(game.wells, Well:new(95/8, 41/8, 10.25, 20))
end

function game.update(dt)
    updateGroup(game.wells, dt)
end

function game.draw()
    for _, well in ipairs(game.wells) do
        well:draw()
    end

    love.graphics.print(love.timer.getFPS())
end

function game.keypressed()

end

return game
