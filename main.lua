-- an example

local timer = require 'timers'
local ssys = require 'ssys'
local ease = require 'ease'

ssys.new('tester', 'load', function()
    PosX, PosY = 100, 100
    Frac = 0
    Status = ''
    timer.new(5, 'inf', {
        ['0.5-1'] = function(f, relf)
            relf = ease.elastic.inout(relf)
            PosX, PosY = unpack(ease.lerp2({100, 100}, {200, 100}, relf))
        end,
        ['0-1'] = function(f, _, _, status)
            Frac = f
            Status = status
        end
    })
end)
ssys.new('tester', 'draw', function()
    love.graphics.circle('fill', PosX, PosY, 5)
    love.graphics.print(string.format('%.2f', Frac)..' / '..Status, 100, 120)
end)