local _Playfield = require "class._Playfield"
local Puyo = require "class.puyo.Puyo"
local PuyoGroup = require "class.puyo.PuyoGroup"
local audioManager = require "lib.audioManager3"
local NextPieceContainer = require "class.puyo.NextPieceContainer"

local Wall = require "class.Wall"

local PuyoPlayfield = CLASS("PuyoPlayfield", _Playfield)

function PuyoPlayfield:initialize(game, x, y, columns, rows, player, randomizer)
    self.game = game
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows
    self.player = player
    self.randomizer = randomizer

    self.queuedGarbage = 0

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(function() end, function() end, function() end, self.postSolve)

    self.walls = {}
    self.walls.left = Wall:new(self.world, 0, -WALLEXTEND*PHYSICSSCALE, 0, (self.rows+WALLEXTEND)*PHYSICSSCALE, WALLFRICTION) -- left
    self.walls.right = Wall:new(self.world, self.columns*PHYSICSSCALE, -WALLEXTEND*PHYSICSSCALE, 0, (self.rows+WALLEXTEND)*PHYSICSSCALE, WALLFRICTION) -- right
    self.walls.bottom = Wall:new(self.world, 0, self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION) -- floor

    self.walls.left.dontDrop = true
    self.walls.right.dontDrop = true

    self.paused = false
    self.puyoEnded = false

    self.worldUpdateBuffer = WORLDUPDATEINTERVAL
    self.puyoGroupUpdateBuffer = 0

    self.puyos = {}
    self.puyoGroups = {}

    self.pieceCount = 0

    self.nextPieceContainer = NextPieceContainer:new(self, 0, 0)

    self:nextPuyo()
end

function PuyoPlayfield:update(dt)
    self.worldUpdateBuffer = self.worldUpdateBuffer + dt
    self.puyoGroupUpdateBuffer = self.puyoGroupUpdateBuffer + dt

    -- world is updated in fixed steps to prevent fps-dependency (box2d behaves differently with different deltas, even if the total is the same)
    while self.worldUpdateBuffer >= WORLDUPDATEINTERVAL do
        -- Movement
        if self.activePuyoGroup then
            -- Rotation
            if self.player:down("rotate_left") then
                for _, puyo in ipairs(self.activePuyoGroup.puyos) do
                    puyo:rotate(-1)
                end

                if self.player:pressed("rotate_left") then
                    audioManager.play("turn")
                end
            end

            if self.player:down("rotate_right") then
                for _, puyo in ipairs(self.activePuyoGroup.puyos) do
                    puyo:rotate(1)
                end

                if self.player:pressed("rotate_right") then
                    audioManager.play("turn")
                end
            end

            -- Horizontal movement
            if self.player:down("left") then
                for _, puyo in ipairs(self.activePuyoGroup.puyos) do
                    puyo:move(-1)
                end

                if self.player:pressed("left") then
                    audioManager.play("move")
                end
            end

            if self.player:down("right") then
                for _, puyo in ipairs(self.activePuyoGroup.puyos) do
                    puyo:move(1)
                end

                if self.player:pressed("right") then
                    audioManager.play("move")
                end
            end

            -- vertical movement
            if not self.player:down("down") then
                for _, puyo in ipairs(self.activePuyoGroup.puyos) do
                    puyo:limitDownwardVelocity()
                end
            end
        end

        self.world:update(WORLDUPDATEINTERVAL)

        self.worldUpdateBuffer = self.worldUpdateBuffer - WORLDUPDATEINTERVAL

        if self.puyoGroupUpdateBuffer > PUYOGROUPUPDATEINTERVAL then
            self:updatePuyoGroups()

            self.puyoGroupUpdateBuffer = self.puyoGroupUpdateBuffer%PUYOGROUPUPDATEINTERVAL
        end
    end

    if self.puyoEnded then
        self.puyoEnded = false

        self.activePuyoGroup:split()
        self.activePuyoGroup = false

        self:checkClearPuyos()
    end
end

function PuyoPlayfield:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    self.nextPieceContainer:draw()

    local x1, y1 = game.camera:cameraCoords(self.x, self.y)
    local x2, y2 = game.camera:cameraCoords(self.x + self.columns*BLOCKSCALE, self.y + self.rows*BLOCKSCALE)

    local x = math.ceil(x1)
    local y = math.ceil(y1)
    local w = math.ceil(x2-x1)
    local h = math.ceil(y2-y1)

    love.graphics.setScissor(x, y, w, h)

    love.graphics.scale(1/PHYSICSSCALE*BLOCKSCALE, 1/PHYSICSSCALE*BLOCKSCALE)

    for _, v in ipairs(self.puyos) do
        v:draw()
    end

    love.graphics.pop()
    love.graphics.setScissor()
end

function PuyoPlayfield:updatePuyoGroups()
    local colorGroups = {}

    for i = 1, #PUYOCOLORS do
        colorGroups[i] = {}
    end

    for _, puyo in ipairs(self.puyos) do
        -- clear closeness
        puyo.neighbouringPuyos = {}

        -- make groups
        table.insert(colorGroups[puyo.type],
            {
                puyo=puyo,
                recursed=false,
            }
        )
    end

    local groups = {}

    for _, colorGroup in ipairs(colorGroups) do
        -- work through puyos until we have no puyos :(
        for j = 1, #colorGroup do
            if not colorGroup[j].recursed then
                -- make a new group
                local group = {}

                local function recursiveGrouping(puyo)
                    table.insert(group, puyo)

                    -- check for close puyos
                    for i = 1, #colorGroup do
                        if i ~= j then
                            local otherPuyo = colorGroup[i].puyo

                            local x1, y1 = puyo.body:getWorldPoint(puyo.fixture:getShape():getPoint())
                            local x2, y2 = otherPuyo.body:getWorldPoint(otherPuyo.fixture:getShape():getPoint())

                            local distance = util.distance(x1, y1, x2, y2)

                            if distance <= PUYODISTANCE then
                                -- enter into some closeness cache for puyo
                                puyo:insertNeighbour(otherPuyo, distance)
                                otherPuyo:insertNeighbour(puyo, distance)

                                if not colorGroup[i].recursed then
                                    -- throw close puyo into our group
                                    colorGroup[i].recursed = true
                                    recursiveGrouping(otherPuyo)
                                end
                            end
                        end
                    end
                end

                colorGroup[j].recursed = true
                recursiveGrouping(colorGroup[j].puyo)

                -- add group to groups if more than 1 member
                if #group > 1 then
                    table.insert(groups, group)
                end
            end
        end
    end

    self.puyoGroups = groups
end

function PuyoPlayfield:gameOver()
    self.dead = true
    self.activePuyoGroup = false
    self.walls.bottom.body:destroy()
    if self.game.topOut then
        self.game:topOut(self)
    end
end

function PuyoPlayfield.postSolve(a, b)
    local aObject = a:getBody():getUserData()
    local bObject = b:getBody():getUserData()
    local otherObject

    local puyo = false

    if aObject and aObject:isInstanceOf(Puyo) and aObject.playfield.activePuyoGroup and table.includesI(aObject.playfield.activePuyoGroup.puyos, aObject) then
        puyo = aObject
        otherObject = bObject
    end

    if bObject and bObject:isInstanceOf(Puyo) and bObject.playfield.activePuyoGroup and table.includesI(bObject.playfield.activePuyoGroup.puyos, bObject) then
        puyo = bObject
        otherObject = aObject
    end

    if puyo and not otherObject.dontDrop and not table.includesI(puyo.playfield.activePuyoGroup.puyos, otherObject) then
        local self = puyo.playfield

        -- some velocity check here maybe

        if puyo.body:getY() < PIECESTARTY+1 then
            self:gameOver()
            return
        end

        self.puyoEnded = true
    end
end

function PuyoPlayfield:checkClearPuyos()
    local puyosDestroyed = false

    self:updatePuyoGroups()

    for _, group in ipairs(self.puyoGroups) do
        if #group >= 4 then
            for _, puyo in ipairs(group) do
                puyo:destroy()
            end

            puyosDestroyed = true
        end
    end

    if puyosDestroyed then
        util.updateGroup(self.puyos)
        TIMER.setTimer(function() self:checkClearPuyos() end, PUYOCHAINTIME)
    else
        self:nextPuyo()
    end
end

function PuyoPlayfield:nextPuyo()
    self.pieceCount = self.pieceCount + 1
    self.activePuyoGroup = PuyoGroup:new(self,
        self.randomizer:getPiece(self.pieceCount)
    )
    for _, puyo in ipairs(self.activePuyoGroup.puyos) do
        table.insert(self.puyos, puyo)
    end

    self.nextPieceContainer.group = self.randomizer:getPiece(self.pieceCount+1)
end

function PuyoPlayfield:getMaxSpeedY()
    return 100
end

return PuyoPlayfield
