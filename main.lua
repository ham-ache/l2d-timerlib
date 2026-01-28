local _G = _G
local ssys = require 'ssys'
local timer = require 'timers2'
local ease = require 'ease'

-- example
-- using ssys for love2d
-- ssys is not neccessary for timers to work

local globalposx, globalposy = 0, 0
timer.l2d_ssys_init(ssys)

ssys.new('main', 'load', function()
  local start = 0.5

  local mx, my = 0, 0
  local posx, posy = 0, 0

  timer.new(1, 'inf', {
    [0.35] = function()
      mx, my = love.mouse.getPosition()
    end,
    [{0.35, 0.75}] = function(_, relf)
      globalposx = ease.lerp(posx, mx, ease.back.io(relf))
      globalposy = ease.lerp(posy, my, ease.back.io(relf))
    end,
    [1] = function()
      posx, posy = mx, my
    end
  })
end)
ssys.new('main', 'draw', function()
  love.graphics.circle('fill', globalposx, globalposy, 3)
end)