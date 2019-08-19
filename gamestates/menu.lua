local Menu = class("Menu")

local logo = love.graphics.newImage("img/logo.png")

local unreadyTime = 10

function Menu:initialize()
    self.ready = {false, false}
    self.unreadyTimer = {0, 0}
end

function Menu:update(dt)
    for i = 1, 2 do
        if self.ready[i] then
            self.unreadyTimer[i] = self.unreadyTimer[i] + dt

            if self.unreadyTimer[i] >= unreadyTime then
                self.ready[i] = false
            end
        end

        if controls[i]:pressed("action1") or controls[i]:pressed("action2") or controls[i]:pressed("start") then
            self.ready[i] = true
            self.unreadyTimer[i] = 0

            if i == 1 and self.ready[2] or i == 2 and self.ready[1] then
                self:startGame()
            end
        end
    end
end

function Menu:draw()
    love.graphics.draw(logo, (WIDTH-logo:getWidth()*2/3)/2, 8, 0, 2/3)
    love.graphics.printf(
[[this is an alpha version
of the game.


let us know what you think!


press start on both players]], 0, 80, WIDTH, "center")

    -- players ready
    for i = 1, 2 do
        local text = "waiting for player"

        if self.ready[i] then
            text = "player " .. i .. " ready!"
        end

        local x = WIDTH/4

        if i == 2 then
            x = x*3
        end

        love.graphics.printf(text, x-WIDTH/6, 180, WIDTH/3, "center")
    end
end

function Menu:startGame()
    gamestate = require("gamestates.game_versus"):new()
end

return Menu
