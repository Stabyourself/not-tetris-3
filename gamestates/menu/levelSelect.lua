local levelSelect = CLASS("levelSelect")

local levelSelectBackground = love.graphics.newImage("img/level_select.png")
local levelGrid = love.graphics.newImage("img/level_grid.png")

function levelSelect:initialize()
    self.level = 0
    self.crazyFlashyTimer = 0
end

function levelSelect:update(dt)
    if CONTROLS[1]:pressed("left") and self.level > 0 then
        self.level = self.level - 1
    end

    if CONTROLS[1]:pressed("right") and self.level < 9 then
        self.level = self.level + 1
    end

    if CONTROLS[1]:pressed("down") and self.level < 5 then
        self.level = self.level + 5
    end

    if CONTROLS[1]:pressed("up") and self.level > 4 then
        self.level = self.level - 5
    end

    if CONTROLS[1]:pressed("start") then
        self:startGame()
    end

    self.crazyFlashyTimer = self.crazyFlashyTimer + dt
end

local function getLevelOffset(level)
    return level%5 * 16, math.floor(level/5)*16
end

function levelSelect:draw()
    love.graphics.draw(levelSelectBackground)

    if self.crazyFlashyTimer%(CRAZYFLASHYTIMERON+CRAZYFLASHYTIMEROFF) > CRAZYFLASHYTIMEROFF then
        love.graphics.setColor(COLORS.levelSelectActive)

        local xOff, yOff = getLevelOffset(self.level)
        love.graphics.rectangle("fill", 52+xOff, 76+yOff, 16, 16)
    end

    love.graphics.setColor(COLORS.levelNumbers)
    for i = 0, 9 do
        local xOff, yOff = getLevelOffset(i)

        local num = i
        if CONTROLS[1]:down("rotate_right") then
            num = num + 10
        end
        love.graphics.printf(num, 52+xOff, 80+yOff, 16, "center")
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(levelGrid, 51, 74)
end

function levelSelect:startGame()
    local level = self.level
    if CONTROLS[1]:down("rotate_right") then
        level = level + 10
    end

    GAMESTATE.switch(require("gamestates.game.type_a"):new(), level)
end

return levelSelect
