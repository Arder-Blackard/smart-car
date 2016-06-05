local math2 = require "scripts.common.math2"


local smart_car_behavior = {}
smart_car_behavior.__index = smart_car_behavior

---
--- Implement moving to a point in a tank-specific manner
---
function smart_car_behavior:tank_go_to_point( point, stop_at_point, turn_angle )

  local smart_car = self.smart_car

  local orientation_delta = smart_car:get_orientation_delta( point )
  local rotation_direction = math2.rotation_direction( orientation_delta )

  local point_distance = math2.distance(smart_car.car.position, point)
  local braking_distance = smart_car:get_braking_distance()

  local speed = smart_car.car.speed
  if not stop_at_point then
    if turn_angle / smart_car.calibration.rotation > point_distance / speed then
      return true
    end
  else
    if braking_distance > point_distance then
      --  Start braking
      smart_car.driver:brake( rotation_direction )
      return speed == 0
    end
  end

  --  Keep moving and turn to the target
  local abs_delta = math.abs( orientation_delta )
  if abs_delta < 0.16 then
    smart_car.driver:accelerate( rotation_direction )
  elseif abs_delta < 0.33 then
    smart_car.driver:coast( rotation_direction )
  else
    smart_car.driver:brake( rotation_direction )
  end

  return false
end


---
--- Implement moving to a point in a car-specific manner
---
function smart_car_behavior:car_go_to_point( point, stop_at_point, turn_angle )

  local smart_car = self.smart_car
  local car = smart_car.car
  local orientation_delta = smart_car:get_orientation_delta( point )
  local forward_direction = math2.rotation_direction( orientation_delta )

  local point_distance = math2.distance(smart_car.car.position, point)
  local braking_distance = smart_car:get_braking_distance()

  if braking_distance > point_distance then
    smart_car.driver:brake( forward_direction )
    if not stop_at_point and ( turn_angle / smart_car.calibration.rotation <= braking_distance ) then
      return true
    elseif smart_car.car.speed == 0 then
      return true
    end
  else
    local motion_direction = forward_direction
    local abs_delta = math.abs( orientation_delta )

    if car.speed < 0 then
      orientation_delta = orientation_delta > 0 and 1 - orientation_delta or 1 + orientation_delta
      motion_direction = math2.opposite_direction( math2.rotation_direction (orientation_delta) )
    end

    if car.speed == 0 then
      if abs_delta < 0.5 then
        smart_car.driver:accelerate( forward_direction )
      else
        smart_car.driver:reverse( motion_direction )
      end
    else
      if abs_delta < 0.16 then
        smart_car.driver:accelerate( forward_direction )
      elseif abs_delta < 0.33 then
        smart_car.driver:coast( motion_direction )
      else
        smart_car.driver:reverse( motion_direction )
      end
    end
  end

  return false

end


---
--- Implement moving to a point
---
function smart_car_behavior:go_to_point( point, stop_at_point, turn_angle )
  if self.smart_car.calibration.tank_driving then
    return self:tank_go_to_point( point, stop_at_point, turn_angle )
  else
    return self:car_go_to_point( point, stop_at_point, turn_angle )
  end
end


---
---
---
function smart_car_behavior:update( event )

  local smart_car = self.smart_car
  local path = self.path

  if not smart_car or not path then
    return
  end

  local point = path:get_current_point()

  local result = self:go_to_point( point, point.type == 1, point.angle or 0 )

  if result then
    path:goto_next_point()
    if path:is_finished() then
      smart_car:set_behavior( nil )
    end
  end
end


return {
  new = function( type, path )
    return setmetatable( { type = type, path = path }, smart_car_behavior )
  end
}
