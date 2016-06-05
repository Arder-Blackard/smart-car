require "util"
require "defines"
require "scripts.common.helpers"

local math2 = require "scripts.common.math2"
local smart_car_driver = require "scripts.smart-car.driver"
local smart_car_calibration = require "scripts.smart-car.calibration"
local smart_car_calibrators = require "scripts.smart-car.calibrators-collection"

-------------------------------------------
--- A smart car descriptor
-------------------------------------------
local smart_car = {}
smart_car.__index = smart_car

  ---
  --- Creates a new SmartCar object belonging to the 'player' from the 'car'
  ---
function smart_car:new( car, player )

  debug( "SmartCar:new(" .. tostring(car.name) .. ", " .. tostring( player ) .. ")" )

  local instance = {
    car = car,
    player = player,
    calibration = global.smart_car_calibrations[car.name],
    mark = player.surface.create_entity{ name = "mark", position = car.position, force = "neutral" },
  }

  instance.driver = smart_car_driver.new( player )
  instance.car.passenger = instance.driver.driver

  setmetatable( instance, smart_car )

  instance.tick_handler = function( event ) smart_car.tick_handler( instance, event ) end
  instance:after_calibration( function() event_manager.on_tick( 3, instance.tick_handler ) end )

  global.smart_car = instance

  return instance
end

  ---
  --- Disposes a SmartCar objects
  ---
function smart_car:dispose()
  if self.tick_handler then
    event_manager.clear_on_tick( self.tick_handler )
  end
  self.driver:dispose()
  self.mark.destroy()
end

-- --------------------------------------------------
--  Car tick_handler
-- --------------------------------------------------
function smart_car:tick_handler ( event )
  if not self.car.valid then
    global.smart_cars:remove( self )
  else

--    debug( "smart_car:tick_handler(" .. event.tick .. ")" )

    local behavior = self.behavior
    if behavior then
      behavior:update( event )
    end
    --  debug
    self.mark.teleport( math2.point_along_orientation( self.car.position, self.car.orientation, self:get_braking_distance() ) )
  end
end



---
--- Returns the delta between the car orientation and orientation to 'target_position'
---
function smart_car:get_orientation_delta( target_position )
  local target_orientation = math2.orientation( self.car.position, target_position )
  return math2.orientation_delta( self.car.orientation, target_orientation )
end

---
--- Calculates the rotation direction to turn towards the 'target_position'
---
function smart_car:get_rotation_towards( target_position )
  return math2.rotation_direction( self:get_orientation_delta( target_position ) )
end

---
--- Rotates the car towards a given position
---
function smart_car:rotate_towards( target_position )
  self.driver:turn( self:get_rotation_towards( target_position ) )
end

---
--- Gets the orientation of a car.
---
function smart_car:get_forward_orientation()
  return self.car.orientation
end

---
--- Gets the orientation of a car relative to it's motion.
---
function smart_car:get_motion_orientation()
  local car = self.car
  if car.speed < 0 then
    return math2.reverse_orientation( car.orientation )
  else
    return car.orientation
  end
end


---
--- Detects the minimal distance required for the car to stop.
---
function smart_car:get_braking_distance()
  local speed = self.car.speed
  return (speed * speed * 2 / self.calibration.braking) + self.calibration.braking_correction
end


---
--- Checks whether braking is required.
---
function smart_car:is_braking_required( distance_sqr )
  local braking_distance = self:get_braking_distance()
  return (distance_sqr <= braking_distance * braking_distance)
  --         or self:detect_obstacle( braking_distance, self:get_motion_orientation() )
end



---
---
---
function smart_car:get_closest_direction()
  local orientation = self.car.orientation
  if (orientation > 0.125 and orientation < 0.375) or (orientation > 0.625 and orientation < 0.875) then
    return defines.direction.north
  else
    return defines.direction.east
  end
end


---
--- Ensures that the car type is calibrated before executing the 'post_check_handler'.
--- If the car type is already calibrated - the handler is executed synchronously,
--- otherwise it will be executed when the relevant calibrator finishes the calibration.
---
function smart_car:after_calibration( post_check_handler )
  if self.calibration.calibration_status == smart_car_calibration.status.calibrated then
    post_check_handler()  --  instantly execute the handler and return
  else
    smart_car_calibrators:get_or_create( self ):on_calibration_finished( post_check_handler )
  end
end


---
--- Performs check for an obstacle on the car way.
---
function smart_car:detect_obstacle( check_distance, orientation )
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
end


---
--- Sets smart_car behavior
---
function smart_car:set_behavior( behavior )
  self.behavior = behavior
  if behavior then
    behavior.smart_car = self
  end
end


---
--- Module class definition
---
return {

  ---
  --- Creates a smart_car object
  ---
  new = function( car, player )
    return smart_car:new( car, player )
  end,

  ---
  --- Restores a smart_car object setting it's metatable ( after load )
  ---
  restore = function( smart_car_instance )
    setmetatable( smart_car_instance, smart_car )
    smart_car_driver:restore( smart_car_instance.driver )
    smart_car_instance.tick_handler = function( event ) smart_car.tick_handler( smart_car_instance, event ) end
    smart_car_instance:after_calibration( smart_car_instance.tick_handler )
    return smart_car_instance
  end

}
