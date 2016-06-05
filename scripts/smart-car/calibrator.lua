local SmartCarCalibration = require "scripts.smart-car.calibration"

local smart_car_calibrator = { post_calibration_handlers = {} }
smart_car_calibrator.__index = smart_car_calibrator

  ---
  --- Starts calibrating sequence
  ---
function smart_car_calibrator:start()

  event_manager.execute_coroutine (
    function()

      local initial_orientation = self.smart_car.car.orientation
      self.smart_car.driver:turn_left()
      coroutine.yield( 5 )

      --  Test 'tank_driving' property
      if initial_orientation ~= self.smart_car.car.orientation then
        self.calibration.tank_driving = true
        self.calibration.rotation = math.abs( self.smart_car.car.orientation - initial_orientation )
      else
        self.calibration.tank_driving = false
      end

      self.smart_car.driver:turn_right()
      coroutine.yield( 5 )

      self.smart_car.driver:brake()
      coroutine.yield()

      self.smart_car.driver:accelerate()
      coroutine.yield( 4 )

      --  Test acceleration estimate
      self.calibration.acceleration = self.smart_car.car.speed / 4
      if not self.calibration.tank_driving then
        self.smart_car.driver:turn_left()
      end
      coroutine.yield( 4 )

      if not self.calibration.tank_driving then
        self.calibration.rotation = math.abs( self.smart_car.car.orientation - initial_orientation )
      end
      self.initial_speed = self.smart_car.car.speed
      self.smart_car.driver:brake()
      coroutine.yield( 4 )

      --  Test braking estimate
      self.calibration.braking = (self.initial_speed - self.smart_car.car.speed) / 4
      coroutine.yield( 4 )

      self.calibration.calibration_status = SmartCarCalibration.status.calibrated
      for _, handler in ipairs( self.post_calibration_handlers ) do
        handler()
      end
      self.post_calibration_handlers = {}
    end
  )
end


function smart_car_calibrator:on_calibration_finished( handler )
  if self.calibration.calibration_status ~= SmartCarCalibration.status.calibrated then
    table.insert( self.post_calibration_handlers, handler )
  else
    handler()
  end
end

---
--- Module class definition
---
return {

  new = function( smart_car )
    local instance = { smart_car = smart_car, calibration = smart_car.calibration }
    instance.calibration.calibration_status = SmartCarCalibration.status.calibrating
    return setmetatable( instance, smart_car_calibrator )
  end

}
