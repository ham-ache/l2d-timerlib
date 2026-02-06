-- 'Scene Systems' Cross-file callbacks library by hamache | Github: @ham-ache
local _G = _G
local ipairs, type, mathFloor , assert, setmetatable, rawset = 
      ipairs, type, math.floor, assert, setmetatable, rawset
local l2d_override = {
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

----------------------------------------------
-- used neccessary parts of Tieske's binary heap (https://github.com/Tieske)

local sceneHeap = {}
sceneHeap.__index = sceneHeap

function sceneHeap.new()
  local heap = setmetatable({
    scenes = {},
    orders = {},
    sOrder = {},
  }, sceneHeap)
  return heap
end

function sceneHeap:swap(a, b)
  self.orders[a], self.orders[b] = 
  self.orders[b], self.orders[a] ;
end

function sceneHeap:float(pos)
  while pos > 1 do
    local parent = mathFloor(pos/2)
    if self.orders[pos] > self.orders[parent] then break end
    self:swap(pos, parent)
    pos = parent
  end
end

function sceneHeap:sink(pos)
  local last = #self.orders
  while true do
    local min = pos
    local child = pos*2
    for c = child, child + 1 do
      if c <= last and self.orders[c] > self.orders[min] then min = c end
    end
    if min == pos then break end
    self:swap(pos, min)
    pos = min
  end
end

function sceneHeap:push(sceneName, order)
  local pos = #self.orders + 1
  self.sOrder[sceneName] = pos
  self.scenes[pos] = sceneName
  self.orders[pos] = order or 0
  self:float(pos)
end

function sceneHeap:remove(pos)
  if pos == nil then return end
  local last = #self.orders
  local v = self.orders[pos]
  if pos < last then
    self:swap(last, pos)
    self:float(pos)
    self:sink(pos)
  end
  if pos <= last then
    self.orders[last] = nil
  end
  return v
end

-----------------------------------------------

local heapStack = setmetatable({}, {
  __index = function(t, key)
    local new = sceneHeap.new()
    rawset(t, key, new)
    return new
  end,
})
local scenes = setmetatable({}, {
  __index = function(t, key)
    local new = {}
    rawset(t, key, new)
    return new
  end,
})

local function new(sceneName, event, callback, order)
  assert(type(callback) == 'function', 'ssys.new, 3rd argument => function expected')
  scenes[event][sceneName] = callback
  heapStack[event]:push(sceneName, order or 0)
end 

local function rem(sceneName, event)
  local heap = heapStack[event]
  scenes[event][sceneName] = nil
  heap:remove(heap.sOrder[sceneName])
end

local function call(event, ...)
  local heap = heapStack[event]
  for x = 1, #heap.orders do
    local sc = heap.scenes[x]
    if not sc then break end
    if scenes[event][sc] then
      scenes[event][sc](...)
    end
  end
end

local function overrideL2D()
  for _, name in ipairs(l2d_override) do
    love[name] = function(...)
      call(name, ...)
    end
  end
end

return{
  new = new,
  rem = rem,
  call = call,
  overrideL2D = overrideL2D,
  scenes = scenes
}