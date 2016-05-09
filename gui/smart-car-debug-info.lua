require "util"
require "common.helpers"
require "common.math2"

local debug_info = {}

---
--- Creates debug info UI
---
local function create_debug_info()
  local flow = game.player.gui.top.add {
    type = "flow",
    direction = "vertical",
    name = "smart_car_debug_info"
  }

  flow.add { type = "label", name = "tick_display", caption = "tick: " }
  flow.add { type = "label", name = "smart_cars", caption = "smart_cars" }
  flow.add { type = "label", name = "orientation", caption = "car names" }
  flow.add { type = "label", name = "position", caption = "position" }
  flow.add { type = "label", name = "mouse_position", caption = "mouse position" }
  flow.add { type = "label", name = "mouse_orientation", caption = "mouse orientation" }

  return flow
end

---
--- Updates debug info UI
---
function update_debug_info( event )
  local flow =  game.player.gui.top.smart_car_debug_info

  if not flow then
    flow = create_debug_info()
  end

  flow.tick_display.caption = "tick: " .. tostring( event.tick )
  flow.smart_cars.caption = "smart_cars: " .. debug_info.get_smart_cars_count()
  flow.orientation.caption = "orientation: " .. (game.player.vehicle and game.player.vehicle.orientation or "undefined")
  flow.position.caption = "position: " .. util.positiontostr( game.player.position )
  if game.player.selected then
    flow.mouse_position.caption = "mouse position: " .. ( game.player.selected and util.positiontostr( game.player.selected.position ) or "undefined" )
    flow.mouse_orientation.caption = "mouse orientation: " .. ( game.player.selected and math2.orientation( game.player.position, game.player.selected.position  ) or "undefined" )
  end
end


function debug_info.get_smart_cars_count()
    local cars_names = {}
    for i,car in ipairs( global.smart_cars ) do
      if car.valid then
        table.insert( cars_names, table.concat( { car.name, " {", car.position.x,",", car.position.y, "}"}, "" ) )
      end
    end
    return table.concat( cars_names, ", " )
end


function debug_info.get_orientation()
    local cars_names = {}
    for k,car in pairs( game.entity_prototypes ) do
      if car.type == "car" then
        table.insert( cars_names, table.concat( { car.name, " [" , car.type, "]" } ) )
      end
    end
    return table.concat( cars_names, ", " )
end

function debug_info.get_calibrations()
    if not global.smart_car_calibrations then
      return ""
    end

    local calibrations = {}
    for k,c in pairs( global.smart_car_calibrations ) do
      table.insert( calibrations, table.concat( { c.car_name, " [" , c.calibration_status, "]" } ) )
    end
    return table.concat( calibrations, ", " )
end

function debug_info.format_position()
  local str = ""
  for k, v in pairs(game.player.position) do
    str = str .. tostring( k ) .. ": " .. tostring( v ) .. ", "
  end
  return str
end
