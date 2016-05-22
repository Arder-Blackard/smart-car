require "defines"
require "common.helpers"
require "gui.smart-car-gui"

---
--- Handles 'smart-car-controller' placement
---
function smart_car_controller_placed(  controller, player )

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
    global.smart_cars:get_or_add( tank, player ):set_mode( SmartCar.mode.follow )
    return
  end

  global.smart_car_gui:enable( global.smart_cars:get_or_add( cars[1], player ) )
end
