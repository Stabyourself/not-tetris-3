local game = class("Game")

function game:init()
    self.playfields = {}
end

function game:update(dt)
    updateGroup(self.playfields, dt)
end

function game:draw()
    for _, playfield in ipairs(self.playfields) do
        playfield:draw()
    end
end

function game:sendGarbage(toPly, count) end

return game
