local Block = CLASS("Block")

function Block:initialize(piece, shape, x, y, img, quadI)
    self.piece = piece
    self.shape = shape
    self.x = x
    self.y = y
    self.img = img
    self.quadI = quadI

    self.fixture = love.physics.newFixture(self.piece.body, self.shape)
    self.fixture:setFriction(PIECEFRICTION)
    self.subShapes = {}

    self:setMesh()

    for row = 1, self.piece.playfield.rows do
        self.subShapes[row] = {}
    end
end

function Block:draw()
    if not DEBUG_HIDEBLOCKS then
        love.graphics.push()

        love.graphics.translate(self.x*PHYSICSSCALE, self.y*PHYSICSSCALE)

        love.graphics.draw(self.mesh, 0, 0, 0, PHYSICSSCALE/BLOCKSCALE)

        love.graphics.pop()
    end
end

function Block:debugDraw()
    if DEBUG_DRAWSUBSHAPES then
        love.graphics.setColor(1, 0, 0)

        for row, subShape in ipairs(self.subShapes) do
            if #subShape > 0 then
                util.drawLinedPolygon(subShape)
            end
        end

        love.graphics.setColor(1, 1, 1)
    end

    if DEBUG_DRAWSUBSHAPEROWS then
        love.graphics.setColor(0, 1, 0)

        for row, subShape in ipairs(self.subShapes) do
            if #subShape > 0 then
                love.graphics.print(row, subShape[1], subShape[2])
            end
        end

        love.graphics.setColor(1, 1, 1)
    end


    if DEBUG_DRAWSHAPES then
        love.graphics.setColor(0, 0, 1)

        util.drawLinedPolygon({self.shape:getPoints()})

        love.graphics.setColor(1, 1, 1)
    end

    if DEBUG_DRAWSHAPEVERTICES then
        love.graphics.setColor(1, 0, 0)
        local points = {self.shape:getPoints()}
        love.graphics.print(#points/2, points[1], points[2])
        love.graphics.setColor(1, 1, 1)
    end
end

local meshPoints = {}
local shapePoints = {}
--- Updates the mesh used for drawing the block, based on the physical shape
function Block:setMesh()
    util.setPointTable(shapePoints, self.shape:getPoints())

    util.iclearTable(meshPoints)

    for i = 1, #shapePoints, 2 do
        local x = (shapePoints[i]/PHYSICSSCALE - self.x)
        local y = (shapePoints[i+1]/PHYSICSSCALE - self.y)

        table.insert(meshPoints, {
            x*BLOCKSCALE, y*BLOCKSCALE,
            x/3*8/10 + (self.quadI-1)/3 + 1/30, y*8/10 + 1/10
        })
    end

    self.mesh = love.graphics.newMesh(meshPoints)
    self.mesh:setTexture(self.img)
end

--- Main function for cutting out rows of a block (based on the cached subShapes)
function Block:cut(rows)
    -- remove condition: row being deleted
    local removed = false

    for _, row in ipairs(rows) do
        if #self.subShapes[row] > 0 then
            util.iclearTable(self.subShapes[row])
            removed = true
        end
    end

    if not removed then -- no need to do anything if no subshapes were removed in the cutting
        return
    end

    local shapes = {}

    for row, subShape in pairs(self.subShapes) do
        if #subShape > 0 then
            table.insert(shapes, subShape)
        end
    end

    if #shapes > 0 then
        shapes = util.combineShapes(shapes)

        -- remove condition: too small for box2d
        for i = #shapes, 1, -1 do
            local shape = shapes[i]

            if not util.largeEnough(shape) then
                -- print("A shape was removed for being too small")
                table.remove(shapes, i)
            end
        end
    end

    if #shapes > 0 then
        for i = 1, #shapes do
            -- limit vertices to 8 TODO: bad?
            while #shapes[i] > 16 do
                local shortest = math.huge
                local shortestI

                for pointI = 1, #shapes[i], 2 do
                    local compareI = pointI+2

                    if compareI > #shapes[i] then
                        compareI = 1
                    end

                    local dist = math.sqrt((shapes[i][pointI] - shapes[i][compareI])^2 + (shapes[i][pointI+1] - shapes[i][compareI+1])^2)

                    if dist < shortest then
                        shortest = dist
                        shortestI = pointI
                    end
                end

                table.remove(shapes[i], shortestI)
                table.remove(shapes[i], shortestI)
                print("Removed a vertex cuz too many")
            end
        end

        for i = #shapes, 2, -1 do
            if #shapes[i] >= 6 then
                local shape = love.physics.newPolygonShape(shapes[i])
                table.insert(self.piece.blocks, Block:new(self.piece, shape, self.x, self.y, self.img, self.quadI))

            else
                print("Prevented a crash during Block cutting creation.")
            end
        end

        if #shapes[1] >= 6 then
            self.fixture:destroy()
            self.shape = love.physics.newPolygonShape(shapes[1])
            self.fixture = love.physics.newFixture(self.piece.body, self.shape)
            self.fixture:setFriction(PIECEFRICTION)

            self:setMesh()
        else
            print("Prevented a crash during Block cutting creation. (2)")
        end
    else
        self.fixture:destroy()
        self.removeMe = true
    end
end

local rayTraceResults = {left={}, right={}}
local points = {}

--- Handles the entry of a single point into the subShape table
local function doPoint(block, previousRow, x, y, add, bottomY)
    local row

    if y == bottomY then -- prioritize above row for the bottom-most points
        row = math.ceil(y/PHYSICSSCALE)
    else
        row = block.piece.playfield:worldToRow(y)
    end

    if not block.subShapes[row] then
        block.subShapes[row] = {}
    end

    if not previousRow then
        previousRow = row
    end

    if row > previousRow then -- we just went into the next row
        -- add exit point to previous row
        table.insert(block.subShapes[previousRow], rayTraceResults.right[previousRow])
        table.insert(block.subShapes[previousRow], block.piece.playfield:rowToWorld(previousRow))

        -- add entry point to current row
        table.insert(block.subShapes[row], rayTraceResults.right[previousRow])
        table.insert(block.subShapes[row], block.piece.playfield:rowToWorld(previousRow))
    end

    if row < previousRow then -- we just went into the previous row
        -- add exit point to previous row
        table.insert(block.subShapes[previousRow], rayTraceResults.left[row])
        table.insert(block.subShapes[previousRow], block.piece.playfield:rowToWorld(row))

        -- add entry point to current row
        table.insert(block.subShapes[row], rayTraceResults.left[row])
        table.insert(block.subShapes[row], block.piece.playfield:rowToWorld(row))
    end

    if add then
        table.insert(block.subShapes[row], x)
        table.insert(block.subShapes[row], y)
    end

    return row
end

--- Divides a block into row-based sub shapes and stores those in block.subShapes
function Block:setSubShapes()
    -- doing all of this inline because I expect this to be performance-important code
    -- can be broken up later

    -- Get top and bottom most row that this block is in
    local topRow = math.huge
    local bottomRow = -math.huge

    local topY = math.huge
    local bottomY = -math.huge

    util.setPointTable(points, self.piece.body:getWorldPoints(self.shape:getPoints()))

    for i = 1, #points, 2 do
        local x, y = points[i], points[i+1]

        if x < 0 or x > self.piece.playfield.columns*PHYSICSSCALE then
            -- might crash
            -- print("block was outside playfield")
            return
        end

        topRow = math.min(topRow, math.floor(y/PHYSICSSCALE)+1)
        bottomRow = math.max(bottomRow, math.ceil(y/PHYSICSSCALE))

        topY = math.min(topY, y)
        bottomY = math.max(bottomY, y)
    end

    -- raytrace the points at which this block crosses lines
    util.iclearTable(rayTraceResults.left)
    util.iclearTable(rayTraceResults.right)

    for row = topRow, bottomRow-1 do
        -- FROM LEFT
        local x1 = 0
        local x2 = self.piece.playfield.columns*PHYSICSSCALE
        local y = self.piece.playfield:rowToWorld(row)

        local xn, yn, fraction = self.fixture:rayCast(x1, y, x2, y, 1)

        if not fraction then
            print(x1, y, x2, y)
            print(self.fixture:getPoints())
            print("fraction crash1")
        end

        local hitx = x2 * fraction

        rayTraceResults.left[row] = hitx

        -- FROM RIGHT
        local x1 = self.piece.playfield.columns*PHYSICSSCALE
        local x2 = 0

        local xn, yn, fraction = self.fixture:rayCast(x1, y, x2, y, 1)

        if not fraction then
            print(x1, y, x2, y)
            print(self.fixture:getPoints())
            print("fraction crash2")
        end

        local hitx = x1 * (1-fraction)

        rayTraceResults.right[row] = hitx
    end

    -- clear subshape table (saves memory?)
    for row, subShape in pairs(self.subShapes) do
        util.iclearTable(self.subShapes[row])
    end

    -- start assigning points to rows
    local previousRow = false
    for i = 1, #points, 2 do
        previousRow = doPoint(self, previousRow, points[i], points[i+1], true, bottomY)
    end

    doPoint(self, previousRow, points[1], points[2], false, bottomY) -- go back to first point for the adding of the additional points on the rows

    ---------------------------------------------------
    -- all shape calculations complete at this point --
    ---------------------------------------------------

    for row, subShape in pairs(self.subShapes) do
        if row > 0 and row <= self.piece.playfield.rows then -- ignore rows outside the playfield (todo: don't even calculate those?)
            if #subShape > 0 then -- had stuff entered into it
                for i = 1, #subShape, 2 do
                    -- make local
                    subShape[i], subShape[i+1] = self.piece.body:getLocalPoint(subShape[i], subShape[i+1])
                end

                self.piece.playfield:addArea(row, util.polygonArea(subShape))
            end
        end
    end
end

return Block
