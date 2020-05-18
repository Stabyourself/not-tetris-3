local Puyo = CLASS("Puyo")

Puyo.size = 10/6 / 2 -- radius

Puyo.shape = love.physics.newCircleShape(Puyo.size*PHYSICSSCALE)

function Puyo:initialize(playfield, color)
    self.playfield = playfield
    self.color = color

    self.body = love.physics.newBody(playfield.world, PIECESTARTX, PIECESTARTY, "dynamic")
    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.body:setUserData(self)
    self.body:setAngle(0)
    -- self.body:setBullet(true)

    self.body:setLinearVelocity(0, self.playfield:getMaxSpeedY())
    self.active = true
end

--- Stops the piece from falling too fast, based on the level usually
function Puyo:limitDownwardVelocity()
    local speedX, speedY = self.body:getLinearVelocity()

    if speedY > self.playfield:getMaxSpeedY() then
        self.body:setLinearVelocity(speedX, self.playfield:getMaxSpeedY())
    end
end

function Puyo:draw()
    love.graphics.push()
    love.graphics.scale(1/PHYSICSSCALE*BLOCKSCALE, 1/PHYSICSSCALE*BLOCKSCALE)
    love.graphics.translate(self.body:getPosition())
    love.graphics.rotate(self.body:getAngle())

    love.graphics.setColor(self.color)
    love.graphics.circle("fill", 0, 0, self.size*PHYSICSSCALE)

    love.graphics.setColor(1, 1, 1)

    love.graphics.pop()
end

function Puyo:move(dir)
    self.body:applyForce(MOVEFORCE*dir, 0)
end

function Puyo:rotate(dir)
    self.body:applyTorque(ROTATEFORCE*dir, 0)
end

--- Cuts a piece in rows
function Puyo:cut(rows)
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
function Puyo:separateBlocks()
    local shapes = {}

    for _, block in ipairs(self.blocks) do
        table.insert(shapes, {block.shape:getPoints()})
    end

    local connected = {}
    local notConnected = {}

    for blockI, block in ipairs(self.blocks) do
        local enteredAnywhere = false

        for pointI = 1, #shapes[blockI], 2 do
            local foundShapeI, foundPointI = util.findPointInShapes(shapes, shapes[blockI][pointI], shapes[blockI][pointI+1], blockI, 4)

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
                if table.includesI(group, pair[1]) then
                    if not table.includesI(group, pair[2]) then
                        table.insert(group, pair[2])
                    end

                    found = true
                elseif table.includesI(group, pair[2]) then
                    if not table.includesI(group, pair[1]) then
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

                if not table.includesI(group, j) then
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

            local piece = Puyo.fromShapes(self.playfield, createShapes)
            piece.body:setPosition(self.body:getPosition())
            piece.body:setAngle(self.body:getAngle())
            piece.body:setAngularVelocity(self.body:getAngularVelocity())
            piece.body:setLinearVelocity(self.body:getLinearVelocity())

            self.playfield:addPuyo(piece)
        end
    end
end

function Puyo:move(dir)
    self.body:applyForce(MOVEFORCE*dir, 0)
end

function Puyo:rotate(dir)
    self.body:applyTorque(ROTATEFORCE*dir, 0)
end


return Puyo