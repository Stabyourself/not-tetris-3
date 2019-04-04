local PieceType = class("PieceType")

local img = love.graphics.newImage("img/tiles/0.png")

local quads = {}

for i = 0, 2 do
    quads[tostring(i+1)] = love.graphics.newQuad(i*10+1, 1, 8, 8, 30, 10)
end

function PieceType:initialize(map)
    self.map = map

    -- convert to array before sending so we don't have to do it all the time
    self.map = {}
    for y = 1, #map do
        for x = 1, #map[y] do
            if not self.map[x] then
                self.map[x] = {}
            end

            local char = map[y]:sub(x, x)

            if char ~= " " then
                self.map[x][y] = quads[char]
            else
                self.map[x][y] = false
            end
        end
    end
end

local pieceTypes = {}

table.insert(pieceTypes, PieceType:new(
    {
        "111",
        " 1 ",
    }
))

table.insert(pieceTypes, PieceType:new(
    {
        "333",
        "  3",
    }
))

table.insert(pieceTypes, PieceType:new(
    {
        "22 ",
        " 22"
    }
))

table.insert(pieceTypes, PieceType:new(
    {
        "11",
        "11",
    }
))

table.insert(pieceTypes, PieceType:new(
    {
        " 33",
        "33 ",
    }
))

table.insert(pieceTypes, PieceType:new(
    {
        "222",
        "2  ",
    }
))

table.insert(pieceTypes, PieceType:new(
    {
        "1111",
    }
))

return pieceTypes
