local baton = require "lib.baton"
controls = {}

controls[1] = baton.new({
    controls = {
        left = {'key:a', 'axis:leftx-', 'hat:1l', 'hat:1ld'},
        right = {'key:d', 'axis:leftx+', 'hat:1r', 'hat:1rd'},
        up = {'key:w', 'axis:lefty-', 'hat:1u'},
        down = {'key:s', 'axis:lefty+', 'hat:1d', 'hat:1ld', 'hat:1rd'},
        action1 = {'key:j', 'button:2'},
        action2 = {'key:k', 'button:1'},
        start = {'key:return', 'button:4'},

        debug1 = {"key:1"},
        debug2 = {"key:2"},
        debug3 = {"key:3"},
        debug4 = {"key:4"},
        debug5 = {"key:5"},
    },
    pairs = {
        move = {'left', 'right', 'up', 'down'}
    },
    joystick = love.joystick.getJoysticks()[1],
})

controls[2] = baton.new({
    controls = {
        left = {'key:left', 'axis:leftx-', 'hat:1l', 'hat:1ld'},
        right = {'key:right', 'axis:leftx+', 'hat:1r', 'hat:1rd'},
        up = {'key:up', 'axis:lefty-', 'hat:1u'},
        down = {'key:down', 'axis:lefty+', 'hat:1d', 'hat:1ld', 'hat:1rd'},
        action1 = {'key:kp1', 'button:2'},
        action2 = {'key:kp2', 'button:1'},
        start = {'key:kp5', "key:rshift", 'button:4'},
    },
    pairs = {
        move = {'left', 'right', 'up', 'down'}
    },
    joystick = love.joystick.getJoysticks()[2],
})
