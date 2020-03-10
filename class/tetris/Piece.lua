local Piece = CLASS("Piece")
local audioManager = require "lib.audioManager3"

local Block = require "CLASS.tetris.Block"

function Piece:initialize(playfield)
    self.playfield = playfield

    self.blocks = {}

    self.body = love.physics.newBody(playfield.world, PIECESTARTX, PIECESTARTY, "dynamic")
    self.body:setUserData(self)
    self.body:setAngle(0)
    -- self.body:setBullet(true)

    self.body:setLinearVelocity(0, self.playfield:getMaxSpeedY())
    self.active = true
end

--- Returns a piece from a piece type (like, T or O)
function Piece.fromPieceType(playfield, pieceType)
    local piece = Piece:new(playfield)

    for x = 1, #pieceType.map do
        for y = 1, #pieceType.map[x] do
            if pieceType.map[x][y] then
                local rx = x-1-#pieceType.map/2
                local ry = y-1-#pieceType.map[x]/2

                local shape = love.physics.newRectangleShape((rx+.5)*PHYSICSSCALE, (ry+.5)*PHYSICSSCALE, PHYSICSSCALE, PHYSICSSCALE)

                local block = Block:new(piece, shape, rx, ry, playfield:getBlockGraphic(), pieceType.map[x][y])
                table.insert(piece.blocks, block)
            end
        end
    end

    return piece
end

--- Returns a piece from a list of shapes
function Piece.fromShapes(playfield, shapes)
    local piece = Piece:new(playfield)

    for _, shape in ipairs(shapes) do
        local b2shape = love.physics.newPolygonShape(shape.shape)
        local block = Block:new(piece, b2shape, shape.x, shape.y, shape.img, shape.quadI)
        table.insert(piece.blocks, block)
    end

    return piece
end

--- Stops the piece from falling too fast, based on the level usually
function Piece:limitDownwardVelocity()
    local speedX, speedY = self.body:getLinearVelocity()

    if speedY > self.playfield:getMaxSpeedY() then
        self.body:setLinearVelocity(speedX, self.playfield:getMaxSpeedY())
    end
end

function Piece:draw()
    love.graphics.push()
    love.graphics.scale(1/PHYSICSSCALE*BLOCKSCALE, 1/PHYSICSSCALE*BLOCKSCALE)
    love.graphics.translate(self.body:getPosition())
    love.graphics.rotate(self.body:getAngle())

    for _, block in ipairs(self.blocks) do
        block:draw()
    end

    for _, block in ipairs(self.blocks) do
        block:debugDraw()
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.pop()
end

function Piece:move(dir)
    self.body:applyForce(MOVEFORCE*dir, 0)
end

function Piece:rotate(dir)
    self.body:applyTorque(ROTATEFORCE*dir, 0)
end

--- Cuts a piece in rows
function Piece:cut(rows)
    for i = #self.blocks, 1, -1 do
        self.blocks[i]:cut(rows)
    end

    for i = #self.blocks, 1, -1 do
        if self.blocks[i].removeMe then
            table.remove(self.blocks, i)
        end
    end

    -- check if blocks are separated
    self:separateBlocks()
end

--- Handles blocks that are no longer connected, creating new pieces as required
function Piece:separateBlocks()
    local shapes = {}

    for _, block in ipairs(self.blocks) do
        table.insert(shapes, {block.shape:getPoints()})
    end

    local connected = {}
    local notConnected = {}

    for blockI, block in ipairs(self.blocks) do
        local enteredAnywhere = false

        for pointI = 1, #shapes[blockI], 2 do
            local foundShapeI, foundPointI = findPointInShapes(shapes, shapes[blockI][pointI], shapes[blockI][pointI+1], blockI, 4)

            if foundShapeI then
                -- check already entered
                local found = false

                for _, pair in ipairs(connected) do
                    if  (pair[1] == foundShapeI and pair[2] == blockI) or
                        (pair[1] == blockI and pair[2] == foundShapeI) then
                        found = true
                        enteredAnywhere = true
                    end
                end

                if not found then
                    table.insert(connected, {foundShapeI, blockI})
                    enteredAnywhere = true
                end
            end
        end

        if not enteredAnywhere then
            table.insert(notConnected, blockI)
        end
    end

    local groups = {}
    if #connected > 0 then
        table.insert(groups, {connected[1][1], connected[1][2]})

        for i = 2, #connected do
            local pair = connected[i]
            local found = false

            for _, group in ipairs(groups) do
                if inTable(group, pair[1]) then
                    if not inTable(group, pair[2]) then
                        table.insert(group, pair[2])
                    end

                    found = true
                elseif inTable(group, pair[2]) then
                    if not inTable(group, pair[1]) then
                        table.insert(group, pair[1])
                    end

                    found = true
                end
            end

            if not found then
                table.insert(groups, {pair[1], pair[2]})
            end
        end
    end

    for _, notConnectedV in ipairs(notConnected) do
        table.insert(groups, {notConnectedV})
    end

    for i = #groups, 1, -1 do
        local group = groups[i]

        if i == 1 then -- remove any fixture no longer in group 1
            for j = #self.blocks, 1, -1 do
                local block = self.blocks[j]

                if not inTable(group, j) then
                    block.fixture:destroy()
                    table.remove(self.blocks, j)
                end
            end

        else -- add these blocks to new pieces
            local createShapes = {}
            for _, groupElem in ipairs(group) do
                local block = self.blocks[groupElem]

                table.insert(createShapes, {
                    shape = {block.shape:getPoints()},
                    x = block.x,
                    y = block.y,
                    img = block.img,
                    quadI = block.quadI,
                })
            end

            local piece = Piece.fromShapes(self.playfield, createShapes)
            piece.body:setPosition(self.body:getPosition())
            piece.body:setAngle(self.body:getAngle())
            piece.body:setAngularVelocity(self.body:getAngularVelocity())
            piece.body:setLinearVelocity(self.body:getLinearVelocity())

            self.playfield:addPiece(piece)
        end
    end
end

return Piece