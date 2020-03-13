local audioManager3 = {}

function audioManager3.load()
    audioManager3.sources = {}

    local audioList = {"clear", "move", "place", "topout", "turn", "tetris", "level", "menu_move", "menu_select"}

    for _, name in ipairs(audioList) do
        audioManager3.sources[name] = love.audio.newSource("audio/" .. name .. ".ogg", "static")
    end
end

function audioManager3.play(soundName)
    assert(audioManager3.sources[soundName], string.format("Request sound %s not found.", soundName))

    audioManager3.sources[soundName]:stop()
    audioManager3.sources[soundName]:play()
end

return audioManager3
