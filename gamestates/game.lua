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

    love.graphics.print("fps: " .. love.timer.getFPS())
end

function Game:sendGarbage(toPly, count)
end

return Game
