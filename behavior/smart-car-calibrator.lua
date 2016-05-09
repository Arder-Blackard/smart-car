active_calibrators = {}

SmartCarCalibrator = {

  create = function ( self, smart_car )

    local calibrator = active_calibrators[ smart_car.car.name ]
    if calibrator then
      calibrator:dispose()
    end

    local calibrator = {
      smart_car = smart_car,
      calibration = smart_car.calibration
    }

    calibrator.calibration.calibration_status = SmartCarCalibration.status.calibrating

    self.__index = self
    return setmetatable( calibrator, self )
  end,

  ---
  --- Starts calibrating sequence
  ---
  start = function ( self )
    event_manager.execute_sequence {
      --  Test 'tank_driving' property
      function()
        self.initial_orientation = self.smart_car.car.orientation
        self.smart_car:turn_left()
      end,
      5,
      function()
        self.calibration.tank_driving = not ( self.initial_orientation == self.smart_car.car.orientation )
        self.smart_car:turn_right()
      end,
      5,
      function()
        self.smart_car:brake()
      end,
      --  Test 'acceleration' property
      function()
        self.smart_car:accelerate()
      end,
      4,
      function()
        self.calibration.acceleration = self.smart_car.car.speed / 4
      end,
      4,
      function()
        self.initial_speed = self.smart_car.car.speed
        self.smart_car:brake()
      end,
      4,
      function()
        self.calibration.braking = (self.initial_speed - self.smart_car.car.speed) / 4
      end,
    }
  end,
}
