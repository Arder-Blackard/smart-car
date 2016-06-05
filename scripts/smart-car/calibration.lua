require "defines"
require "scripts.common.helpers"

----------------------------------------------
--- Stores a car movement characteristics
----------------------------------------------
local smart_car_calibration = {
  status = {
    not_calibrated = 1,
    calibrating = 2,
    calibrated = 3
  },
}

---
--- Creates a new SmartCarCalibration object for the 'car_name'
---
function smart_car_calibration.new( car_name )
  debug( "SmartCarCalibration:new(" .. tostring( car_name ) .. ") " )
  return {
    car_name = car_name,
    braking_correction = math.abs( game.entity_prototypes[car_name].collision_box.left_top.y ) + 2,
    calibration_status = smart_car_calibration.status.not_calibrated
  }
end

return smart_car_calibration
