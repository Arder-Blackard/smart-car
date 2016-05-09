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

  ride = function( self, acceleration, direction )
    self.driver.riding_state = {
      acceleration = acceleration or defines.riding.acceleration.accelerating,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Runs the car
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
    return math2.rotation_direction( self:get_orientation_delta( target_position ) )
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
    local direction = math2.rotation_direction( delta )
    local speed = self.car.speed

    if util.distance( self.car.position, target ) <= (speed*speed*2/self.calibration.braking) + math.abs(self.car.prototype.collision_box.left_top.y) + 2 then
      self:brake( direction )
    else
      local abs_delta = math.abs(delta)
      if abs_delta < 0.16 then
        self:accelerate( direction )
      elseif abs_delta < 0.33 then
        self:coast( direction )
      else
        self:brake( direction )
      end
    end
  end,

  car_follow = function( self )
    local target = game.player.position
    local delta = self:get_orientation_delta( target )
    local abs_delta = math.abs(delta)
    local direction = math2.rotation_direction( delta )
    local speed = self.car.speed

    if util.distance( self.car.position, target ) <= (speed*speed*2/self.calibration.braking) + math.abs(self.car.prototype.collision_box.left_top.y) + 2 then
      self:brake( direction )
    else
      if self.car.speed < 0 then
        delta = delta > 0 and 1 - delta or 1 + delta
        direction = math2.opposite_direction( math2.rotation_direction ( delta ) )
      end

      if self.car.speed == 0 then
        if abs_delta < 0.5 then
          self:accelerate( direction )
        else
          self:reverse( direction )
        end
      else
        if abs_delta < 0.16 then
          self:accelerate( direction )
        elseif abs_delta < 0.33 then
          self:coast( direction )
        else
          self:reverse( direction )
        end
      end
    end
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

