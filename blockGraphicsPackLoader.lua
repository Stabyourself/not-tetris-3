local BlockGraphicsPack = CLASS("BlockGraphicsPack")

function BlockGraphicsPack:initialize(dir)
    self.graphics = {}
    self.graphicsCount = 0

    local i = 0

    while love.filesystem.getInfo(dir .. "/" .. i .. ".png", "file") do
        self.graphics[i] = love.graphics.newImage(dir .. "/" .. i .. ".png")
        self.graphicsCount = i+1

        i = i + 1
    end
end

function BlockGraphicsPack:getGraphic(level)
    local level = (level or 0)%self.graphicsCount

    return self.graphics[level]
end



local packs = {
    NES="nes"
}

local blockGraphicsPacks = {}

for name, dir in pairs(packs) do
    blockGraphicsPacks[name] = BlockGraphicsPack:new("img/blocks/" .. dir)
end

return blockGraphicsPacks
