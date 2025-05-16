-- hamache's fractional timer library for Love2D | Github: @ham-ache

-- evferyy optimnziuation mateters!!!!!!!!!!!!
local pairs = pairs
local ipairs = ipairs
local sm = setmetatable
local ins = table.insert
local rem = table.remove
local ty = type
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
---@param tickrate number|nil independent tickrate or dt
---@return timer timer timer
function timer.new(sec, loops, clb, tickrate)
    local t = sm({
        sec = sec,
        rem = sec,
        loops = loops,
        clb = clb,
        paused = false,
        f = 0,
        isf = ty(clb) == 'table',
        tick = tickrate
    }, timer)
    if t.isf then
        for x, cb in pairs(t.clb) do
            if ty(x) == 'string' then
                local range = dsep(x)
                t.clb[x] = {cb, range[1], range[2]}
            end
            if x == 0 then
                cb(0, t)
            end
        end
    end
    ins(timer_instances, t)
    return t
end
---Pauses/Continues a timer
---@param state boolean return state if no bool
function timer:pause(state)
    if state ~= nil then
        self.paused = state
    end
    return self.paused
end
---Destroys a timer
function timer:destroy()
    for x, t in ipairs(timer_instances) do
        if t == self then 
            rem(timer_instances, x)
            break
        end
    end
end
local function resetTimer(t)
    local last
    if t.loops ~= 'inf' then
        t.loops = t.loops - 1
        last = t.loops <= 0
    end
    
    if t.isf then
        if t.clb[0] and not last then
            t.clb[0](t)
        end
        for x, c in pairs(t.clb) do
            if ty(x) == 'string' then
                local st, fin = c[2], c[3]
                if st == 0 and not last then
                    c[1](0, 0, t, 'enter')
                end
                if fin == 1 then
                    c[1](1, 1, t, 'exit')
                end
            end
        end
        if t.clb[1] then
            t.clb[1](t)
        end
    else
        t.clb(t)
    end

    if last then
        t:destroy()
        return
    end
    t.rem = t.sec
end
function timer.update(dt)
    for _, t in ipairs(timer_instances) do
        if t.paused then goto continue end

        local dt = t.tick or dt
        local toend = t.rem - dt < 0
        local df = t.f
        t.f = (t.sec - t.rem) / t.sec
        if t.isf then
            for x, c in pairs(t.clb) do
                if ty(x) ~= 'string' then
                    if (t.f >= x and df < x) or (df < x and toend) and (x ~= 0 or x ~= 1) then
                        c(t)
                    end
                else
                    local st, fi = c[2], c[3]
                    if t.f >= st and t.f <= fi then
                        local dfOut = (df<st or df>fi)
                        local relf = (fi ~= st or dfOut) and (t.f-st)/(fi-st) or 0
                        c[1](t.f, relf, t, dfOut and 'enter' or 'inside')
                    elseif (df <= fi and t.f > fi) then
                        c[1](t.f, 1, t, 'exit')
                    end
                end
            end
        end

        if toend then
            resetTimer(t)
        end
        
        t.rem = t.rem - dt

        ::continue::
    end
end

if type(ssys) == 'table' and ssys.new then
    ssys.new('timerlibupd', 'update', timer.update)
end

return timer