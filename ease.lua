-- hamache's easing library (also contains 123lerp)
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

local ease = setmetatable({
    quad = {
        In = function(t)
            return t^2
        end,
        out = function(t)
            return t*(2-t)
        end,
        inout = function(t)
            return t < 0.5  and  2*t*t  or  1-(-2*t+2)^2/2
        end
    },
    sine = {
        In = function(t)
            return 1 - c((t*pi)/2)
        end,
        out = function(t)
            return s((t*pi)/2)
        end,
        inout = function(t)
            return -(c(pi*t)-1)/2
        end
    },
    anyexp = {
        In = function(t, exp)
            return t^exp
        end,
        out = function(t, exp)
            return 1 - (1-t)^exp
        end,
        inout = function(t, exp)
            return (t < 0.5  and  (2*t)^exp  or  1 - (2*(1-t))^exp)/2
        end
    },
    circ = {
        In = function(t)
            return 1 - r(1-t^2)
        end,
        out = function(t)
            return r(1-(t-1)^2)
        end,
        inout = function(t)
            return (t < 0.5  and  1-r(1-(2*t)^2)  or  r(1 - (-2*t+2)^2))/2
        end
    },
    elastic = {
        In = function(t)
            if t == 0 or t == 1 then return t end
            return -2^(10*t-10) * s((t*10-10.75)*c4)
        end,
        out = function(t)
            if t == 0 or t == 1 then return t end
            return 2^(-10*t) * s((t*10-0.75)*c4) + 1
        end,
        inout = function(t)
            if t == 0 or t == 1 then return t end
            local sin = s((20*t-11.125)*c5)/2
            return t < 0.5  and  -2^(20*t-10) * sin  or  2^(-20*t+10) * sin + 1
        end
    },
    back = {
        In = function(t)
            return c3 * t^3 - c1 * t^2
        end,
        out = function(t)
            return 1 + c3 * (t-1)^3 + c1 * (t-1)^2
        end,
        inout = function(t)
            return ( t < 0.5  and  (2*t)^2 * ((c2+1)*2*t-c2)/2  or  (2*t-2)^2 * ((c2+1)*(t*2-2)+c2) + 2 )/2
        end
    },
    lerp = function(t, t2, f)
        return t + f*(t2-t)
    end,
    lerp2 = function(v, v2, f)
        local c, c2 = {x = v.x or v[1], y = v.y or v[2]}, {x = v2.x or v2[1], y = v2.y or v2[2]}
        return {
            c.x + f*(c2.x - c.x),
            c.y + f*(c2.y - c.y)
        }
    end,
    lerp3 = function(v, v2, f)
        local c, c2 = {x = v.x or v[1], y = v.y or v[2], z = v.z or v[3]}, {x = v2.x or v2[1], y = v2.y or v2[2], z = v2.z or v2[3]}
        return {
            c.x + f*(c2.x - c.x),
            c.y + f*(c2.y - c.y),
            c.z + f*(c2.z - c.z),
        }
    end,
}, {__index = function(t, key)
    return t.sine[key]
end})
return ease