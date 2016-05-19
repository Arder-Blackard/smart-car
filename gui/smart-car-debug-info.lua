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
  flow.add { type = "checkbox", name = "can_place", caption = "can_place_entity", state = false }

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
  flow.smart_cars.caption = "smart_cars: " .. debug_info.get_smart_cars_info()
  flow.orientation.caption = "orientation: " .. (game.player.vehicle and (game.player.vehicle.orientation .. ", " ..
                                                 util.positiontostr( math2.point_along_orientation( game.player.vehicle.position, game.player.vehicle.orientation, 10 ) ) )
                                                or "undefined")

  flow.position.caption = "position: " .. util.positiontostr( game.player.position )
  if game.player.selected then
    flow.mouse_position.caption = "mouse position: " .. ( game.player.selected and util.positiontostr( game.player.selected.position ) or "undefined" )
    flow.mouse_orientation.caption = "mouse orientation: " .. ( game.player.selected and math2.orientation( game.player.position, game.player.selected.position  ) or "undefined" )
  end

  if flow.can_place.state then
    local player = game.player
    local surf = player.surface
    local entity = { name = "tank", position = { player.position.x, player.position.y + 20 } }
    for _ = 1, 1000 do
      surf.can_place_entity( entity )
    end
  end
end


function debug_info.get_smart_cars_info()
    local cars_names = {}
    for _, smart_car in ipairs( global.smart_cars ) do
      local c = smart_car.car
      if c.valid then
        table.insert( cars_names, table.concat( { c.name, " {", c.position.x,",", c.position.y, "},",
                                                  " speed: ", c.speed,
                                                  ", ", debug_info.format_riding( smart_car.car.passenger ),
                                                  ", ", debug_info.format_approaching( smart_car )
                                                },
                                                "" ) )
      end
    end
    return table.concat( cars_names, ", " )
end


function debug_info.get_orientation()
    local cars_names = {}
    for _,car in pairs( game.entity_prototypes ) do
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
    for _,c in pairs( global.smart_car_calibrations ) do
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

function debug_info.format_approaching( smart_car )

  if not smart_car.calibration or not smart_car.calibration.braking then
    return "uncalibrated"
  else
    return " {dist: " .. util.distance( smart_car.car.position, game.player.position ) ..
           ", br_dist: " .. tostring( smart_car:get_braking_distance() ) ..
           ", tg_delta: " .. (smart_car.target and smart_car:get_orientation_delta( smart_car.target.position ) or "") ..
           ", obst: " .. tostring( smart_car:detect_obstacle() ) ..
           "}"
  end
end

function debug_info.format_riding( player )
  if not player.riding_state then
    return "[ : ]"
  end

  local result = "["
  local acceleration = player.riding_state.acceleration
  if acceleration == defines.riding.acceleration.accelerating then
    result = result .. " acc :"
  elseif acceleration == defines.riding.acceleration.braking then
    result = result .. " brk :"
  elseif acceleration == defines.riding.acceleration.reversing then
    result = result .. " rev :"
  elseif acceleration == defines.riding.acceleration.nothing then
    result = result .. " nth :"
  else
    result = result .. " :"
  end
  local direction = player.riding_state.direction
  if direction == defines.riding.direction.straight then
    result = result .. " str ]"
  elseif direction == defines.riding.direction.left then
    result = result .. " lft ]"
  elseif direction == defines.riding.direction.right then
    result = result .. " rgt ]"
  else
    result = result .. " ]"
  end
  return result
end
