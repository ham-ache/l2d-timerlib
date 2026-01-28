local _G = _G
local timer = require 'htimers'
local ssys = require 'ssys'
local ease = require 'ease'

--[[
io.write(os.clock()) -- benchmark: startup
io.flush()
]]

-- example
-- using ssys for love2d
-- ssys is not neccessary for timers to work

local globalposx, globalposy = 0, 0
timer.l2d_ssys_init(ssys)

ssys.new('main', 'load', function()
  local start = 0.5

  local mx, my = 0, 0
  local posx, posy = 0, 0

  --[[
    for _ = 1, 1e6 do -- benchmark: spawn and delete 1000000 timers
      local sample = timer.new(1, 0, function() end)
      sample:destroy()
    end
    io.write('\n', os.clock()) -- benchmark: check
    io.flush()
  ]] -- the results are usually ~ 0.3s

  timer.new(1, 'inf', {
    [0.35] = function()
      mx, my = love.mouse.getPosition()
    end,
    [{0.35, 1}] = function(_, relf)
      globalposx = ease.lerp(posx, mx, ease.back.io(relf))
      globalposy = ease.lerp(posy, my, ease.back.io(relf))
    end,
    [1] = function()
      posx, posy = mx, my
    end
  })
end)
ssys.new('main', 'mousepressed', function()
  timer.update_ls = false
end)
ssys.new('main', 'mousereleased', function()
  timer.update_ls = true
end)
ssys.new('main', 'draw', function()
  love.graphics.circle('fill', globalposx, globalposy, 3)
end)