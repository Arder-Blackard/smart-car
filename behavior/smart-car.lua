require "util"
require "defines"
require "common.helpers"
require "common.math2"

-------------------------------------------
--- A smart car descriptor
-------------------------------------------
SmartCar = {

  mode = {
    idle = 0,
    follow = 1
  },

  ---
  --- Restores SmartCar object setting it's metatable (after load)
  ---
  restore = function( self, source )
    if not source.car then
      return
    end
    self.__index = self
    return setmetatable( source, self )
  end,

  ---
  --- Creates a new SmartCar object belonging to the 'player' from the 'car'
  ---
  create = function ( self, car, player )

    car.passenger = player.surface.create_entity{
      name = "smart-car-driver",
      position = car.position,
      force = player.force
    }

    local smart_car = {
      mode = SmartCar.mode.idle,
      car = car,
      player = player,
      driver = car.passenger,
      calibration = global.smart_car_calibrations[car.name]
    }

    self.__index = self
    return setmetatable( smart_car, self )
  end,

  destroy = function ( self )
    self.driver.destroy()
    if self.tick_handler then
      event_manager.clear_on_tick( self.tick_handler )
    end
  end,

  ---
  --- Runs the car
  ---
  accelerate = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.accelerating,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Brakes the car
  ---
  brake = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.braking,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Runs the car backwards
  ---
  reverse = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.reversing,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Turns off the engine
  ---
  coast = function( self, direction )
    self.driver.riding_state = {
      acceleration = defines.riding.acceleration.nothing,
      direction = direction or defines.riding.direction.straight
    }
  end,

  ---
  --- Turns weels to a given direction keeping current accelerating status
  ---
  turn = function( self, direction )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = direction
    }
  end,

  ---
  --- Turns weels left keeping current accelerating status
  ---
  turn_left = function( self )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = defines.riding.direction.left
    }
  end,

  ---
  --- Turns weels right keeping current accelerating status
  ---
  turn_right = function( self )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = defines.riding.direction.right
    }
  end,

  ---
  --- Turns weels straight keeping current accelerating status
  ---
  keep_straight = function( self )
    self.driver.riding_state = {
      acceleration = self.driver.riding_state.acceleration,
      direction = defines.riding.direction.straight
    }
  end,

  ---
  --- Calculates the rotation direction to turn towards the 'target_position'
  ---
  get_rotation_towards = function( self, target_position )
    local target_orientation = math2.orientation( self.car.position, target_position )
    return math2.get_rotation_direction( self.car.orientation, target_orientation )
  end,

  ---
  --- Rotates the car to a given point
  ---
  rotate_towards = function ( self, target_position )
    local direction = self:get_rotation_towards( target_position )
    self:turn( direction )
  end,

  follow = function ( self )
    local direction = self:get_rotation_towards( game.player.position )
    self:accelerate( direction )
  end,

  set_mode = function( self, mode )
    if self.tick_handler then
      event_manager.clear_on_tick( self.tick_handler )
    end
    self.mode = mode
    if mode == SmartCar.mode.follow then
      self.target = self.player
      self.tick_handler = event_manager.on_tick( function() self:follow() end, 2 )
      prnt( "Setting mode to " .. self.mode ..", tick_handler =  " .. tostring( self.tick_handler ) )
    end
  end
}

-------------------------------------------
--- Collection of smart cars
-------------------------------------------
SmartCarsCollection = {

    ---
    --- Creates a new or restores an existing SmartCarsCollection
    ---
    restore = function ( self, source )
      if source then
        for _, smart_car in ipairs(source) do
          SmartCar:restore( smart_car )
        end
      else
        source = {}
      end

      self.__index = self
      return setmetatable( source, self )
    end,

    ---
    --- Searches for a SmartCar object for the 'car'
    ---
    find = function ( self, car )
      for index, smart_car in ipairs(self) do
        if smart_car.car == car then
          return smart_car, index
        end
      end
      return nil
    end,

    ---
    --- Checks whether the collection contains a SmartCar object for the 'car'
    ---
    contains = function ( self, car )
      return self:find( car ) ~= nil
    end,

    ---
    --- Adds a new car and enables it's smart logic
    ---
    get_or_add = function ( self, car, player )

      --  Check for errors
      if car.type ~= "car" then
        prnt( "Cannot init smart driving for a non-car object" )
        return nil
      end

      --  Check if the car is already a SmartCar
      local smart_car = self:find( car )
      if smart_car then
        return smart_car
      end

      --  Check for errors
      if car.passenger then
        prnt( "The car is not empty" )
        return nil
      end

      --  Init a new SmartCar
      local smart_car = SmartCar:create( car, player )
      table.insert( self, smart_car )
      return smart_car
    end,

    ---
    --- Removes a car and disables it's smart logic
    ---
    remove = function ( self, car )

      local smart_car, index = self:find( car )
      if not smart_car then
        prnt( "Cannot find the smart car" )
        return false
      end

      smart_car.driver.destroy()
      table.remove( self, index )
      return true

    end,

    ---
    --- Clears all SmartCars describing cars that are not valid anymore
    ---
    remove_invalid_cars = function ( self )
      for index, smart_car in ipairs( self ) do
        if not smart_car.car.valid then
          smart_car:destroy()
          table.remove( self, index )
        end
      end
    end
}
