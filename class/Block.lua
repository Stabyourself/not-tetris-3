local Block = class("Block")

local img = love.graphics.newImage("img/tiles/0.png")

function Block:initialize(piece, x, y, quad)
    self.piece = piece
    self.x = x
    self.y = y
    self.quad = quad

    if DIAMONDADD > 0 then
        error("DIAMONDADD support broke lol.")
        self.shape = love.physics.newPolygonShape(
            x+DIAMONDADD, y, -- clockwise, starting top leftish
            x+1-DIAMONDADD, y,
            x+1, y+DIAMONDADD,
            x+1, y+1-DIAMONDADD,
            x+1-DIAMONDADD, y+1,
            x+DIAMONDADD, y+1,
            x, y+1-DIAMONDADD,
            x, y+DIAMONDADD
        )
    else
        self.shape = love.physics.newRectangleShape((x+.5)*PHYSICSSCALE, (y+.5)*PHYSICSSCALE, PHYSICSSCALE, PHYSICSSCALE)
    end

    self.fixture = love.physics.newFixture(self.piece.body, self.shape)
    self.fixture:setFriction(PIECEFRICTION)
end

function Block:draw()
    love.graphics.draw(img, self.quad, self.x*PHYSICSSCALE, self.y*PHYSICSSCALE, 0, PHYSICSSCALE/PIECESCALE)
end

function Block:debugDraw()
    -- local points = {self.fixture:getShape():getPoints()}
    -- love.graphics.line(points[#points-1], points[#points], unpack(points))

    for _, subShape in ipairs(self.subShapes) do
        if subShape.row%2 == 1 then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(0, 1, 0)
        end

        for i = 1, #subShape.shape-2, 2 do
            love.graphics.line(subShape.shape[i], subShape.shape[i+1], subShape.shape[i+2], subShape.shape[i+3])
        end
        love.graphics.line(subShape.shape[#subShape.shape-1], subShape.shape[#subShape.shape], subShape.shape[1], subShape.shape[2])
    end
end

function Block:cut(rows)
    for _, subShape in ipairs(self.subShapes) do
        if inTable(rows, subShape.row) then
            table.remove(self.subShapes, i)
        end
    end

    if #self.subShapes > 0 then
        for _, subShape in ipairs(self.subShapes) do
            self.fixture:destroy()
            self.shape = love.physics.newPolygonShape(subShape.shape)
            self.fixture = love.physics.newFixture(self.piece.body, self.shape)
            self.fixture:setFriction(PIECEFRICTION)
        end
    else
        self.fixture:destroy()
        self.piece:removeBlock(self)
    end
end

function Block:setSubShapes()
    -- doing all of this inline because I expect this to be performance-important code
    -- can be broken up later

    -- Get top and bottom most row that this block is in
    local topRow = math.huge
    local bottomRow = -1
    local points = {self.piece.body:getWorldPoints(self.shape:getPoints())}

    for i = 1, #points, 2 do
        local x, y = points[i], points[i+1]

        -- print

        topRow = math.min(topRow, math.floor(y/PHYSICSSCALE)+1)
        bottomRow = math.max(bottomRow, math.ceil(y/PHYSICSSCALE))
    end

    -- raytrace the points at which this block crosses lines
    local rayTraceResults = {left={}, right={}}

    for row = topRow, bottomRow-1 do
        -- FROM LEFT
        local x1 = 0
        local x2 = self.piece.playfield.columns*PHYSICSSCALE
        local y1 = self.piece.playfield:rowToWorld(row)
        local y2 = self.piece.playfield:rowToWorld(row)

        local xn, yn, fraction = self.fixture:rayCast(x1, y1, x2, y2, 1)

        local hitx = x1 + (x2 - x1) * fraction
        -- local hity = y1 + (y2 - y1) * fraction -- we already have hity

        rayTraceResults.left[row] = hitx

        -- FROM RIGHT
        local x1 = self.piece.playfield.columns*PHYSICSSCALE
        local x2 = 0

        local xn, yn, fraction = self.fixture:rayCast(x1, y1, x2, y2, 1)

        local hitx = x1 + (x2 - x1) * fraction
        -- local hity = y1 + (y2 - y1) * fraction

        rayTraceResults.right[row] = hitx
    end

    local subShapes = {}
    local previousRow = false

    local function doPoint(x, y, add)
        local row = self.piece.playfield:worldToRow(y)

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
        local x, y = points[i], points[i+1]

        doPoint(x, y, true)
    end

    doPoint(points[1], points[2], false) -- go back to first point for the adding of the additional points on the rows

    ---------------------------------------------------
    -- all shape calculations complete at this point --
    ---------------------------------------------------
    self.subShapes = {}

    for row, subShape in pairs(subShapes) do
        -- make local
        for i = 1, #subShape-1, 2 do
            subShape[i], subShape[i+1] = self.piece.body:getLocalPoint(subShape[i], subShape[i+1])
        end

        table.insert(self.subShapes,
            {
                row=row,
                shape=subShape
            }
        )
    end
end

return Block
