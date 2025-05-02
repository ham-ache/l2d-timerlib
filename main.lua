-- an example

local timer = require 'timers'
local ssys = require 'ssys'
local ease = require 'ease'

ssys.new('tester', 'load', function()
    Pos = {100, 100}
    Status = 'nil'
    timer.new(1, 'inf', function()
        Status = Status..'\n\n'..love.timer.getTime()
    end)
    MX, MY = 0, 0
    timer.new(2, 'inf', {
        ['0.5-1'] = function(f, relf)
            relf = ease.elastic.o(relf)
            Pos = {ease.lerp(100, MX, relf), ease.lerp(100, MY, relf)}
        end,
        [0.5] = function(f)
            Status = 'start - '..f
            MX, MY = love.mouse:getPosition()
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