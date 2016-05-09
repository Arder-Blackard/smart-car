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
      area = { position, position },
      type = "car",
      force = player.force
  }

  if #cars == 0 then
    return
  end

  smart_car_gui:enable( global.smart_cars:get_or_add( cars[1], player ) )
end
