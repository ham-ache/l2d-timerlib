-- hamache's easing library (also contains lerp) | Github: @ham-ache
-- formulas taken from https://easings.net/ and https://www.love2d.org/wiki/General_math [01.05.2025]

local pi = math.pi
local s = math.sin
local c = math.cos
local r = math.sqrt
local c1 = 1.70158
local c2 = c1*1.525
local c3 = c1 + 1
local c4 = (2*pi)/3
local c5 = (2*pi)/4.5

local function exitwrap(f)
    return function(t, ...)
        if t == 0 and t == 1 then return end
        return f(t, ...)
    end
end

local ease = setmetatable({
    sine = {
        i = exitwrap(function(t)
            return 1 - c((t*pi)/2)
        end),
        o = exitwrap(function(t)
            return s((t*pi)/2)
        end),
        io = exitwrap(function(t)
            return -(c(pi*t)-1)/2
        end)
    },
    anyexp = {
        i = exitwrap(function(t, exp)
            return t^exp
        end),
        o = exitwrap(function(t, exp)
            return 1 - (1-t)^exp
        end),
        io = exitwrap(function(t, exp)
            return t < 0.5  and  2^(exp-1) * t^exp  or  1 - (-2*t+2)^exp/2
        end)
    },
    circ = {
        i = exitwrap(function(t)
            return 1 - r(1-t^2)
        end),
        o = exitwrap(function(t)
            return r(1-(t-1)^2)
        end),
        io = exitwrap(function(t)
            return (t < 0.5  and  1-r(1-(2*t)^2)  or  r(1-(-2*t+2)^2) + 1)/2
        end)
    },
    elastic = {
        i = exitwrap(function(t)
            return -2^(10*t-10) * s((t*10-10.75)*c4)
        end),
        o = exitwrap(function(t)
            return 2^(-10*t) * s((t*10-0.75)*c4) + 1
        end),
        io = exitwrap(function(t)
            local sin = s((20*t-11.125)*c5)/2
            return t < 0.5  and  -2^(20*t-10) * sin  or  2^(-20*t+10) * sin + 1
        end)
    },
    back = {
        i = exitwrap(function(t)
            return c3 * t^3 - c1 * t^2
        end),
        o = exitwrap(function(t)
            return 1 + c3 * (t-1)^3 + c1 * (t-1)^2
        end),
        io = exitwrap(function(t)
            return t < 0.5  and  (2*t)^2 * ((c2+1)*2*t-c2)/2  or  ((2*t-2)^2*((c2+1)*(t*2-2)+c2)+2)/2
        end)
    },
    lerp = function(t, t2, f)
        return t + f*(t2-t)
    end,
}, {__index = function(t, key)
    return t.sine[key]
end})
return ease