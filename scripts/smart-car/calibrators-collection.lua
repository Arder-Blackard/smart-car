local smart_car_calibrator = require "scripts.smart-car.calibrator"

----------------------------------------------
--- Contains all car calibrators
----------------------------------------------
local smart_car_calibrators_collection = {}
smart_car_calibrators_collection.__index = smart_car_calibrators_collection

---
--- Gets existing or creates a new car calibrator
---
function smart_car_calibrators_collection:get_or_create( smart_car )
  local calibrator = self[ smart_car.car.name ]
  if not calibrator then
    calibrator = smart_car_calibrator.new( smart_car )
    calibrator:start()
    self[smart_car] = calibrator
  end
  return calibrator
end

if not global.smart_car_calibrators then
  global.smart_car_calibrators = {}
end

return setmetatable( global.smart_car_calibrators, smart_car_calibrators_collection )
