local Block = class("Block")

local img = love.graphics.newImage("img/tiles/0.png")

function Block:initialize(piece, shape, x, y, quad)
    self.piece = piece
    self.shape = shape
    self.x = x
    self.y = y
    self.quad = quad

    self.fixture = love.physics.newFixture(self.piece.body, self.shape)
    self.fixture:setFriction(PIECEFRICTION)
end

local shape
local function blockStencil()
    love.graphics.polygon("fill", shape:getPoints())
end

function Block:draw()
    love.graphics.push()
    if not DEBUG_HIDEBLOCKS then
        shape = self.shape
        love.graphics.stencil(blockStencil, "replace", 1)
        love.graphics.setStencilTest("greater", 0)

        love.graphics.translate(self.x*PHYSICSSCALE, self.y*PHYSICSSCALE)

        love.graphics.draw(img, self.quad, 0, 0, 0, PHYSICSSCALE/PIECESCALE)

        love.graphics.setStencilTest()
        love.graphics.pop()
    end

    self:debugDraw()
end

function Block:debugDraw()
    if DEBUG_DRAWSUBSHAPES then
        for _, subShape in ipairs(self.subShapes) do
            if subShape.row%2 == 1 then
                love.graphics.setColor(1, 0, 0)
            else
                love.graphics.setColor(0, 1, 0)
            end

            drawLinedPolygon(subShape.shape)
        end
    end

    if DEBUG_DRAWSHAPES then
        love.graphics.setColor(0, 0, 1)

        drawLinedPolygon({self.shape:getPoints()})

        love.graphics.setColor(1, 1, 1)
    end

    if DEBUG_DRAWSUBSHAPEUPDATETIME then
        for _, subShape in ipairs(self.subShapes) do
            local t = string.format("%.3f", love.timer.getTime() - subShape.timeUpdated)

            love.graphics.print(t, subShape.shape[1], subShape.shape[2])
        end
    end

    if DEBUG_DRAWSUBSHAPEROW then
        for _, subShape in ipairs(self.subShapes) do
            love.graphics.print(subShape.row, subShape.shape[1], subShape.shape[2])
        end
    end

    if DEBUG_DRAWSHAPEVERTICES then
        love.graphics.setColor(1, 0, 0)
        local points = {self.shape:getPoints()}
        love.graphics.print(#points/2, points[1], points[2])
        love.graphics.setColor(1, 1, 1)
    end
end

function Block:cut(rows)
    -- remove condition: row being deleted
    local removed = false
    for i = #self.subShapes, 1, -1 do
        local subShape = self.subShapes[i]

        if inTable(rows, subShape.row) then
            table.remove(self.subShapes, i)
            removed = true
        end
    end

    if not removed then -- no need to do anything if no subshapes were removed in the cutting
        return
    end

    local shapes = {}
    for _, subShape in ipairs(self.subShapes) do
        table.insert(shapes, {unpack(subShape.shape)})
    end

    if #shapes > 0 then
        shapes = combineShapes(shapes)

        -- remove condition: too small for box2d
        for i = #shapes, 1, -1 do
            local shape = shapes[i]

            if not largeenough(shape) then
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
            end
        end

        for i = #shapes, 2, -1 do
            local shape = love.physics.newPolygonShape(shapes[i])
            table.insert(self.piece.blocks, Block:new(self.piece, shape, self.x, self.y, self.quad))
        end

        self.fixture:destroy()
        self.shape = love.physics.newPolygonShape(shapes[1])
        self.fixture = love.physics.newFixture(self.piece.body, self.shape)
        self.fixture:setFriction(PIECEFRICTION)
    else
        self.fixture:destroy()
        self.removeMe = true
    end
end

function Block:setSubShapes()
    -- doing all of this inline because I expect this to be performance-important code
    -- can be broken up later

    -- Get top and bottom most row that this block is in
    local topRow = math.huge
    local bottomRow = -math.huge

    local topY = math.huge
    local bottomY = -math.huge

    local points = {self.piece.body:getWorldPoints(self.shape:getPoints())}

    for i = 1, #points, 2 do
        local x, y = points[i], points[i+1]

        if x < 0 or x > self.piece.playfield.columns*PHYSICSSCALE then
            -- might crash
            return
        end

        topRow = math.min(topRow, math.floor(y/PHYSICSSCALE)+1)
        bottomRow = math.max(bottomRow, math.ceil(y/PHYSICSSCALE))

        topY = math.min(topY, y)
        bottomY = math.max(bottomY, y)
    end

    -- raytrace the points at which this block crosses lines
    local rayTraceResults = {left={}, right={}}

    for row = topRow, bottomRow-1 do
        -- FROM LEFT
        local x1 = 0
        local x2 = self.piece.playfield.columns*PHYSICSSCALE
        local y = self.piece.playfield:rowToWorld(row)

        local xn, yn, fraction = self.fixture:rayCast(x1, y, x2, y, 1)

        if not fraction then
            print(x1, y, x2, y)
            print(self.fixture:getPoints())
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
        end

        local hitx = x1 * (1-fraction)

        rayTraceResults.right[row] = hitx
    end

    local subShapes = {}
    local previousRow = false

    local function doPoint(x, y, add)
        local row

        if y == bottomY then -- prioritize above row for the bottom-most points
            row = math.ceil(y/PHYSICSSCALE)
        else
            row = self.piece.playfield:worldToRow(y)
        end


        if not subShapes[row] then
            subShapes[row] = {}
        end

        if not previousRow then
            previousRow = row
        end

        if row > previousRow then -- we just went into the next row
            -- add exit point to previous row
            table.insert(subShapes[previousRow], rayTraceResults.right[previousRow])
            table.insert(subShapes[previousRow], self.piece.playfield:rowToWorld(previousRow))

            -- add entry point to current row
            table.insert(subShapes[row], rayTraceResults.right[previousRow])
            table.insert(subShapes[row], self.piece.playfield:rowToWorld(previousRow))
        end

        if row < previousRow then -- we just went into the previous row
            -- add exit point to previous row
            table.insert(subShapes[previousRow], rayTraceResults.left[row])
            table.insert(subShapes[previousRow], self.piece.playfield:rowToWorld(row))

            -- add entry point to current row
            table.insert(subShapes[row], rayTraceResults.left[row])
            table.insert(subShapes[row], self.piece.playfield:rowToWorld(row))
        end

        if add then
            table.insert(subShapes[row], x)
            table.insert(subShapes[row], y)
        end

        previousRow = row
    end

    for i = 1, #points, 2 do
        doPoint(points[i], points[i+1], true)
    end

    doPoint(points[1], points[2], false) -- go back to first point for the adding of the additional points on the rows

    ---------------------------------------------------
    -- all shape calculations complete at this point --
    ---------------------------------------------------
    self.subShapes = {}

    for row, subShape in pairs(subShapes) do
        -- make local
        for i = 1, #subShape, 2 do
            subShape[i], subShape[i+1] = self.piece.body:getLocalPoint(subShape[i], subShape[i+1])
        end

        self.piece.playfield:addArea(row, polygonarea(subShape))

        table.insert(self.subShapes,
            {
                row=row,
                shape=subShape,
                timeUpdated=love.timer.getTime()
            }
        )
    end
end

return Block
