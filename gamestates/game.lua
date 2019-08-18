local Game = class("Game")

function Game:initialize()
    self.playfields = {}
end

function Game:update(dt)
    updateGroup(self.playfields, dt)
end

function Game:draw()
    for _, playfield in ipairs(self.playfields) do
        playfield:draw()
    end

    love.graphics.print(love.timer.getFPS())
end

function Game:keypressed(key, unicode)
    for _, playfield in ipairs(self.playfields) do
        playfield:keypressed(key, unicode)
    end
end

function Game:sendGarbage(toPly, count)
end

return Game
