require "defines"
require "behavior.smart-car.car"
require "behavior.smart-car.collection"
require "behavior.smart-car.control"
require "behavior.smart-car.calibration"
require "gui.smart-car-gui"
require "gui.smart-car-debug-info"
require "common.helpers"
require "common.event-manager"

local road_paver = require "behavior.road.road_paver"

---
--- Inits smart cars data structures
---
function init_smart_cars_mod()

  --  new data structures
  global.smart_cars = SmartCarsCollection:restore( global.smart_cars )
  global.smart_car_calibrations = SmartCarCalibrationsCollection:restore( global.smart_car_calibrations )
  global.smart_car_gui = SmartCarGui:new( global.smart_car_gui )

  SmartCarCalibratorsCollection:new()

  event_manager.init()

  event_manager.on(
    defines.events.on_built_entity,
    function ( event )
      local entity = event.created_entity
      local entity_name = entity.name
      debug( entity_name )
      if entity_name == "smart-car-controller" then
        smart_car_controller_placed( entity, game.get_player( event.player_index ) )
      elseif entity_name == "asphalt-node" then
        road_paver.road_node_placed( entity, game.get_player( event.player_index ) )
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
      debug( "Entity died: " .. entity.type .. ( entity.valid and "[valid]" or "[invalid]" ) .. ", passenger: " .. (entity.type == "car" and ( entity.passenger and entity.passenger.name or "nil" ) or "invalid" ) )
      if entity.type == "car" and entity.passenger and entity.passenger.name == "smart-car-driver" then
        global.smart_cars:remove( entity )
        global.smart_cars:remove_invalid_cars()
      end
    end
  )

  event_manager.on_tick( 1, update_debug_info )
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
    player.insert { name = "asphalt-node", count = 1 }
    player.insert { name = "asphalt", count = 1000 }
    player.insert { name = "car", count = 1 }
    player.insert { name = "tank", count = 1 }
    player.insert { name = "smart-car-controller-item", count = 1 }
    player.insert { name = "solid-fuel", count = 50 }
    player.insert { name = "combat-shotgun", count = 1 }
    player.insert { name = "piercing-shotgun-shell", count = 50 }

    draw_number( player.surface, player.position.x, player.position.y, 11 )
    draw_number( player.surface, player.position.x + 1, player.position.y, 22, true )
    draw_number( player.surface, player.position.x + 1, player.position.y + 1, 256, true, true )
  end
)


