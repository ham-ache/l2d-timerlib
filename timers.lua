-- hamache's fractional timer library for Love2D

local ssys = require 'ssys'

local FIND = string.find
local SUB = string.sub
local NUM = tonumber
local function dsep(str)
    local sep = FIND(str, '-')
    return {NUM(SUB(str, 1, sep - 1)), NUM(SUB(str, sep + 1))}
end

---@class timer
local timer = {}
timer.__index = timer
timer_instances = {}
---Creates a new timer
---@param sec number time in seconds
---@param loops number total loops
---@param clb function|table callback function or fractions
---@return timer timer timer
function timer.new(sec, loops, clb)
    local t = setmetatable({
        sec = sec,
        rem = sec,
        loops = loops,
        clb = clb,
        pause = false,
        f = 0,
        isf = type(clb) == 'table'
    }, timer)
    if t.isf then
        for x, cb in pairs(t.clb) do
            if type(x) == 'string' then
                local range = dsep(x)
                t.clb[x] = {cb, range[1], range[2]}
            end
            if x == 0 then
                cb(0, t)
            end
        end
    end
    table.insert(timer_instances, t)
    return t
end
---Pauses/Continues a timer
---@param state boolean return state if no bool
function timer:pause(state)
    if state ~= nil then
        self.pause = state
    end
    return self.pause
end
---Destroys a timer
function timer:destroy()
    for x, t in ipairs(timer_instances) do
        if t == self then 
            table.remove(timer_instances, x)
            break
        end
    end
end

ssys.new('timerlib', 'update', function(dt)
    for _, t in ipairs(timer_instances) do
        if t.pause then goto continue end
        local df = t.f
        t.f = (t.sec - t.rem) / t.sec
        if t.isf then
            for x, callback in pairs(t.clb) do
                if type(x) ~= 'string' then
                    if (t.f >= x and df < x) or ((x == 0 or x == 1) and (t.rem-dt < 0)) then
                        callback(t.f, t)
                    end
                else
                    local st, fin = callback[2], callback[3]
                    if t.f > st and t.f < fin then
                        local relf = fin ~= st and (t.f-st)/(fin-st) or 0
                        callback[1](t.f, relf, t, (df<st or df>fin) and 'enter' or 'inside')
                    elseif (df >= st and df <= fin) and (t.f < st or t.f > fin) then
                        callback[1](t.f, t.f<st and 0 or 1, t, 'exit')
                    end
                end
            end
        end
        if t.rem - dt > 0 then
            t.rem = t.rem - dt
        else
            t.rem = t.sec
            if t.loops ~= 'inf' then
                t.loops = t.loops - 1
            end
            if not t.isf then
                t.clb(t.f, t)
            end
        end
        if t.loops ~= 'inf' and t.loops <= 0 then
            t:destroy()
        end
        ::continue::
    end
end, -1)

return timer