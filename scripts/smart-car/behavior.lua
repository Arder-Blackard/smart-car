local smart_car_behavior = {}
smart_car_behavior.__index = smart_car_behavior

---
---
---
function smart_car_behavior:update( event )

  local smart_car = self.smart_car
  local path = self.path

  if not smart_car or not path then
    return
  end

  local next_point = path:get_current_target()



--[[
  if smart_car.calibration.tank_driving then

    local delta = smart_car:get_orientation_delta( self.target.position )
    local direction = math2.rotation_direction( delta )

    if smart_car:is_braking_required( math2.distance_sqr( smart_car.car.position, smart_car.target.position ) ) then
      smart_car.driver:brake( direction )
    else
      local abs_delta = math.abs(delta)
      if abs_delta < 0.16 then
        smart_car.driver:accelerate( direction )
      elseif abs_delta < 0.33 then
        smart_car.driver:coast( direction )
      else
        smart_car.driver:brake( direction )
      end
    end

  else

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


  end
]]

end


return {
  new = function( type, path )
    global.smart_car = setmetatable( { path = path }, smart_car_behavior )
    return global.smart_car
  end
}
