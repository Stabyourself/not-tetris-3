local PieceType = class("PieceType")

local img = love.graphics.newImage("img/tiles/0.png")

function PieceType:initialize(map, quad)
    self.map = map
    self.quad = quad

    -- convert to array before sending so we don't have to do it all the time
    self.map = {}
    for y = 1, #map do
        for x = 1, #map[y] do
            if not self.map[x] then
                self.map[x] = {}
            end

            local char = map[y]:sub(x, x)

            if char == "#" then
                self.map[x][y] = true
            else
                self.map[x][y] = false
            end
        end
    end
end

function PieceType:draw()
    love.graphics.push()
    love.graphics.translate(-#self.map*4, -#self.map[1]*4)

    for x = 1, #self.map do
        for y = 1, #self.map[x] do
            if self.map[x][y] then
                love.graphics.draw(img, self.quad, (x-1)*8, (y-1)*8)
            end
        end
    end
    love.graphics.pop()
end

local quads = {}

for i = 0, 2 do
    table.insert(quads, love.graphics.newQuad(i*10+1, 1, 8, 8, 30, 10))
end

local pieceTypes = {}

table.insert(pieceTypes, PieceType:new(
    {
        "###",
        " # ",
    },

    quads[1]
))

table.insert(pieceTypes, PieceType:new(
    {
        "###",
        "  #",
    },

    quads[3]
))

table.insert(pieceTypes, PieceType:new(
    {
        "## ",
        " ##"
    },

    quads[2]
))

table.insert(pieceTypes, PieceType:new(
    {
        "##",
        "##",
    },

    quads[1]
))

table.insert(pieceTypes, PieceType:new(
    {
        " ##",
        "## ",
    },

    quads[3]
))

table.insert(pieceTypes, PieceType:new(
    {
        "###",
        "#  ",
    },

    quads[2]
))

table.insert(pieceTypes, PieceType:new(
    {
        "####",
    },

    quads[1]
))

return pieceTypes
