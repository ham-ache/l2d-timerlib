-- 'Scene Systems' Cross-file callbacks library by hamache

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

local rs = rawset
local ti = table.insert
local ts = table.sort

local _METAVALID  = setmetatable({}, { __mode = 'k' }) -- meta validator, weak keys
local function setResetter(tbl, saver, name, valdefault) -- resetter function, compatible with other __newindex
    if _METAVALID[tbl] then return end -- if already checked, do nothing
    local meta = getmetatable(tbl)
    if not meta then -- if no metatable, create new
        setmetatable(tbl, {})
        meta = getmetatable(tbl)
    end
    local old = meta.__newindex or rs
    meta.__newindex = function(t, key, val) -- wrap the function or create new __newindex for already existing metatable
        saver[t][name] = valdefault
        old(t, key, val)
    end
    _METAVALID[tbl] = true -- validate
end

local _SORTCACHER = setmetatable({}, { -- sort results cache
    __mode = 'k', -- weak keys
    __index = function(t, key)
        local new = {}
        rs(t, key, new)
        return new
    end, -- nonexistent table index is created in case there is not
})
local sortfunc = { -- sort functions, used in opairs
    _SORTRES = function(tbl) -- manual sort
        local SORTED = {}
        for x, t in pairs(tbl) do
            if t._order ~= nil then
                ti(SORTED, {t, x, t._order})
            end
        end
        ts(SORTED, function(a, b) return a[3] < b[3] end)
        return SORTED
    end,
    _SORTRESABC = function(tbl) -- alphabetic sort
        local SORTED = {}
        for x, t in pairs(tbl) do
            ti(SORTED, {t, x})
        end
        ts(SORTED, function(a, b) return a[2] < b[2] end)
        return SORTED
    end
}
local function opairs(tbl, alphabetic_sort)
    local cur_sort = alphabetic_sort and '_SORTRESABC' or '_SORTRES'
    local id = 0
    local SORTED = {}

    setResetter(tbl, _SORTCACHER, cur_sort)
    if _SORTCACHER[tbl][cur_sort] ~= nil then
        SORTED = _SORTCACHER[tbl][cur_sort]
    else
        SORTED = sortfunc[cur_sort](tbl)
        _SORTCACHER[tbl][cur_sort] = SORTED
    end
    return function()
        id = id + 1
        if not SORTED[id] then return end
        return SORTED[id][2], SORTED[id][1]
    end
end

local scenes = setmetatable({},  {
    __index = function(t, key)
        local new = {}
        rs(t, key, new)
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
    new = function(sName, toOverride, func, order)
        assert(type(toOverride) == 'string', 'ssys.new [2nd arg]: string expected')
        assert(type(func) == 'function', 'ssys.new [3rd arg]: function expected')
        scenes[toOverride][sName] = {func, _order = order or 0}
        _SORTCACHER[scenes[toOverride]]['_SORTRES'] = nil
    end,
    ---Removes a scene
    ---@param sName any Scene Identifier
    ---@param toOverride string Callback Name
    rem = function(sName, toOverride)
        assert(type(toOverride) == 'string', 'ssys.rem [2nd arg]: string expected')
        scenes[toOverride][sName] = nil
        _SORTCACHER[scenes[toOverride]]['_SORTRES'] = nil
    end,
    ---Call scenes in a custom callback
    ---@param toOverride string Callback Name
    ---@param args ... Any passed arguments
    call = function(toOverride, ...)
        for _, params in opairs(scenes[toOverride]) do
            params[1](...)
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
            order = targ._order
        }
    end,
}

for _, name in ipairs(autoArray) do
    love[name] = function(...)
        ssys.call(name, ...)
    end
end
return ssys