-- an example

local timer = require 'timers'
local ssys = require 'ssys'
local ease = require 'ease'

ssys.new('tester', 'load', function()
    local Pos = {100, 100}
    local Start = 0.3
    MX, MY = 0, 0
    GPos = Pos
    Status = 'none'
    T = timer.new(1, 'inf', {
        [Start..'-1'] = function(f, relf, _, st)
            local relf2 = ease.elastic.i(relf)
            GPos = {ease.lerp(Pos[1], MX, relf2), ease.lerp(Pos[2], MY, relf2)}
            Status = st
        end,
        [Start] = function(t)
            MX, MY = love.mouse:getPosition()
        end,
        [1] = function(t)
            Pos = GPos
        end
    })
    love.graphics.setLineStyle('rough')
end)
ssys.new('tester', 'mousepressed', function()
    T:pause(true)
end)
ssys.new('tester', 'mousereleased', function()
    T:pause(false)
end)
ssys.new('tester', 'draw', function()
    love.graphics.circle('fill', GPos[1], GPos[2], 5)
    love.graphics.circle('fill', MX, MY, 1)
    love.graphics.print(Status, 6, 0)
end)