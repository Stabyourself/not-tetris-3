local audioManager = {}

function audioManager.load()
    audioManager.sources = {}

    local audioList = {"clear", "move", "place", "topout", "turn"}

    for _, name in ipairs(audioList) do
        audioManager.sources[name] = love.audio.newSource("audio/" .. name .. ".ogg", "static")
    end
end

function audioManager.play(soundName)
    assert(audioManager.sources[soundName], string.format("Request sound %s not found.", soundName))

    audioManager.sources[soundName]:stop()
    audioManager.sources[soundName]:play()
end

return audioManager
