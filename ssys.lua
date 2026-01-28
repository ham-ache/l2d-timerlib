-- 'Scene Systems' Cross-file callbacks library by hamache | Github: @ham-ache

local autoArray = {
    'draw',
    'load',
    'lowmemory',
    'quit',
    'threaderror',
    'update',
    'directorydropped',
    'displayrotated',
    'filedropped',
    'focus',
    'mousefocus',
    'resize',
    'visible',
    'keypressed',
    'keyreleased',
    'textedited',
    'textinput',
    'mousemoved',
    'mousepressed',
    'mousereleased',
    'wheelmoved',
    'gamepadaxis',
    'gamepadpressed',
    'gamepadreleased',
    'joystickadded',
    'joystickaxis',
    'joystickhat',
    'joystickpressed',
    'joystickreleased',
    'joystickremoved',
    'touchmoved',
    'touchpressed',
    'touchreleased',
}

local sortcacher = setmetatable({}, { -- sort results cache
    __mode = 'k', -- weak keys
    __index = function(t, key)
        local new = {}
        rawset(t, key, new)
        return new
    end, -- nonexistent table index is created in case there is not
})

local function opairs(tbl)
    local SORTED = sortcacher[tbl]
    if not SORTED or next(SORTED) == nil then
        SORTED = {}
        for x, t in pairs(tbl) do
            if t._order ~= nil then
                table.insert(SORTED, {t, x, t._order})
            end
        end
        table.sort(SORTED, function(a, b) return a[3] < b[3] end)
        sortcacher[tbl] = SORTED
    end

    local id = 0
    local len = #SORTED
    return function()
        id = id + 1
        if id > len then return end
        return SORTED[id][2], SORTED[id][1]
    end
end

local scenes = setmetatable({},  {
    __index = function(t, key)
        local new = {}
        rawset(t, key, new)
        return new
    end,
})

---@class ssys
local ssys = {
    ---Creates a new scene
    ---@param sName any Scene Identifier
    ---@param toOverride string Callback Name
    ---@param func function Your function
    ---@param order number? Order
    ---@param condition function? Condition on which scene will execute
    new = function(sName, toOverride, func, order, funcif)
        assert(type(toOverride) == 'string', 'ssys.new [2nd arg]: string expected')
        assert(type(func) == 'function', 'ssys.new [3rd arg]: function expected')
        scenes[toOverride][sName] = {func, _order = order or 0, funcif = funcif}
        sortcacher[scenes[toOverride]] = nil
        return scenes[toOverride][sName]
    end,
    ---Removes a scene
    ---@param sName any Scene Identifier
    ---@param toOverride string Callback Name
    rem = function(sName, toOverride)
        assert(type(toOverride) == 'string', 'ssys.rem [2nd arg]: string expected')
        scenes[toOverride][sName] = nil
        sortcacher[scenes[toOverride]] = nil
    end,
    ---Call scenes in a custom callback
    ---@param toOverride string Callback Name
    ---@param args ... Any passed arguments
    call = function(toOverride, ...)
        for _, params in opairs(scenes[toOverride]) do
            if (params.funcif and params.funcif()) or not params.funcif then 
                params[1](...)
            end
        end
    end,
    ---Get scene data
    ---@param sName any Scene Identifier
    ---@param toOverride string Callback Name
    data = function(sName, toOverride)
        local targ = scenes[toOverride][sName]
        if not targ then return end
        return {
            func = targ[1],
            order = targ._order,
        }
    end,
}

for _, name in ipairs(autoArray) do
    love[name] = function(...)
        ssys.call(name, ...)
    end
end
return ssys