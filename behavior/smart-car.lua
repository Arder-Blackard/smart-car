require "util"
require "defines"
require "common.helpers"
require "common.math2"

-------------------------------------------
--- A smart car descriptor
-------------------------------------------
SmartCar = {

  mode = {
    idle = 0,
    follow = 1
  },

  ---
  --- Restores SmartCar object setting it's metatable (after load)
  ---
  restore = function( self, source )
    if not source.car then
      return
    end
    self.__index = self
    return setmetatable( source, self )
  end,

  ---
  --- Creates a new SmartCar object belonging to the 'player' from the 'car'
  ---
  create = function ( self, car, player )

    car.passenger = player.surface.create_entity{
      name = "smart-car-driver",
      position = car.position,
      force = player.force
    }

    local smart_car = {
      mode = SmartCar.mode.idle,
      car = car,
      player = player,
      driver = car.passenger,
      calibration = global.smart_car_calibrations[car.name]
    }

    self.__index = self
    return setmetatable( smart_car, self )
  end,

  destroy = function ( self )
    self.driver.destroy()
    if self.tick_handler then
      event_manager.clear_on_tick( self.tick_handler )
    end
  end,

  -- --------------------------------------------------
  --  Car control operations
  -- --------------------------------------------------

  ---
  --- Runs the car
  ---
  accelerate = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.accelerating,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Brakes the car
  ---
  brake = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.braking,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Runs the car backwards
  ---
  reverse = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.reversing,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Turns off the engine
  ---
  coast = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.nothing,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Turns weels to a given direction keeping current accelerating status
  ---
  turn = function( self, direction )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = direction
    }
  end,

  ---
  --- Turns weels left keeping current accelerating status
  ---
  turn_left = function( self )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = defines.riding.direction.left
    }
  end,

  ---
  --- Turns weels right keeping current accelerating status
  ---
  turn_right = function( self )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = defines.riding.direction.right
    }
  end,

  ---
  --- Turns weels straight keeping current accelerating status
  ---
  keep_straight = function( self )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = defines.riding.direction.straight
    }
  end,

  ---
  --- Returns the delta between the car orientation and
  ---
  get_orientation_delta = function( self, target_position )
    local target_orientation = math2.orientation( self.car.position, target_position )
    return math2.orientation_delta( self.car.orientation, target_orientation )
  end,

  ---
  --- Calculates the rotation direction to turn towards the 'target_position'
  ---
  get_rotation_towards = function( self, target_position )
    return math2.get_rotation_direction( self:get_orientation_delta( target_position ) )
  end,

  ---
  --- Rotates the car to a given point
  ---
  rotate_towards = function ( self, target_position )
    self:turn( self:get_rotation_towards( target_position ) )
  end,

  -- --------------------------------------------------
  --  Car behavior operations
  -- --------------------------------------------------

  tank_follow = function( self )

    local target = game.player.position
    local delta = self:get_orientation_delta( target )
    local abs_delta = math.abs(delta)
    local direction = math2.get_rotation_direction( delta )

    if abs_delta < 0.16 then
      self:accelerate( direction )
    elseif abs_delta < 0.33 then
      self:coast( direction )
    else
      self:brake( direction )
    end
  end,

  car_follow = function( self )
    local direction = self:get_rotation_towards( game.player.position )
    self:accelerate( direction )
  end,

  enable_follow_mode = function ( self )
    self.target = self.player
    local handler = self.calibration.tank_driving and self.tank_follow or self.car_follow
    self.tick_handler = event_manager.on_tick( 2, function() handler( self ) end )
  end,

  set_mode = function( self, mode )
    if self.tick_handler then
      event_manager.clear_on_tick( self.tick_handler )
    end
    self.mode = mode
    prnt( "Setting mode to " .. self.mode )
    if mode == SmartCar.mode.follow then
      self:enable_follow_mode()
    end
  end
}

