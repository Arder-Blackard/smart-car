require "defines"

local smart_car_driver = {}
smart_car_driver.__index = smart_car_driver

---
--- Restores SmartCarDriver object setting it's metatable (after load)
---
function smart_car_driver:restore( smart_car_driver )
  self.__index = self
  return setmetatable( smart_car_driver, self )
end

---
--- Destroys SmartCarDriver object
---
function smart_car_driver:dispose()
  self.driver.destroy()
end

---
--- Sets car riding state
---
function smart_car_driver:ride( acceleration, direction )
  self.driver.riding_state = {
    acceleration = acceleration or defines.riding.acceleration.accelerating,
    direction = direction or defines.riding.direction.straight
  }
end

---
--- Accelerates the car forward
---
function smart_car_driver:accelerate( direction )
  return self:ride( defines.riding.acceleration.accelerating, direction )
end

---
--- Brakes the car
---
function smart_car_driver:brake( direction )
  return self:ride( defines.riding.acceleration.braking, direction )
end

---
--- Runs the car backwards
---
function smart_car_driver:reverse( direction )
  return self:ride( defines.riding.acceleration.reversing, direction )
end

---
--- Turns off the engine
---
function smart_car_driver:coast( direction )
  return self:ride( defines.riding.acceleration.nothing, direction )
end

---
--- Turns weels to a given direction keeping current accelerating status
---
function smart_car_driver:turn( direction )
  return self:ride( self.driver.riding_state.acceleration, direction )
end

---
--- Turns weels left keeping current accelerating status
---
function smart_car_driver:turn_left()
  return self:turn( defines.riding.direction.left )
end

---
--- Turns weels right keeping current accelerating status
---
function smart_car_driver:turn_right()
  return self:turn( defines.riding.direction.right )
end



return {
  ---
  --- Creates a smart_car_driver object
  ---
  new = function ( player )
    return setmetatable(
      {
        driver = player.surface.create_entity {
          name = "smart-car-driver",
          position = player.position,
          force = player.force
        },
      },
      smart_car_driver
  )
  end,

  ---
  --- Restores a smart_car_driver object
  ---
  restore = function( smart_car_driver_instance )
    return setmetatable( smart_car_driver_instance, smart_car_driver )
  end
}
