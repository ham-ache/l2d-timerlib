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
![ezgif-6df75baf9aebb8](https://github.com/user-attachments/assets/0c4c18f8-5f6a-4dd8-a95b-8274ae30ff29)
(ignore gif lags)