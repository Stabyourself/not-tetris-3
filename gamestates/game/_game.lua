local game = CLASS("Game")

function game:enter()
    self.playfields = {}
end

function game:update(dt)
    util.updateGroup(self.playfields, dt)
end

function game:draw()
    for _, playfield in ipairs(self.playfields) do
        playfield:draw()
    end
end

function game:sendGarbage(toPly, count) end

return game
