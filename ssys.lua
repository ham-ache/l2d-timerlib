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

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- used neccessary parts of Tieske's binary heap (https://github.com/Tieske) --
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

local sceneHeap = {}
sceneHeap.__index = sceneHeap

local function newHeap()
  local heap = setmetatable({
    scenes = {},
    orders = {},
    sOrder = {},
  }, sceneHeap)
  return heap
end

local function swap(self, a, b)
  self.orders[a], self.orders[b] = 
  self.orders[b], self.orders[a] ;
  local sA, sB = self.scenes[a], self.scenes[b]
  self.scenes[a], self.scenes[b] = sB, sA
  self.sOrder[sA] = b
  self.sOrder[sB] = a
end

local function float(self, pos)
  while pos > 1 do
    local parent = mathFloor(pos/2)
    if self.orders[pos] > self.orders[parent] then break end
    swap(self, pos, parent)
    pos = parent
  end
end

local function push(self, sceneName, order)
  if self.sOrder[sceneName] then return end
  local pos = #self.orders + 1
  self.sOrder[sceneName] = pos
  self.scenes[pos] = sceneName
  self.orders[pos] = order or 0
  float(self, pos)
end

local function remove(self, pos)
  if pos == nil then return end
  local last = #self.orders
  if pos > last then return end
  local v = self.orders[pos]
  self.sOrder[self.scenes[pos]] = nil
  if pos < last then
    swap(self, last, pos)
    float(self, pos)
    while true do -- sink
      local min = pos
      local child = pos*2
      for c = child, child + 1 do
        if c <= last and self.orders[c] < self.orders[min] then min = c end
      end
      if min == pos then break end
      swap(self, pos, min)
      pos = min
    end
  end
  self.orders[last] = nil
  return v
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

local heapStack = setmetatable({}, {
  __index = function(t, key)
    local new = newHeap()
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
  push(heapStack[event], sceneName, order or 0)
end 

local function rem(sceneName, event)
  scenes[event][sceneName] = nil
  remove(heapStack[event], heapStack[event].sOrder[sceneName])
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

local function clear(event)
  heapStack[event] = nil
  scenes[event] = nil
end

local function overrideL2D()
  for x = 1, #l2d_override do
    local name = l2d_override[x]
    love[name] = function(...)
      call(name, ...)
    end
  end
end

local function fetchScenes()
  return scenes
end

local function fetchEventsHeap()
  return heapStack
end

return {
  new = new,
  rem = rem,
  call = call,
  clear = clear,
  overrideL2D = overrideL2D,
  scenes = fetchScenes,
  eventsHeap = fetchEventsHeap
}