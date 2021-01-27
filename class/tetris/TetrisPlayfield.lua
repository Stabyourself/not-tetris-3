local _Playfield = require "class._Playfield"
local TetrisPlayfield = CLASS("TetrisPlayfield", _Playfield)
local audioManager = require "lib.audioManager3"

local Wall = require "class.Wall"
local Piece = require "class.tetris.Piece"
local ClearAnimation = require "class.tetris.ClearAnimation"
local pieceTypes = require "class.tetris.PieceType"
local NextPieceContainer = require "class.tetris.NextPieceContainer"
local FillGuideContainer = require "class.tetris.FillGuideContainer"


local blockQuads = {}

for i = 1, 3 do
    blockQuads[i] = love.graphics.newQuad((i-1)*10+1, 1, 8, 8, 30, 10)
end

function TetrisPlayfield:initialize(game, x, y, columns, rows, player, randomizer, mirrored, blockGraphicsPack, level)
    _Playfield.initialize(self)

    self.game = game
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows
    self.player = player
    self.randomizer = randomizer
    self.mirrored = mirrored
    self.blockGraphicsPack = blockGraphicsPack
    self.level = level or 0

    self.score = 0
    self.lines = 0
    self.pieceCount = 0

    self.queuedGarbage = 0

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(function() end, function() end, function() end, self.postSolve)

    self.walls = {}
    self.walls.left = Wall:new(self.world, 0, -WALLEXTEND*PHYSICSSCALE, 0, (self.rows+WALLEXTEND)*PHYSICSSCALE, WALLFRICTION) -- left
    self.walls.right = Wall:new(self.world, self.columns*PHYSICSSCALE, -WALLEXTEND*PHYSICSSCALE, 0, (self.rows+WALLEXTEND)*PHYSICSSCALE, WALLFRICTION) -- right
    self.walls.bottom = Wall:new(self.world, 0, self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION) -- floor

    self.walls.left.dontDrop = true
    self.walls.right.dontDrop = true

    self.worldUpdateBuffer = WORLDUPDATEINTERVAL
    self.linesUpdateBuffer = LINESUPDATEINTERVAL

    self.rowOverlay = true
    self.area = {}

    self.clearAnimations = {}
    self.paused = false
    self.pieceEnded = false

    self.fillGuideContainer = FillGuideContainer:new(self, -11, 0, 8)
    self.nextPieceContainer = NextPieceContainer:new(self, 0, 0)

    self.pieces = {}
    self:nextPiece(true)

    self.firstPieceWait = true
    TIMER.setTimer(function()
        self.firstPieceWait = false
        self.activePiece.body:setAwake(true)
    end, FIRSTPIECEWAITTIME)

    self:updateLines()
end

function TetrisPlayfield:update(dt)
    util.updateGroup(self.clearAnimations, dt)
    self.fillGuideContainer:update(dt)

    if self.paused then
        return
    end

    if self.player:pressed("down") then
        self.firstPieceWait = false
    end

    -- debug stuff
    if self.player._controls["debug6"] and self.player:pressed("debug6") then
        self.lines = self.lines + 10
        self.level = self.level + 1
    end

    if self.player._controls["debug9"] and self.player:pressed("debug9") then
        self:receiveGarbage(40)
    end

    self.worldUpdateBuffer = self.worldUpdateBuffer + dt
    self.linesUpdateBuffer = self.linesUpdateBuffer + dt

    -- world is updated in fixed steps to prevent fps-dependency (box2d behaves differently with different deltas, even if the total is the same)
    while self.worldUpdateBuffer >= WORLDUPDATEINTERVAL do
        if self.spawnNewPieceNextFrame then
            -- check if we have garbage to spawn
            self:nextPiece()
            self.spawnNewPieceNextFrame = false
        end

        -- Movement
        if self.activePiece then
            -- Rotation
            if self.player:down("rotate_left") then
                self.activePiece:rotate(-1)

                if self.player:pressed("rotate_left") then
                    audioManager.play("turn")
                end
            end

            if self.player:down("rotate_right") then
                self.activePiece:rotate(1)

                if self.player:pressed("rotate_right") then
                    audioManager.play("turn")
                end
            end

            -- Horizontal movement
            if self.player:down("left") then
                self.activePiece:move(-1)

                if self.player:pressed("left") then
                    audioManager.play("move")
                end
            end

            if self.player:down("right") then
                self.activePiece:move(1)

                if self.player:pressed("right") then
                    audioManager.play("move")
                end
            end

            -- vertical movement
            if not self.player:down("down") then
                self.activePiece:limitDownwardVelocity()
            end
        end

        self.world:update(WORLDUPDATEINTERVAL)

        if self.pieceEnded then
            self:checkClearRow()
            self.pieceEnded = false
        end

        if self.linesUpdateBuffer > LINESUPDATEINTERVAL then
            self:updateLines()

            -- modulu because we don't care if this is skipped due to high dt; we only care about the latest state
            self.linesUpdateBuffer = self.linesUpdateBuffer%LINESUPDATEINTERVAL
        end

        self.worldUpdateBuffer = self.worldUpdateBuffer - WORLDUPDATEINTERVAL
    end
end

function TetrisPlayfield:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- next
    self.nextPieceContainer:draw()

    -- fullness
    self.fillGuideContainer:draw()

    -- overlay
    if self.rowOverlay then
        love.graphics.setColor(LINECOLORS[2])

        for row = 2+math.fmod(self.rows, 1), self.rows, 2 do
            love.graphics.rectangle("fill", 0, (row-1)*BLOCKSCALE, self.columns*BLOCKSCALE, BLOCKSCALE)
        end

        love.graphics.setColor(1, 1, 1)
    end

    local x1, y1 = game.camera:cameraCoords(self.x, self.y)
    local x2, y2 = game.camera:cameraCoords(self.x + self.columns*BLOCKSCALE, self.y + self.rows*BLOCKSCALE)

    local x = math.ceil(x1)
    local y = math.ceil(y1)
    local w = math.ceil(x2-x1)
    local h = math.ceil(y2-y1)

    love.graphics.setScissor(x, y, w, h)

    for _, v in ipairs(self.pieces) do
        v:draw()
    end

    -- line clear animation
    for _, clearAnimation in ipairs(self.clearAnimations) do
        clearAnimation:draw()
    end

    if DEBUG_DRAWLINEAREA then
        for row = 1, self.rows do
            local factor = self.area[row]/(math.floor(self.columns)*BLOCKSIZE)
            love.graphics.print(string.format("%.2f", factor*100), 0, (row-1)*BLOCKSCALE, 0, 0.5)
        end
    end

    if DEBUG_PRINTQUEUEDGARBAGE then
        love.graphics.print(self.queuedGarbage)
    end

    love.graphics.pop()
    love.graphics.setScissor()
end

function TetrisPlayfield:worldToRow(y)
    return math.floor(y/PHYSICSSCALE)+1
end

function TetrisPlayfield:rowToWorld(y)
    return y*PHYSICSSCALE
end

function TetrisPlayfield:getBlockGraphic()
    return self.blockGraphicsPack:getGraphic(self.level)
end

function TetrisPlayfield:getMaxSpeedY()
    local speed = MAXSPEEDYBASE + MAXSPEEDYPERLEVEL*self.level

    if self.firstPieceWait then
        speed = -4.2 -- don't ask me why
    end

    return speed
end

function TetrisPlayfield:addArea(row, area)
    if row > 0 and row <= self.rows then
        self.area[row] = self.area[row] + area
    end
end

function TetrisPlayfield:updateLines()
    for row = 1, self.rows do
        self.area[row] = 0
    end

    for _, piece in ipairs(self.pieces) do
        -- if piece ~= self.activePiece then -- don't include the active piece?
            for _, block in ipairs(piece.blocks) do
                block:setSubShapes()
            end
        -- end
    end

    -- update fillGuides
    for row = 1, self.rows do
        local mul = 0.9 -- maximum width without being a clear (there's a jump to show clearing lines)

        if self.area[row]/(math.floor(self.columns)*BLOCKSIZE) >= LINECLEARREQUIREMENT then
            mul = 1
        end

        self.fillGuideContainer.fillGuides[row]:smoothSet(math.min(1, self.area[row]/(math.floor(self.columns)*BLOCKSIZE*LINECLEARREQUIREMENT))*mul)
    end

end

function TetrisPlayfield:nextPiece(first)
    self.pieceCount = self.pieceCount + 1
    local pieceNum = self.randomizer:getPiece(self.pieceCount, self.mirrored)
    local piece = Piece.fromPieceType(self, pieceTypes[pieceNum])

    if first then
        piece.body:setY(PHYSICSSCALE)
    end

    self.activePiece = piece

    table.insert(self.pieces, piece)

    -- update NEXT
    self.nextPieceContainer.pieceType = pieceTypes[self.randomizer:getPiece(self.pieceCount+1, self.mirrored)]
end

function TetrisPlayfield:gameOver()
    self.dead = true
    self.activePiece = false
    self.walls.bottom.body:destroy()
    if self.game.topOut then
        self.game:topOut(self)
    end
end

function TetrisPlayfield.postSolve(a, b)
    local aObject = a:getBody():getUserData()
    local bObject = b:getBody():getUserData()
    local otherObject

    local piece = false

    if aObject and aObject:isInstanceOf(Piece) and aObject == aObject.playfield.activePiece then
        piece = aObject
        otherObject = bObject
    end

    if bObject and bObject:isInstanceOf(Piece) and bObject == bObject.playfield.activePiece then
        piece = bObject
        otherObject = aObject
    end

    if piece and not otherObject.dontDrop then
        local self = piece.playfield

        -- some velocity check here maybe

        if piece.body:getY() < PIECESTARTY+1 then
            self:gameOver()
            return
        end

        self.activePiece = false
        self.pieceEnded = true
    end
end

function TetrisPlayfield:addPiece(piece)
    table.insert(self.pieces, piece)
end

function TetrisPlayfield:changeLevel(level)
    self.level = level
end

local garbageShapes1 = {}
for i = 0, 2 do
    garbageShapes1[i+1] = {
        shape={
            -PHYSICSSCALE, -PHYSICSSCALE/2,
            0, -PHYSICSSCALE/2,
            0, PHYSICSSCALE/2,
            -PHYSICSSCALE, PHYSICSSCALE/2
        },
        x=-1,
        y=-.5,
        quadI = i+1,
    }
end
local garbageShapes2 = {}
for i = 0, 2 do
    garbageShapes2[i+1] = {
        shape={
            0, -PHYSICSSCALE/2,
            PHYSICSSCALE, -PHYSICSSCALE/2,
            PHYSICSSCALE, PHYSICSSCALE/2,
            0, PHYSICSSCALE/2
        },
        x=0,
        y=-.5,
        quadI = i+1,
    }
end

function TetrisPlayfield:spawnGarbage(count)
    for garbageNum = 1, count do
        local y = math.ceil(garbageNum/4)
        local x = garbageNum%4+1

        local px = ((self.columns-1)/4)*PHYSICSSCALE*x-0.5*PHYSICSSCALE
        local py = -y*PHYSICSSCALE*2

        local shape1 = garbageShapes1[love.math.random(#garbageShapes1)]
        local shape2 = garbageShapes2[love.math.random(#garbageShapes2)]

        shape1.img = self:getBlockGraphic()
        shape2.img = self:getBlockGraphic()

        local piece = Piece.fromShapes(self, {shape1, shape2})
        self:addPiece(piece)

        piece.body:setPosition(px, py)
        piece.body:setAngularVelocity((love.math.random()*2-1)*10)
    end
end

function TetrisPlayfield:clearRow(rows)
    self.paused = true
    for _, row in ipairs(rows) do
        table.insert(self.clearAnimations, ClearAnimation:new(self, row))
        self.fillGuideContainer.fillGuides[row]:smoothSet(0)
    end

    TIMER.setTimer(function()
        for i = #self.pieces, 1, -1 do
            self.pieces[i]:cut(rows)
        end
        self.paused = false
        self:updateLines()
        self:checkGarbageSpawn()
    end, LINECLEARTIME)
end

function TetrisPlayfield:checkClearRow()
    self:updateLines()
    local toClear = {}
    local totalFactor = 0

    for row = 1, self.rows do
        local factor = self.area[row]/(math.floor(self.columns)*BLOCKSIZE)

        if factor >= LINECLEARREQUIREMENT then
            table.insert(toClear, row)
            totalFactor = totalFactor + factor
        end
    end

    if #toClear > 0 then
        -- add lines
        local oldLines = self.lines
        self.lines = self.lines + #toClear

        -- check level
        if math.floor(self.lines/10) > math.floor(oldLines/10) then
            local toLevel = math.floor(self.lines/10)

            if toLevel > self.level then
                self:changeLevel(toLevel)
            end
        end

        -- add score
        local clearRatio = totalFactor/#toClear
        local BASE = 200
        local LINES_BASE = -0.4
        local LINES_DIVISOR = 1.8
        local level = self.level
        local LEVEL_BASE = 1
        local LEVEL_DIVISOR = 0.62

        local toAdd = clearRatio*(BASE*(LINES_BASE+#toClear/LINES_DIVISOR))*((level+LEVEL_BASE)/LEVEL_DIVISOR)

        self.score = self.score + toAdd

        -- send garbage?
        local toSend = GARBAGETABLE[math.min(#GARBAGETABLE, #toClear)]

        if toSend > 0 then
            self:sendGarbage(toSend)
        end

        if #toClear >= 4 then
            game.background:flashStuff()
            audioManager.play("tetris")
        else
            audioManager.play("clear")
        end

        self:clearRow(toClear)
    else
        audioManager.play("place")
        self:checkGarbageSpawn()
    end
end

return TetrisPlayfield
