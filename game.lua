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

    if DEBUGDRAW then
        love.graphics.setColor(1, 0, 0)
        for _, well in ipairs(game.wells) do
            for _, piece in ipairs(well.pieces) do
                love.graphics.push()
                love.graphics.scale(1/PHYSICSSCALE*8, 1/PHYSICSSCALE*8)
                love.graphics.translate(piece.body:getPosition())
                love.graphics.rotate(piece.body:getAngle())
                love.graphics.translate(-0.5, -0.5)

                for _, fixture in ipairs(piece.body:getFixtures()) do -- this is good code, I promise
                    love.graphics.polygon("line", fixture:getShape():getPoints())
                end

                love.graphics.pop()
            end
        end
        love.graphics.setColor(1, 1, 1)
    end
end

function game.keypressed()

end

return game
