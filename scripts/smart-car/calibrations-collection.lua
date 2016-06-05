local smart_car_calibration = require "scripts.smart-car.calibration"

local smart_car_calibrations_collection = {}
smart_car_calibrations_collection.__index = smart_car_calibrations_collection

---
--- Creates and returns a new calibration object.
--- Will be called only if the respecting object hasn't been already created
---
function smart_car_calibrations_collection.__index( table, car_name )

  debug( "smart_car_calibrations_collection.__index(" .. tostring( car_name ) .. ") " )

  local calibration = smart_car_calibration.new( car_name )
  table[car_name] = calibration
  return calibration
end

----------------------------------------------
--- Contains all known car calibrations
----------------------------------------------

if not global.smart_car_calibrations then
  global.smart_car_calibrations = {}
end

return setmetatable( global.smart_car_calibrations, smart_car_calibrations_collection )
