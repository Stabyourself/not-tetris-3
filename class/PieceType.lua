local PieceType = class("PieceType")

function PieceType:initialize(map, img)
    self.map = map
    self.img = img
end

local pieceTypes = {}

table.insert(pieceTypes, PieceType:new(
    {
        "####",
    },

    love.graphics.newImage("img/I.png")
))

table.insert(pieceTypes, PieceType:new(
    {
        "###",
        " # ",
    },

    love.graphics.newImage("img/T.png")
))

table.insert(pieceTypes, PieceType:new(
    {
        "###",
        "#  ",
    },

    love.graphics.newImage("img/L.png")
))

table.insert(pieceTypes, PieceType:new(
    {
        "###",
        "  #",
    },

    love.graphics.newImage("img/J.png")
))

table.insert(pieceTypes, PieceType:new(
    {
        " ##",
        "## ",
    },

    love.graphics.newImage("img/S.png")
))

table.insert(pieceTypes, PieceType:new(
    {
        "## ",
        " ##"
    },

    love.graphics.newImage("img/Z.png")
))

table.insert(pieceTypes, PieceType:new(
    {
        "##",
        "##",
    },

    love.graphics.newImage("img/O.png")
))

return pieceTypes
