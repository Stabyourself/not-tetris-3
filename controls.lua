local baton = require "lib.baton"
controls = {}
controlsLoader = {}

function controlsLoader.loadSP()
    controls = {}

    controls[1] = baton.new({
        controls = {
            left = {'key:a', "key:left", 'axis:leftx-', 'hat:1l', 'hat:1ld'},
            right = {'key:d', "key:right", 'axis:leftx+', 'hat:1r', 'hat:1rd'},
            up = {'key:w', "key:up", 'axis:lefty-', 'hat:1u'},
            down = {'key:s', "key:down", 'axis:lefty+', 'hat:1d', 'hat:1ld', 'hat:1rd'},
            rotate_left = {'key:j', "key:y", "key:z", "key:w", 'button:2'},
            rotate_right = {'key:k', "key:x", 'button:1'},
            start = {'key:return', 'button:4'},

            debug1 = {"key:1"},
            debug2 = {"key:2"},
            debug3 = {"key:3"},
            debug4 = {"key:4"},
            debug5 = {"key:5"},
            debug6 = {"key:6"},
            debug7 = {"key:7"},
            debug8 = {"key:8"},
            debug9 = {"key:9"},
        },
        pairs = {
            move = {'left', 'right', 'up', 'down'}
        },
        joystick = love.joystick.getJoysticks()[1],
    })
end

function controlsLoader.loadMP()
    controls = {}

    controls[1] = baton.new({
        controls = {
            left = {'key:a', 'axis:leftx-', 'hat:1l', 'hat:1ld'},
            right = {'key:d', 'axis:leftx+', 'hat:1r', 'hat:1rd'},
            up = {'key:w', 'axis:lefty-', 'hat:1u'},
            down = {'key:s', 'axis:lefty+', 'hat:1d', 'hat:1ld', 'hat:1rd'},
            rotate_left = {'key:j', 'button:2'},
            rotate_right = {'key:k', 'button:1'},
            start = {'key:return', 'button:4'},

            debug1 = {"key:1"},
            debug2 = {"key:2"},
            debug3 = {"key:3"},
            debug4 = {"key:4"},
            debug5 = {"key:5"},
            debug6 = {"key:6"},
            debug7 = {"key:7"},
            debug8 = {"key:8"},
            debug9 = {"key:9"},
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
            rotate_left = {'key:kp1', 'button:2'},
            rotate_right = {'key:kp2', 'button:1'},
            start = {'key:kp5', "key:rshift", 'button:4'},
        },
        pairs = {
            move = {'left', 'right', 'up', 'down'}
        },
        joystick = love.joystick.getJoysticks()[2],
    })
end
