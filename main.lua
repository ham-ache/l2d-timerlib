-- an example, usually for testing purposes

local ssys = require 'ssys'
local timer = require 'timers'
local ease = require 'ease'

ssys.new('tester', 'load', function()
    local Pos = {100, 100}
    local Start = 0.5
    MX, MY = 0, 0
    GPos = Pos
    Status = 'none'
    ts = {'exit time: 0', 'enter time: 0'}
    T = timer.new(1, 'inf', {
        [Start..'-1'] = function(f, relf, _, st)
            local relf2 = ease.circ.io(relf)
            GPos = {ease.lerp(Pos[1], MX, relf2), ease.lerp(Pos[2], MY, relf2)}
            Status = st..' | '..relf
            if st == 'exit' then
                ts[1] = 'exit time: '..love.timer.getTime()
            end
            if st == 'enter' then
                ts[2] = 'enter time: '..love.timer.getTime()
            end
        end,
        [Start] = function(t)
            MX, MY = love.mouse:getPosition()
        end,
        [1] = function(t)
            Pos = GPos
        end
    })
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
    love.graphics.print(Status..'\n'..ts[1]..'\n'..ts[2]..'\n'..string.format('%.2f',T.f), 6, 0)
end)