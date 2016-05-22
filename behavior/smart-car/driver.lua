require "defines"

SmartCarDriver = {

  ---
  --- Creates a SmartCarDriver object
  ---
  new = function ( self, player )

    local instance = {
      driver = player.surface.create_entity {
        name = "smart-car-driver",
        position = player.position,
        force = player.force
      }
    }

    self.__index = self
     return setmetatable( instance, self )
  end,

  ---
  --- Restores SmartCarDriver object setting it's metatable (after load)
  ---
  restore = function( self, smart_car_driver )
    self.__index = self
    return setmetatable( smart_car_driver, self )
  end,

  ---
  --- Destroys SmartCarDriver object
  ---
  dispose = function( self )
    self.driver.destroy()
  end,

  ---
  --- Sets car riding state
  ---
  ride = function( self, acceleration, direction )
    self.driver.riding_state = {
      acceleration = acceleration or defines.riding.acceleration.accelerating,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Accelerates the car forward
  ---
  accelerate = function( self, direction )
    return self:ride( defines.riding.acceleration.accelerating, direction )
  end,

  ---
  --- Brakes the car
  ---
  brake = function( self, direction )
    return self:ride( defines.riding.acceleration.braking, direction )
  end,

  ---
  --- Runs the car backwards
  ---
  reverse = function( self, direction )
    return self:ride( defines.riding.acceleration.reversing, direction )
  end,

  ---
  --- Turns off the engine
  ---
  coast = function( self, direction )
    return self:ride( defines.riding.acceleration.nothing, direction )
  end,

  ---
  --- Turns weels to a given direction keeping current accelerating status
  ---
  turn = function( self, direction )
    return self:ride( self.driver.riding_state.acceleration, direction )
  end,

  ---
  --- Turns weels left keeping current accelerating status
  ---
  turn_left = function( self )
    return self:turn( defines.riding.direction.left )
  end,

  ---
  --- Turns weels right keeping current accelerating status
  ---
  turn_right = function( self )
    return self:turn( defines.riding.direction.right )
  end,
}
