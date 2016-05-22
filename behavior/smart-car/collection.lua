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
    local smart_car = SmartCar:new( car, player )
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
    smart_car:dispose()
    table.remove( self, index )
    return true

  end,

  ---
  --- Clears all SmartCars describing cars that are not valid anymore
  ---
  remove_invalid_cars = function ( self )
    for index = #self, 1, -1 do
      local smart_car = self[index]
      if not smart_car.car.valid then
        smart_car:dispose()
        table.remove( self, index )
      end
    end
  end
}
