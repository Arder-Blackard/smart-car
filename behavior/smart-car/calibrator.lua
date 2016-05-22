active_calibrators = {}

SmartCarCalibrator = {

  post_calibration_handlers = {},

  new = function ( self, smart_car )

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

--[[    event_manager.execute_sequence {
      --  Test 'tank_driving' property
      function()
        self.initial_orientation = self.smart_car.car.orientation
        self.smart_car.driver:turn_left()
      end,
      5,
      function()
        self.calibration.tank_driving = not ( self.initial_orientation == self.smart_car.car.orientation )
        self.smart_car.driver:turn_right()
      end,
      5,
      function()
        self.smart_car.driver:brake()
      end,
      --  Test 'acceleration' property
      function()
        self.smart_car.driver:accelerate()
      end,
      4,
      function()
        self.calibration.acceleration = self.smart_car.car.speed / 4
      end,
      4,
      function()
        self.initial_speed = self.smart_car.car.speed
        self.smart_car.driver:brake()
      end,
      4,
      function()
        self.calibration.braking = (self.initial_speed - self.smart_car.car.speed) / 4
      end,
      4,
      function()
        self.calibration.calibration_status = SmartCarCalibration.status.calibrated
        for _, handler in ipairs( self.post_calibration_handlers ) do
          handler()
        end
        self.post_calibration_handlers = {}
      end
    }]]

    event_manager.execute_coroutine (
      --  Test 'tank_driving' property
      function()

        self.initial_orientation = self.smart_car.car.orientation
        self.smart_car.driver:turn_left()
        coroutine.yield( 5 )

        self.calibration.tank_driving = not ( self.initial_orientation == self.smart_car.car.orientation )
        self.smart_car.driver:turn_right()
        coroutine.yield( 5 )

        self.smart_car.driver:brake()
        coroutine.yield()

        self.smart_car.driver:accelerate()
        coroutine.yield( 4 )

        self.calibration.acceleration = self.smart_car.car.speed / 4
        coroutine.yield( 4 )

        self.initial_speed = self.smart_car.car.speed
        self.smart_car.driver:brake()
        coroutine.yield( 4 )

        self.calibration.braking = (self.initial_speed - self.smart_car.car.speed) / 4
        coroutine.yield( 4 )

        self.calibration.calibration_status = SmartCarCalibration.status.calibrated
        for _, handler in ipairs( self.post_calibration_handlers ) do
          handler()
        end
        self.post_calibration_handlers = {}
      end
    )
  end,

  on_calibration_finished = function( self, handler )
    if self.calibration.calibration_status ~= SmartCarCalibration.status.calibrated then
      table.insert( self.post_calibration_handlers, handler )
    else
      handler()
    end
  end
}


----------------------------------------------
--- Contains all car calibrators
----------------------------------------------
SmartCarCalibratorsCollection = {
  ---
  --- Creates a new or restores an existing SmartCarCalibratorsCollection
  ---
  new = function ( self )
    return setmetatable( self, self )
  end,

  get_or_create = function( self, smart_car )
    local calibrator = self[ smart_car.car.name ]
    if not calibrator then
      calibrator = SmartCarCalibrator:new( smart_car )
      calibrator:start()
      self[smart_car] = calibrator
    end
    return calibrator
  end

}
