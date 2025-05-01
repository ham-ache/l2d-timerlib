# hamache's timers
### a love2d timer library which supports both fractional and simple timers
**depends on ssys (included) and includes easing library**

## Functions:
### `timer.new(sec, loops, clb) -> timer`
- creates a new timer. loops can be an int higher than one or 'inf'

- clb can be either a function, either a table depending if you want simple or fractional timers

---

### `timer:destroy() -> void`

- destroys a timer

---

### `timer:pause(paused) -> bool`

- pauses a timer, return the state

- **timer remains unchanged if paused is nil**
## Examples:
### simple:
```lua
timer.new(1, 5, function(timer)
  --your func
end)
```
### fractional:
```lua
timer.new(1, 5, {
  [0.66] = function(fraction, timer)
    --your func when timer hits 66%
  end,
  ['0.7-0.8'] = function(fraction, relativefrac)
    --your func while timer's fraction is in range between 70% and 80%
    --relativefrac is relative to the range
  end
})
```
### pausing:
```lua
local timer = timer.new(1, 1, func)
local paused = timer:pause()
timer:pause(not paused)
```

## Preview (main.lua, easing out elastic)
![ezgif-63b7a1e3b97751](https://github.com/user-attachments/assets/71f66f9b-f1ce-4ebf-8cb2-58d961ed8469)
