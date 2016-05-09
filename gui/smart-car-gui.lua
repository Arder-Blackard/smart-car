require "defines"
require "common.helpers"
require "common.event-manager"
require "behavior.smart-car-calibration"
require "behavior.smart-car-calibrator"
require "common.math2"

local function format_bool_string( value )
  if value == nil then
    return "unknown"
  elseif value == false then
    return "false"
  else
    return "true"
  end
end

local function format_calibration_status( status )
  if status == SmartCarCalibration.status.calibrated then
    return "calibrated"
  elseif status == SmartCarCalibration.status.not_calibrated then
    return "not calibrated"
  elseif status == SmartCarCalibration.status.calibrating then
    return "calibrating..."
  else
    return "unknown"
  end
end

local function format_per_tick_value( acceleration )
  if not acceleration then
    return "unknown"
  else
    return tostring( acceleration ) .. "/tick"
  end
end

---
--- Displays smart car calibration properties
---
smart_car_calibrations_gui = {
  ---
  --- Creates smart car calibration properties block
  ---
  create = function( self, parent, smart_car )
    self.smart_car = smart_car
    self.calibration = smart_car.calibration
    self.frame = parent.add { type = "frame", name = "calibration_frame", direction = "vertical", caption = "Calibration" }
    self:compose_objects()
    self.tick_handler = event_manager.on_tick( 11, function() self:update() end )
  end,

  ---
  --- Creates a window and it's components
  ---
  compose_objects = function( self )
    local frame = self.frame
    frame.add { type = "label", name = "calibration_status", caption = "Calibration status: " }

    frame.add { type = "button", name = "calibrate_button", caption = "Calibrate this car" }
    event_manager.on_gui_click( "calibrate_button", function() self:calibrate() end )

    frame.add { type = "label", name = "tank_driving", caption = "Tank driving: " }
    frame.add { type = "label", name = "acceleration", caption = "Acceleration: " }
    frame.add { type = "label", name = "braking", caption = "Braking: " }
  end,

  ---
  --- Destroys smart car calibration properties block
  ---
  destroy = function( self )
    if self.tick_handler then
      event_manager.clear_on_tick( self.tick_handler )
    end
  end,

  ---
  --- Updates smart car calibration properties block
  ---
  update = function( self )
    local frame = self.frame
    if not frame.valid then
      return
    end
    frame.calibration_status.caption = "Calibration status: " .. format_calibration_status( self.calibration.calibration_status )
    frame.tank_driving.caption = "Tank driving: " .. format_bool_string( self.calibration.tank_driving )
    frame.acceleration.caption = "Acceleration: " .. format_per_tick_value( self.calibration.acceleration )
    frame.braking.caption = "Braking: " .. format_per_tick_value( self.calibration.braking )
  end,

  ---
  --- Calibrates a selected car type
  ---
  calibrate = function( self )
    local calibrator = active_calibrators[ self.smart_car.car.name ]
    if not calibrator then
      calibrator = SmartCarCalibrator:create( self.smart_car )
      calibrator:start()
    end
  end
}

---
--- Displays smart car properties
---
smart_car_gui = {
  ---
  --- Enables SmartCar GUI when player opens a smart car
  ---
  enable = function( self, smart_car )
    self:disable()
    self.smart_car = smart_car
    self:compose_objects()
    self.is_enabled = true
  end,

  ---
  --- Creates SmartCar GUI window
  ---
  compose_objects = function( self )
    self.window = self.smart_car.player.gui.left.add {
      type = "frame",
      name = "smart_car_window",
      caption = "Smart Car Manager",
      direction = "vertical"
    }

    smart_car_calibrations_gui:create( self.window, self.smart_car )

    self.window.add { type = "checkbox", name = "idle_mode", caption = "Idle",
                      state = self.smart_car.mode == SmartCar.mode.idle }
    event_manager.on_gui_click( "idle_mode", function() self.smart_car:set_mode( SmartCar.mode.idle ) end )
    self.window.add { type = "checkbox", name = "follow_mode", caption = "Follow me",
                      state = self.smart_car.mode == SmartCar.mode.follow }
    event_manager.on_gui_click( "follow_mode", function() self.smart_car:set_mode( SmartCar.mode.follow ) end )

    self.window.add { type = "button", name = "close_button", caption = "Close" }
    self.tick_handler = event_manager.on_tick( 11, function() self:update() end)
    event_manager.on_gui_click( "close_button", function() self:disable() end )
  end,

  update = function( self )
    if self.window then
      self.window.idle_mode.state = self.smart_car.mode == SmartCar.mode.idle
      self.window.follow_mode.state = self.smart_car.mode == SmartCar.mode.follow
    end
  end,

  ---
  --- Disables SmartCarGUI
  ---
  disable = function( self )
    event_manager.clear_on_gui_click( "close_button" )
    event_manager.clear_on_tick( self.tick_handler )
    smart_car_calibrations_gui:destroy()
    if self.window then
      self.window.destroy()
      self.window = nil
    end
    self.is_enabled = false
  end,

  ---
  --- Handles on_tick event to detect smart car opening
  ---
--  detect_smart_car_opened = function()
--    local entity = game.player.opened
--
--    if entity and entity.passenger and entity.passenger.name == "smart-car-driver" then
--      if not smart_car_gui.is_enabled then
--        smart_car_gui:enable( entity, game.player )
--      end
--    else
--      if smart_car_gui.is_enabled and not smart_car_gui.is_window_shown then
--        smart_car_gui:disable()
--      end
--    end
--  end
}

