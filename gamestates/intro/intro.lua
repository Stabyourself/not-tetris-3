local path = "gamestates/intro/"

local frameTime = 0.04
local playSoundAt = 0.5

local palette = {
    {c={0,0,0}, avg=0},
    {c={0,0.14285714285714,0.57142857142857}, avg=0.23809523809524},
    {c={0.42857142857143,0.42857142857143,0.42857142857143}, avg=0.42857142857143},
    {c={0.71428571428571,0.71428571428571,0.71428571428571}, avg=0.71428571428571},
    {c={0.71428571428571,0.85714285714286,1}, avg=0.85714285714286},
    {c={1,1,1}, avg=1},
}

local transitionTypes = {"fade", "lines", "wave"}

local waveShader, shaderCanvas

local intro = CLASS("intro")

function intro:initialize(w, h, scale)
    self.transitionType = "fade"--transitionTypes[love.math.random(#transitionTypes)]

    self.width = w
    self.height = h
    self.scale = scale

    if self.transitionType == "wave" then
        waveShader = love.graphics.newShader([[
            extern float intensity;
            extern float timer;
            extern float height;

            vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
            {
                float useY = ceil(texture_coords.y*height)/height;
                vec4 texcolor = Texel(texture, texture_coords + vec2(sin(timer*10+useY*30)*intensity, 0));
                return texcolor * color;
            }
        ]])

        waveShader:send("height", self.height/self.scale/2)
        shaderCanvas = love.graphics.newCanvas(self.width, self.height)
    end

    self.stabSound = love.audio.newSource(path .. "stab.ogg", "static")

    self.dudeImg = love.graphics.newImage(path .. "dude.png")
    self.dudeImg:setFilter("nearest", "nearest")
    self.dudeFrames = {}

    for y = 1, 5 do
        for x = 1, y == 5 and 1 or 4 do
            table.insert(self.dudeFrames, love.graphics.newQuad(1+(x-1)*88, 1+(y-1)*51, 87, 50, 353, 256))
        end
    end

    self.titleImg = love.graphics.newImage(path .. "title.png")
    self.titleImg:setFilter("nearest", "nearest")

    self.timing = {
        {name="emptyWait", d=0.3},
        {name="fadeIn", d=0.3},
        {name="knifeWait", d=0.5},
        {name="animation", d=#self.dudeFrames*frameTime},
        {name="finishWait", d=1.5},
        {name="fadeOut", d=0.3},
        {name="emptyWait2", d=0.5},
        {name="finished", d=math.huge}
    }

end

function intro:enter()
    self.state = 1
    self.timer = 0
    game.background.active = false
end

function intro:update(dt)
    self.timer = self.timer + dt

    if not self.soundPlayed and self.timing[self.state].name == "animation" and self.timer >= playSoundAt then
        self.stabSound:play()
        self.soundPlayed = true
    end

    while self.timer > self.timing[self.state].d do
        self.timer = self.timer - self.timing[self.state].d
        self.state = math.min(#self.timing, self.state + 1)

        if self.state == #self.timing then
            if self.onFinish then
                self.onFinish()
            end
        end
    end
end

function intro:transition(i)
    if self.transitionType == "fade" then
        self:setClosestColor(i)

    elseif self.transitionType == "lines" then
        local lineHeight = 8*self.scale

        love.graphics.stencil(function()
            love.graphics.push()
            love.graphics.origin()
            for y = 0, self.height-1, lineHeight do
                love.graphics.rectangle("fill", 0, y, self.width, math.ceil(lineHeight*i/self.scale)*self.scale)
            end
            love.graphics.pop()
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)

    elseif self.transitionType == "wave" then
        waveShader:send("intensity", (1-i)*0.1)
        waveShader:send("timer", self.timer)
        love.graphics.setCanvas(shaderCanvas)
        love.graphics.clear()
    end
end

function intro:transitionCleanup(i)
    if self.transitionType == "fade" then
        love.graphics.setColor(1, 1, 1)

    elseif self.transitionType == "lines" then
        love.graphics.setStencilTest()

    elseif self.transitionType == "wave" then
        love.graphics.setCanvas()
        love.graphics.setShader(waveShader)
        love.graphics.push()
        love.graphics.origin()
        love.graphics.setColor(1, 1, 1, i)

        love.graphics.draw(shaderCanvas)
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
        love.graphics.setShader()
    end
end

function intro:setClosestColor(a)
    -- find closest color
    local closest = 1
    for i, color in ipairs(palette) do
        if math.abs(a-color.avg) < math.abs(a-palette[closest].avg) then
            closest = i
        end
    end

    love.graphics.setColor(palette[closest].c)
end

function intro:draw()
    love.graphics.push()
    love.graphics.translate(self.width/2, self.height/2)
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(0, -10)

    local name = self.timing[self.state].name

    if name == "fadeIn" then
        local i = self.timer/self.timing[self.state].d
        self:transition(i)
        love.graphics.draw(self.dudeImg, self.dudeFrames[1], 0, 0, 0, 1, 1, 43, 25)
        self:transitionCleanup(i)

    elseif name == "knifeWait" then
        love.graphics.draw(self.dudeImg, self.dudeFrames[1], 0, 0, 0, 1, 1, 43, 25)

    elseif name == "animation" then
        local frame = math.min(math.ceil(self.timer/frameTime), #self.dudeFrames)
        love.graphics.draw(self.dudeImg, self.dudeFrames[frame], 0, 0, 0, 1, 1, 43, 25)

        love.graphics.stencil(function()
            love.graphics.draw(self.titleImg, 0, 51, 0, 1, 1, 43, 25)
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)

        local posStart = 51-self.titleImg:getHeight()
        local posChange = self.titleImg:getHeight()

        local moveAfter = 0.53
        local moveOver = 0.05

        local progress = math.max(0, math.min(1, (self.timer-moveAfter)/moveOver))

        local pos = posChange * math.sin(progress * (math.pi / 2)) + posStart

        love.graphics.draw(self.titleImg, 0, pos, 0, 1, 1, 43, 25)

        love.graphics.setStencilTest()

    elseif name == "finishWait" then
        love.graphics.draw(self.dudeImg, self.dudeFrames[#self.dudeFrames], 0, 0, 0, 1, 1, 43, 25)
        love.graphics.draw(self.titleImg, 0, 51, 0, 1, 1, 43, 25)

    elseif name == "fadeOut" then
        local i = 1-self.timer/self.timing[self.state].d
        self:transition(i)
        love.graphics.draw(self.dudeImg, self.dudeFrames[#self.dudeFrames], 0, 0, 0, 1, 1, 43, 25)
        love.graphics.draw(self.titleImg, 0, 51, 0, 1, 1, 43, 25)
        self:transitionCleanup(i)
    end

    love.graphics.pop()
end

function intro:keypressed()
    if self.onFinish then
        TIMER.setTimer(function() self.onFinish() end, 0)
    end
end


return intro
