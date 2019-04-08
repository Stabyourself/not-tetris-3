local Playfield = class("Playfield")

local game = require "game"
local Wall = require "class.Wall"
local pieceTypes = require "class.pieceType"
local Piece = require "class.Piece"

function Playfield:initialize(x, y, columns, rows)
    self.x = x
    self.y = y
    self.columns = columns
    self.rows = rows

    self.lineCoverage = {}

    self.world = love.physics.newWorld(0, GRAVITY)
    self.world:setCallbacks(self.beginContact)

    self.walls = {}
    table.insert(self.walls, Wall:new(self.world, 0, -5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- left
    table.insert(self.walls, Wall:new(self.world, self.columns*PHYSICSSCALE, -5*PHYSICSSCALE, 0, (self.rows+5)*PHYSICSSCALE, WALLFRICTION)) -- right
    table.insert(self.walls, Wall:new(self.world, 0, self.rows*PHYSICSSCALE, self.columns*PHYSICSSCALE, 0, FLOORFRICTION)) -- floor

    self.walls[1].dontDrop = true
    self.walls[2].dontDrop = true

    self.worldUpdateBuffer = 0

    self.rowOverlay = true

    self.pieces = {}
    self:nextPiece()
end

function Playfield:update(dt)
    if self.spawnNewPieceNextFrame then
        self:nextPiece()
        self.spawnNewPieceNextFrame = false
    end

    -- world is updated in fixed steps to prevent fps-dependency (box2d behaves differently with different deltas, even if the total is the same)
    self.worldUpdateBuffer = self.worldUpdateBuffer + dt

    while self.worldUpdateBuffer >= WORLDUPDATEINTERVAL do
        if self.activePiece then
            self.activePiece:movement(WORLDUPDATEINTERVAL)
        end

        self.world:update(WORLDUPDATEINTERVAL)
        self.worldUpdateBuffer = self.worldUpdateBuffer - WORLDUPDATEINTERVAL
    end

    self:updateLines()
end

function Playfield:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- overlay
    if self.rowOverlay then
        love.graphics.setColor(1, 1, 1, 0.2)

        for i = 2+math.fmod(self.rows, 1), self.rows, 2 do
            love.graphics.rectangle("fill", 0, (i-1)*PIECESCALE, self.columns*PIECESCALE, PIECESCALE)
        end

        love.graphics.setColor(1, 1, 1)
    end

    for _, v in ipairs(self.pieces) do
        v:draw()
    end

    if DRAWME then
        love.graphics.push()
        love.graphics.scale(1/PHYSICSSCALE*PIECESCALE, 1/PHYSICSSCALE*PIECESCALE)
        love.graphics.setColor(0, 1, 0)
        for _, v in ipairs(DRAWME) do
            for _, points in pairs(v) do
                love.graphics.line(points)
                love.graphics.line(points[#points-1], points[#points], points[1], points[2])
            end
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
    end

    if DEBUGDRAW then
        love.graphics.setColor(1, 0, 0)
        for _, piece in ipairs(self.pieces) do
            love.graphics.push()
            love.graphics.scale(1/PHYSICSSCALE*PIECESCALE, 1/PHYSICSSCALE*PIECESCALE)
            love.graphics.translate(piece.body:getPosition())
            love.graphics.rotate(piece.body:getAngle())

            for _, fixture in ipairs(piece.body:getFixtures()) do -- this is good code, I promise
                love.graphics.polygon("line", fixture:getShape():getPoints())
            end

            love.graphics.pop()
        end
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.pop()
end

function Playfield:worldToRow(y)
    return math.ceil(y/PHYSICSSCALE)
end

function Playfield:rowToWorld(y)
    return y*PHYSICSSCALE
end

function Playfield:updateLines()
    DRAWME = {}
    for i = 1, self.rows do
        self.lineCoverage[i] = 0
    end

    for _, piece in ipairs(self.pieces) do
        for _, block in ipairs(piece.blocks) do
            -- doing all of this inline because I expect this to be performance-important code
            -- can be broken up later

            -- Get top and bottom most row that this block is in
            local topRow = math.huge
            local bottomRow = -1
            local points = {piece.body:getWorldPoints(block.shape:getPoints())}

            for i = 1, #points, 2 do
                local x, y = points[i], points[i+1]

                topRow = math.min(topRow, self:worldToRow(y))
                bottomRow = math.max(bottomRow, self:worldToRow(y))
            end

            -- raytrace the points at which this block crosses lines
            local rayTraceResults = {left={}, right={}}

            for row = topRow, bottomRow-1 do
                -- FROM LEFT
                local x1 = 0
                local x2 = self.columns*PHYSICSSCALE
                local y1 = self:rowToWorld(row)
                local y2 = self:rowToWorld(row)

                local xn, yn, fraction = block.fixture:rayCast(x1, y1, x2, y2, 1)

                local hitx = x1 + (x2 - x1) * fraction
                -- local hity = y1 + (y2 - y1) * fraction

                rayTraceResults.left[row] = hitx

                -- FROM RIGHT
                local x1 = self.columns*PHYSICSSCALE
                local x2 = 0

                local xn, yn, fraction = block.fixture:rayCast(x1, y1, x2, y2, 1)

                local hitx = x1 + (x2 - x1) * fraction
                -- local hity = y1 + (y2 - y1) * fraction

                rayTraceResults.right[row] = hitx
            end

            local subShapes = {}
            local previousRow = false

            local function doPoint(x, y, add)
                local row = self:worldToRow(y)

                if not subShapes[row] then
                    subShapes[row] = {}
                end

                if not previousRow then
                    previousRow = row
                end

                if row > previousRow then -- we just went into the next row
                    -- add exit point to previous row
                    table.insert(subShapes[previousRow], rayTraceResults.right[previousRow])
                    table.insert(subShapes[previousRow], self:rowToWorld(previousRow))

                    -- add entry point to current row
                    table.insert(subShapes[row], rayTraceResults.right[previousRow])
                    table.insert(subShapes[row], self:rowToWorld(previousRow))
                end

                if row < previousRow then -- we just went into the previous row
                    -- add exit point to previous row
                    table.insert(subShapes[previousRow], rayTraceResults.left[row])
                    table.insert(subShapes[previousRow], self:rowToWorld(row))

                    -- add entry point to current row
                    table.insert(subShapes[row], rayTraceResults.left[row])
                    table.insert(subShapes[row], self:rowToWorld(row))
                end

                if add then
                    table.insert(subShapes[row], x)
                    table.insert(subShapes[row], y)
                end

                previousRow = row
            end

            for i = 1, #points, 2 do
                local x, y = points[i], points[i+1]

                doPoint(x, y, true)
            end

            doPoint(points[1], points[2], false) -- go back to first point for the adding of the additional points on the rows

            table.insert(DRAWME, subShapes)
        end
    end
end

function Playfield:nextPiece()
    local pieceNum = love.math.random(1, #pieceTypes)
    local piece = Piece:new(self, pieceTypes[pieceNum])

    self.activePiece = piece

    table.insert(self.pieces, piece)
end

function Playfield:gameOver()
    self.activePiece = nil
end

function Playfield.beginContact(a, b)
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

        if piece.body:getY() < 0 then
            self:gameOver()
            return
        end

        self.spawnNewPieceNextFrame = true
    end
end

return Playfield
