local baton = require "lib.baton"
controls = {}

controls[1] = baton.new({
    controls = {
        left = {'key:a', 'axis:leftx-', 'button:dpleft'},
        right = {'key:d', 'axis:leftx+', 'button:dpright'},
        up = {'key:w', 'axis:lefty-', 'button:dpup'},
        down = {'key:s', 'axis:lefty+', 'button:dpdown'},
        action1 = {'key:j', 'button:a'},
        action2 = {'key:k', 'button:b'},
        start = {'key:return', 'button:start'},
    },
    pairs = {
        move = {'left', 'right', 'up', 'down'}
    },
    joystick = love.joystick.getJoysticks()[1],
})

controls[2] = baton.new({
    controls = {
        left = {'key:left', 'axis:leftx-', 'button:dpleft'},
        right = {'key:right', 'axis:leftx+', 'button:dpright'},
        up = {'key:up', 'axis:lefty-', 'button:dpup'},
        down = {'key:down', 'axis:lefty+', 'button:dpdown'},
        action1 = {'key:kp1', 'button:a'},
        action2 = {'key:kp2', 'button:b'},
        start = {'key:kp5', 'button:start'},
    },
    pairs = {
        move = {'left', 'right', 'up', 'down'}
    },
    joystick = love.joystick.getJoysticks()[2],
})
