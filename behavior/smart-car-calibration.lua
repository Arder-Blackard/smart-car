require "defines"
require "common.helpers"

----------------------------------------------
--- Detects a car movement characteristics
----------------------------------------------
SmartCarCalibration = {

  status = {
    not_calibrated = 1,
    calibrating = 2,
    calibrated = 3
  },

  ---
  --- Restores SmartCarCalibration object setting it's metatable (after load)
  ---
  restore = function ( self, calibration )
    if not calibration.car_name then
      return
    end
    self.__index = self
    return setmetatable( calibration, self )
  end,

  ---
  --- Creates a new SmartCarCalibration object for the 'car_name'
  ---
  create = function ( self, car_name )
    local calibration = {
      car_name = car_name,
      calibration_status = SmartCarCalibration.status.not_calibrated
    }
    self.__index = self
    return setmetatable( calibration, self )
  end
}

----------------------------------------------
--- Contains all known car calibrations
----------------------------------------------
SmartCarCalibrationsCollection = {
  ---
  --- Creates a new or restores an existing SmartCarCalibrationsCollection
  ---
  restore = function ( self, source )
    if source then
      for _, calibration in pairs( source ) do
        SmartCarCalibration:restore( calibration )
      end
    else
      source = {}
    end
    return setmetatable( source, self )
  end,

  __index = function( table, car_name)
    local calibration = SmartCarCalibration:create( car_name )
    table[car_name] = calibration
    return calibration
  end

}
