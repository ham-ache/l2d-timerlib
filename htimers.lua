-- hamache's fractional timer library for Love2D | Github: @ham-ache
local _G = _G
local pairs, ipairs, type, setmetatable, tonumber, table_remove, table_insert, assert =
      pairs, ipairs, type, setmetatable, tonumber, table.remove, table.insert, assert  

local function typeGuard(object, error_, ...)
  local objectType = type(object)
  local pass
  for _, type_ in ipairs{...} do
    if objectType == type_ then pass = true end
  end
  assert(pass, error_)
end

---@class timer
local timer = {instances = {}, update_ls = true}
timer.__index = timer

---Creates a new timer
---@param sec number time in seconds
---@param loops number|'inf' total loops
---@param clb function|table callback function or fractions
---@param tickrate number|nil independent tickrate else dt
---@return timer timer timer instance
local function newTimer(seconds, loops, callback, tickrate)
  typeGuard(seconds, 'hTimers: expected number as the first argument', 'number')
  typeGuard(loops, 'hTimers: expected number or \'inf\' as the second argument', 'number', 'string')
  typeGuard(callback, 'hTimers: expected table or function as the third argument', 'table', 'function')
  typeGuard(tickrate, 'hTimers: expected number or nil as the fourth argument', 'number', 'nil')

  local instance = setmetatable({
    len = seconds,
    elapsed = seconds,
    loops = loops,
    callback = callback,
    tickrate = tickrate,
    notsimple = (type(callback) == 'table'),
    fract = 0
  }, timer )

  if instance.notsimple and instance.callback[0] then
    instance.callback[0](instance)
  end
  table_insert(timer.instances, instance)

  return instance
end
timer.new = newTimer

local function timerDestroy(self)
  for x, t in ipairs(timer.instances) do
    if t == self then
      table_remove(timer.instances, x)
    end
  end
end
timer.destroy = timerDestroy

local function timerNewLoop(self)
  local last
  if self.loops ~= 'inf' then
    self.loops = self.loops - 1
    last = self.loops <= 0
  end
  if self.notsimple then
    if self.callback[0] and not last then self.callback[0](self) end
    for fract, callback in pairs(self.callback) do
      if type(fract) ~= 'table' then goto skip end
      local start, finish = fract[1], fract[2]
      if start == 0 and not last then
        callback(0, 0, self, 'enter')
      end
      if finish == 1 then
        callback(1, 1, self, 'enter')
      end
      ::skip::
    end
  else
    self.callback(self)
  end
  if self.loops ~= 'inf' and self.loops <= 0 then self:destroy() end
  self.elapsed = self.len
end
timer.newLoop = timerNewLoop

local function timerUpdate(self, dt)
  if self.tickrate then dt = self.tickrate end
  local toLoop = dt > self.elapsed
  local deltaFract = self.fract
  
  self.fract = 1 - self.elapsed/self.len
  if self.notsimple then
    for fract, callback in pairs(self.callback) do
      if type(fract) == 'table' then
        local start, finish = fract[1], fract[2]
        if self.fract >= start and self.fract <= finish then
          local deltaOut = (deltaFract < start or deltaFract > finish)
          local normFract = (deltaOut or finish ~= start) and (self.fract - start)/(finish - start) or 0
          callback(self.fract, normFract, self, deltaOut and 'enter' or 'inside')
        elseif (deltaFract <= finish and self.fract > finish) then
          callback(self.fract, 1, self, 'exit')
        end
      elseif
        (self.fract >= fract and deltaFract < fract)
        or
        (deltaFract < fract and toLoop)
        and x ~= 0
        and x ~= 1
      then
          callback(self)
      end
    end
  end

  self.elapsed = self.elapsed - dt
  if toLoop then timerNewLoop(self) end
end
timer.update = timerUpdate

local function l2d_ssys_init(ssys, as, order)
  local ssys = ssys or _G.ssys
  if not ssys then return end
  local name = as or 'timerLib'
  return ssys.new(name, 'update', function(dt)
    for _, t in ipairs(timer.instances) do timerUpdate(t, dt) end
  end, order, function() return timer.update_ls end)
end
timer.l2d_ssys_init = l2d_ssys_init

return timer