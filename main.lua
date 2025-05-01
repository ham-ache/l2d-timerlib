-- an example
--[[
you can create timers like this:
    - simple:
        timer.new(1, 5, function(timer)
            --your func
        end)
    - fractional:
        timer.new(1, 5, {
            [0.66] = function(fraction, timer)
                --your func when timer hits 66%
            end,
            ['0.7-0.8'] = function(fraction, relativefrac)
                --your func while timer's fraction is in range between 70% and 80%
                --relativefrac is relative to the range
            end
        })
    you can also put 'inf' for loops if you want the timer to go on forever

    you can destroy timers:
        timer:destroy()
    
    and pause them:
        timer:pause(true) -> bool paused
        timer will be untouched if there is no boolean paused
]]

local timer = require 'timers'
local ssys = require 'ssys'
local ease = require 'ease'

ssys.new('tester', 'load', function()
    Pos = {100, 100}
    Status = 'nil'
    timer.new(1, 'inf', function()
        Status = Status..'\n\n'..love.timer.getTime()
    end)
    timer.new(2, 'inf', {
        ['0.5-1'] = function(f, relf)
            relf = ease.elastic.o(relf)
            Pos = ease.lerp2({100, 100}, {400, 70}, relf)
        end,
        [0.5] = function(f)
            Status = 'start - '..f
        end,
        [0] = function()
            Status = 'stop'
        end,
    })
end)
ssys.new('tester', 'draw', function()
    love.graphics.circle('fill', Pos[1], Pos[2], 5)
    love.graphics.print(Status, 100, 120)
end)