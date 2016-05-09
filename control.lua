require "defines"
require "behavior.smart-car"
require "behavior.smart-car-control"
require "behavior.smart-car-calibration"
require "gui.smart-car-gui"
require "gui.smart-car-debug-info"
require "common.helpers"
require "common.event-manager"

---
--- Inits smart cars data structures
---
function init_smart_cars_mod()

  --  Create data structures
  global.smart_cars = SmartCarsCollection:restore( global.smart_cars )
  global.smart_car_calibrations = SmartCarCalibrationsCollection:restore( global.smart_car_calibrations )

  event_manager.init()

  event_manager.on(
    defines.events.on_built_entity,
    function ( event )
      if event.created_entity.name == "smart-car-controller" then
        smart_car_controller_placed( event.created_entity, game.get_player( event.player_index ) )
      end
    end
  )

  event_manager.on(
    defines.events.on_preplayer_mined_item,
    function ( event )
      local entity = event.entity
      global.smart_car_mining = entity.type == "car" and entity.passenger and entity.passenger.name == "smart-car-driver"
    end
  )

  event_manager.on(
    defines.events.on_player_mined_item,
    function()
      if global.smart_car_mining then
        global.smart_cars:remove_invalid_cars()
        global.smart_car_mining = nil
      end
    end
  )

  event_manager.on(
    defines.events.on_entity_died,
    function( event )
      local entity = event.entity
      if entity.type == "car" and entity.passenger and entity.passenger.name == "smart-car-driver" then
        global.smart_cars:remove_invalid_cars()
      end
    end
  )

  event_manager.on_tick( update_debug_info, 10 )
end

-----------------------------------
--  Subscribe to game events
-----------------------------------


script.on_load( init_smart_cars_mod )
script.on_init( init_smart_cars_mod )

---
--- on_player_created
---

script.on_event(
  defines.events.on_player_created,
  function ( event )
    local player = game.get_player( event.player_index )
    player.insert( {name = "car", count = 1} )
    player.insert( {name = "tank", count = 1} )
    player.insert( {name = "smart-car-controller-item", count = 1} )
    player.insert( {name = "solid-fuel", count = 50} )
  end
)


