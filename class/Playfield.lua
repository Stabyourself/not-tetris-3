local Playfield = class("Playfield")

local Wall = require "class.Wall"
local pieceTypes = require "class.PieceType"
local Piece = require "class.Piece"
local ClearAnimation = require "class.ClearAnimation"

function Playfield:initialize(game, x, y, columns, rows)
    self.game = game
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows

    self.score = 0
    self.level = 0
    self.lines = 0

    self.queuedGarbage = 0

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(function() end, function() end, function() end, self.postSolve)

    self.walls = {}
    table.insert(self.walls, Wall:new(self.world, 0, -WALLEXTEND*PHYSICSSCALE, 0, (self.rows+WALLEXTEND)*PHYSICSSCALE, WALLFRICTION)) -- left
    table.insert(self.walls, Wall:new(self.world, self.columns*PHYSICSSCALE, -WALLEXTEND*PHYSICSSCALE, 0, (self.rows+WALLEXTEND)*PHYSICSSCALE, WALLFRICTION)) -- right
    table.insert(self.walls, Wall:new(self.world, 0, self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION)) -- floor

    self.walls[1].dontDrop = true
    self.walls[2].dontDrop = true

    self.worldUpdateBuffer = WORLDUPDATEINTERVAL
    self.linesUpdateBuffer = LINESUPDATEINTERVAL

    self.rowOverlay = true
    self.area = {}

    self.clearAnimations = {}
    self.paused = false
    self.pieceEnded = false

    self.pieces = {}
    self:nextPiece()
end

function Playfield:update(dt)
    -- world is updated in fixed steps to prevent fps-dependency (box2d behaves differently with different deltas, even if the total is the same)

    updateGroup(self.clearAnimations, dt)

    if not self.paused then
        self.worldUpdateBuffer = self.worldUpdateBuffer + dt
        self.linesUpdateBuffer = self.linesUpdateBuffer + dt

        while self.worldUpdateBuffer >= WORLDUPDATEINTERVAL do
            if self.spawnNewPieceNextFrame then
                -- check if we have garbage to spawn
                self:nextPiece()
                self.spawnNewPieceNextFrame = false
            end

            if self.activePiece then
                self.activePiece:movement(WORLDUPDATEINTERVAL)
            end

            self.world:update(WORLDUPDATEINTERVAL)

            if self.pieceEnded then
                self:checkClearRow()
                self.pieceEnded = false
            end

            if self.linesUpdateBuffer > LINESUPDATEINTERVAL then
                self:updateLines()
                self.linesUpdateBuffer = self.linesUpdateBuffer - LINESUPDATEINTERVAL
            end

            self.worldUpdateBuffer = self.worldUpdateBuffer - WORLDUPDATEINTERVAL
        end
    end
end

function Playfield:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)


    -- fullness
    for row = 1, self.rows do
        local x = self.areaIndicatorsX
        local y = self.areaIndicatorsY + (row-1)*PIECESCALE

        local factor = self.area[row]/(math.floor(self.columns)*BLOCKSIZE)

        love.graphics.rectangle("fill", x, y, factor*self.areaIndicatorsWidth, PIECESCALE)
    end

    -- overlay
    if self.rowOverlay then
        love.graphics.setColor(LINECOLORS[2])

        for row = 2+math.fmod(self.rows, 1), self.rows, 2 do
            love.graphics.rectangle("fill", 0, (row-1)*PIECESCALE, self.columns*PIECESCALE, PIECESCALE)
        end

        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.setScissor(self.x*SCALE, self.y*SCALE, self.columns*PIECESCALE*SCALE, self.rows*PIECESCALE*SCALE)

    prof.push("pieces")
    for _, v in ipairs(self.pieces) do
        v:draw()
    end
    prof.pop("pieces")

    -- line clear animation
    for _, clearAnimation in ipairs(self.clearAnimations) do
        clearAnimation:draw()
    end

    if DEBUG_DRAWLINEAREA then
        for row = 1, self.rows do
            local factor = self.area[row]/(math.floor(self.columns)*BLOCKSIZE)
            love.graphics.print(string.format("%.2f", factor*100), 0, (row-1)*PIECESCALE, 0, 0.5)
        end
    end

    if DEBUG_PRINTQUEUEDGARBAGE then
        love.graphics.print(self.queuedGarbage)
    end

    love.graphics.pop()
    love.graphics.setScissor()
end

function Playfield:worldToRow(y)
    return math.floor(y/PHYSICSSCALE)+1
end

function Playfield:rowToWorld(y)
    return y*PHYSICSSCALE
end

function Playfield:addArea(row, area)
    if row > 0 and row <= self.rows then
        self.area[row] = self.area[row] + area
    end
end

function Playfield:updateLines()
    prof.push("updateLines")
    for row = 1, self.rows do
        self.area[row] = 0
    end

    for _, piece in ipairs(self.pieces) do
        if piece ~= self.activePiece then -- don't include the active piece?
            for _, block in ipairs(piece.blocks) do
                block:setSubShapes()
            end
        end
    end
    prof.pop("updateLines")
end

function Playfield:nextPiece()
    local pieceNum = love.math.random(1, #pieceTypes)
    local piece = Piece.fromPieceType(self, pieceTypes[pieceNum])

    self.activePiece = piece

    table.insert(self.pieces, piece)
end

function Playfield:gameOver()
    self.activePiece = nil
    self.walls[3].body:destroy()
end

function Playfield.postSolve(a, b)
    local aObject = a:getBody():getUserData()
    local bObject = b:getBody():getUserData()

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
        self = piece.playfield

        -- some velocity check here maybe

        if piece.body:getY() < PIECESTARTY+1 then
            self:gameOver()
            return
        end

        self.activePiece = false
        self.pieceEnded = true
    end
end

function Playfield:addPiece(piece)
    table.insert(self.pieces, piece)
end

function Playfield:changeLevel(level)
    self.level = level
end

function Playfield:sendGarbage(count)
    if self.queuedGarbage < count then
        count = count - self.queuedGarbage
        self.queuedGarbage = 0
    else
        self.queuedGarbage = self.queuedGarbage - count
        count = 0
    end

    if count > 0 then
        self.game:sendGarbage(self, count)
    end
end

function Playfield:receiveGarbage(count)
    self.queuedGarbage = self.queuedGarbage + count
end

function Playfield:checkGarbageSpawn()
    if self.queuedGarbage > 0 then -- oh no
        local garbageWaitTime = GARBAGEWAITTIME + GARBAGEWAITTIMEPERROW * self.queuedGarbage

        self:spawnGarbage(self.queuedGarbage)
        self.queuedGarbage = 0
        self.pieceSpawnTimer = 0

        Timer.setTimer(function() self.spawnNewPieceNextFrame = true end, garbageWaitTime)
    else
        self.spawnNewPieceNextFrame = true
    end
end

local garbageShapes = {}
for i = 0, 2 do
    garbageShapes[i+1] = {
        shape=GARBAGESHAPE.shape,
        x=GARBAGESHAPE.x,
        y=GARBAGESHAPE.y,
        quad = love.graphics.newQuad(i*10+1, 1, 8, 8, 30, 10)
    }
end

function Playfield:spawnGarbage(count)
    for y = 1, count do
        for i = 1, GARBAGECOUNT do
            local px = love.math.random()*((self.columns-1)*PHYSICSSCALE)+PHYSICSSCALE/2
            local py = -y*PHYSICSSCALE*1.5

            local piece = Piece.fromShapes(self, {garbageShapes[love.math.random(#garbageShapes)]})
            self:addPiece(piece)

            piece.body:setPosition(px, py)
            piece.body:setAngularVelocity((love.math.random()*2-1)*20)
        end
    end
end

function Playfield:clearRow(rows)
    self.paused = true
    for _, row in ipairs(rows) do
        table.insert(self.clearAnimations, ClearAnimation:new(self, row))
    end

    Timer.setTimer(function()
        for i = #self.pieces, 1, -1 do
            self.pieces[i]:cut(rows)
        end
        self.paused = false
        self:checkGarbageSpawn()
    end, LINECLEARTIME)
end

function Playfield:checkClearRow()
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
            self:changeLevel(math.floor(self.lines/10))
        end

        -- add score
        local clearRatio = totalFactor/#toClear
        local BASE = 200
        local LINES_BASE = -0.4
        local LINES_DIVISOR = 1.8
        local LEVEL_BASE = 1
        local LEVEL_DIVISOR = 0.62

        local toAdd = clearRatio*(BASE*(LINES_BASE+#toClear/LINES_DIVISOR))*((self.level+LEVEL_BASE)/LEVEL_DIVISOR)

        self.score = self.score + toAdd

        -- send garbage?
        local toSend = GARBAGETABLE[math.min(#GARBAGETABLE, #toClear)]

        if toSend > 0 then
            self:sendGarbage(toSend)
        end

        self:clearRow(toClear)
    else
        self:checkGarbageSpawn()
    end
end

function Playfield:keypressed(key, unicode)

end

return Playfield
