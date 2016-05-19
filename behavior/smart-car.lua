require "util"
require "defines"
require "common.helpers"
require "common.math2"
require "behavior.smart-car-driver"

-------------------------------------------
--- A smart car descriptor
-------------------------------------------
SmartCar = {

  mode = {
    idle = 0,
    follow = 1
  },

  ---
  --- Creates a new SmartCar object belonging to the 'player' from the 'car'
  ---
  new = function ( self, car, player )
    local smart_car = {
      mode = SmartCar.mode.idle,
      car = car,
      player = player,
      driver = SmartCarDriver:new( player ),
      calibration = global.smart_car_calibrations[car.name],

      mark = player.surface.create_entity{ name = "mark", position = car.position, force = "neutral" },
      collision_boxes = {},
    }

    smart_car.car.passenger = smart_car.driver.driver

    self.__index = self
    return setmetatable( smart_car, self )
  end,

  ---
  --- Restores SmartCar object setting it's metatable (after load)
  ---
  restore = function( self, smart_car)
    SmartCarDriver:restore( smart_car.driver )
    self.__index = self
    return setmetatable( smart_car, self )
  end,

  ---
  --- Disposes a SmartCar objects
  ---
  dispose = function ( self )
    self.driver:dispose()
    self.mark.destroy()
    if self.tick_handler then
      event_manager.clear_on_tick( self.tick_handler )
    end
  end,

  -- --------------------------------------------------
  --  Car control operations
  -- --------------------------------------------------


  ---
  --- Returns the delta between the car orientation and orientation to 'target_position'
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
  --- Rotates the car towards a given position
  ---
  rotate_towards = function ( self, target_position )
    self.driver:turn( self:get_rotation_towards( target_position ) )
  end,

  ---
  --- Gets the orientation of a car.
  ---
  get_forward_orientation = function ( self )
    return self.car.orientation
  end,

  ---
  --- Gets the orientation of a car relative to it's motion.
  ---
  get_motion_orientation = function ( self )
    local car = self.car
    if car.speed < 0 then
      return math2.reverse_orientation( car.orientation )
    else
      return car.orientation
    end
  end,


  ---
  --- Detects the minimal distance required for the car to stop.
  ---
  get_braking_distance = function( self )
    local speed = self.car.speed
    return (speed * speed * 2 / self.calibration.braking) + self.calibration.braking_correction
  end,


  ---
  ---
  ---
  get_closest_direction = function( self )
    local orientation = self.car.orientation
    if (orientation > 0.125 and orientation < 0.375) or (orientation > 0.625 and orientation < 0.875) then
      return defines.direction.north
    else
      return defines.direction.east
    end
  end,

  -- --------------------------------------------------
  --  Car behavior operations
  -- --------------------------------------------------


  ---
  --- Ensures that the car type is calibrated before executing the 'post_check_handler'.
  --- If the car type is already calibrated - the handler is executed synchronously,
  --- otherwise it will be executed when the relevant calibrator finishes the calibration.
  ---
  after_calibration = function ( self, post_check_handler )
    if self.calibration.calibration_status == SmartCarCalibration.status.calibrated then
      post_check_handler()  --  instantly execute the handler and return
    else
      SmartCarCalibratorsCollection:get_or_create( self ):on_calibration_finished( post_check_handler )
    end
  end,


  ---
  ---
  ---
  move_towards_point = function()

    -- first check the forward direction


  end,


  ---
  --- Performs check for an obstacle on the car way.
  ---
  detect_obstacle = function ( self, check_distance, orientation )
    local car = self.car
    if car.speed == 0 then
      return false
    end
    local braking_distance = check_distance or self:get_braking_distance()
    orientation = orientation or car.orientation
    return not car.surface.can_place_entity {
      name = car.name,
      position = math2.point_along_orientation( car.position, orientation, braking_distance ),
      force = car.force
    }
  end,

  ---
  --- Checks whether braking is required.
  ---
  is_braking_required = function( self, distance_sqr )
    local braking_distance = self:get_braking_distance()
    return (distance_sqr <= braking_distance * braking_distance)
           or self:detect_obstacle( braking_distance, self:get_motion_orientation() )
  end,

  ---
  --- 'Tanks' following logic
  ---
  tank_follow = function( self )
    local delta = self:get_orientation_delta( self.target.position )
    local direction = math2.rotation_direction( delta )

    if self:is_braking_required( math2.distance_sqr( self.car.position, self.target.position ) ) then
      self.driver:brake( direction )
    else
      local abs_delta = math.abs(delta)
      if abs_delta < 0.16 then
        self.driver:accelerate( direction )
      elseif abs_delta < 0.33 then
        self.driver:coast( direction )
      else
        self.driver:brake( direction )
      end
    end
  end,

  ---
  --- 'Cars' following logic
  ---
  car_follow = function( self )
    local delta = self:get_orientation_delta( self.target.position )
    local forward_direction = math2.rotation_direction( delta )
    local car = self.car

    if self:is_braking_required( math2.distance_sqr( car.position, self.target.position ) ) then
      self.driver:brake( forward_direction )
    else
      local motion_direction = forward_direction
      local abs_delta = math.abs( delta )

      if car.speed < 0 then
        delta = delta > 0 and 1 - delta or 1 + delta
        motion_direction = math2.opposite_direction( math2.rotation_direction ( delta ) )
      end

      if car.speed == 0 then
        if abs_delta < 0.5 then
          self.driver:accelerate( forward_direction )
        else
          self.driver:reverse( motion_direction )
        end
      else
        if abs_delta < 0.16 then
          self.driver:accelerate( forward_direction )
        elseif abs_delta < 0.33 then
          self.driver:coast( motion_direction )
        else
          self.driver:reverse( motion_direction )
        end
      end
    end
  end,

  ---
  --- 'Tanks' following logic
  ---
  enable_follow_mode = function ( self )
    self.target = self.player

    self:after_calibration(
      function ()
        local handler = self.calibration.tank_driving and self.tank_follow or self.car_follow
        self.tick_handler = event_manager.on_tick(
          5,
          function()
            if not self.car.valid then
              global.smart_cars:remove( self )
              return
            end
            handler( self )
            self.mark.teleport( math2.point_along_orientation( self.car.position, self.car.orientation, self:get_braking_distance() ) )
          end
        )
      end
    )
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

