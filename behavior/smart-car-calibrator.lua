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
      1,
      function()
        self.calibration.acceleration = self.smart_car.car.speed
      end,
      function()
--        self.calibration.max_speed = self.speed
--        if self.speed ~= self.smart_car.car.speed then
--          self.speed = self.smart_car.car.speed
--          return 1
--        end
      end,
      function()
        self.smart_car:brake()
      end,
      5,
      function()
      end
    }
  end,


  finish = function ( self )
  end,
}
