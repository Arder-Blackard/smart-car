require "scripts.common.helpers"
local SmartCar = require "scripts.smart-car.car"


-------------------------------------------
--- Collection of smart cars
-------------------------------------------
local smart_cars_collection = {}
smart_cars_collection.__index = smart_cars_collection

---
--- Creates a new or restores an existing SmartCarsCollection
---
function smart_cars_collection:restore ()
  for _, smart_car in ipairs(self) do
    SmartCar:restore( smart_car )
  end
end

---
--- Searches for a SmartCar object for the 'car'
---
function smart_cars_collection:find( car )
  for index, smart_car in ipairs(self) do
    if smart_car.car == car then
      return smart_car, index
    end
  end
  return nil
end

---
--- Checks whether the collection contains a SmartCar object for the 'car'
---
function smart_cars_collection:contains( car )
  return self:find( car ) ~= nil
end

---
  --- Adds a new car and enables it's smart logic
  ---
function smart_cars_collection:get_or_add( car, player )

  --  Check for errors
  if car.type ~= "car" then
    debug( "Cannot init smart driving for a non-car object" )
    return nil
  end

  --  Check if the car is already a SmartCar
  local smart_car = self:find( car )
  if smart_car then
    return smart_car
  end

  --  Check for errors
  if car.passenger then
    debug( "The car is not empty" )
    return nil
  end

  --  Init a new SmartCar
  local smart_car = SmartCar.new( car, player )
  table.insert( self, smart_car )
  return smart_car
end

---
--- Removes a car and disables it's smart logic
---
function smart_cars_collection:remove( car )
  local smart_car, index = self:find( car )
  if not smart_car then
    debug( "Cannot find the smart car" )
    return false
  end
  smart_car:dispose()
  table.remove( self, index )
  return true

end

---
--- Clears all SmartCars describing cars that are not valid anymore
---
function smart_cars_collection:remove_invalid_cars()
  for index = #self, 1, -1 do
    local smart_car = self[index]
    if not smart_car.car.valid then
      smart_car:dispose()
      table.remove( self, index )
    end
  end
end

---
--- Handles 'smart-car-controller' placement
---
function smart_cars_collection:controller_placed( controller, player )

  local position = controller.position

  mine_entity( controller, player )

  local cars = player.surface.find_entities_filtered {
    area = { { position.x - 0.5, position.y - 0.5 }, { position.x + 0.5, position.y + 0.5 } },
    type = "car",
    force = player.force
  }

  if #cars == 0 then
    local tank = player.surface.create_entity{ name = "tank", position = position, force = player.force }
    tank.insert( { name = "solid-fuel", count = 50 } )
    self:get_or_add( tank, player )
    return
  end

  --  TODO: Fix
  global.smart_car_gui:enable( global.smart_cars:get_or_add( cars[1], player ) )

end

if not global.smart_cars then
  global.smart_cars = {}
end

return setmetatable( global.smart_cars, smart_cars_collection )

