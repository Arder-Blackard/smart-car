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

  local astar_d_flow = flow.add { type = "flow", name = "astar_d_flow", direction = "horizontal" }
  astar_d_flow.add { type = "label", name = "d1_label", caption = "D1: " }
  astar_d_flow.add { type = "textfield", name = "d1_text", text = "1" }
  astar_d_flow.add { type = "label", name = "d2_label", caption = "D2: " }
  astar_d_flow.add { type = "textfield", name = "d2_text", text = "1" }

  local astar_dist_flow = flow.add { type = "flow", name = "astar_dist_flow",  direction = "horizontal" }

  global.astar_distance_type = "manhattan_distance"
  astar_dist_flow.add { type = "checkbox", name = "manhattan_distance", caption = "Manhattan dist.", state = true }
  astar_dist_flow.add { type = "checkbox", name = "diagonal_distance", caption = "Diagonal dist.", state = false }
  astar_dist_flow.add { type = "checkbox", name = "euclide_distance", caption = "Euclide dist.", state = false }

  local function distance_checkbox_click( event )
    local element_name = event.element.name
    flow.astar_dist_flow.manhattan_distance.state = ( element_name == "manhattan_distance" )
    flow.astar_dist_flow.diagonal_distance.state = ( element_name == "diagonal_distance" )
    flow.astar_dist_flow.euclide_distance.state = ( element_name == "euclide_distance" )
    global.astar_distance_type = element_name
  end

  event_manager.on_gui_click( "manhattan_distance", distance_checkbox_click )
  event_manager.on_gui_click( "diagonal_distance", distance_checkbox_click )
  event_manager.on_gui_click( "euclide_distance", distance_checkbox_click )

  local astar_turn_flow = flow.add { type = "flow", name = "astar_turn_flow", direction = "horizontal" }
  astar_turn_flow.add { type = "label", name = "str_label", caption = "Turn penalty: " }
  astar_turn_flow.add { type = "textfield", name = "turn_penalty_text", text = "0" }


  local astar_clear_flow = flow.add { type = "flow", name = "astar_clear_flow",  direction = "horizontal" }

  astar_clear_flow.add { type = "button", name = "clear_numbers", caption = "Clear numbers" }
  astar_clear_flow.add { type = "button", name = "clear_road", caption = "Clear road" }

  event_manager.on_gui_click( "clear_numbers", function( event )
    local player = game.players[event.player_index]
    local pos = player.position
    local decoratives = player.surface.find_entities_filtered {
      area={ {pos.x - 300, pos.y - 300}, {pos.x + 300, pos.y + 300} },
      type="decorative"
    }
    for _, v in ipairs( decoratives ) do v.destroy() end
  end )


  event_manager.on_gui_click( "clear_road", function( event )
    local player = game.players[event.player_index]
    local pos = player.position
    local decoratives = player.surface.find_entities_filtered {
      area={ {pos.x - 300, pos.y - 300}, {pos.x + 300, pos.y + 300} },
      name="small-lamp"
    }
    for _, v in ipairs( decoratives ) do v.destroy() end
  end )

  return flow
end

local last_position = {x = 0, y = 0}

---
--- Updates debug info UI
---
function update_debug_info( event )

  local flow =  game.player.gui.top.smart_car_debug_info
  if not flow then
    flow = create_debug_info()
  end

  local astar_d_flow = flow.astar_d_flow

  global.astar_d1 = tonumber( astar_d_flow.d1_text.text ) or 1
  global.astar_d2 = tonumber( astar_d_flow.d2_text.text ) or 1
  global.astar_turn_penalty = tonumber( flow.astar_turn_flow.turn_penalty_text.text ) or 0

  flow.tick_display.caption = "tick: " .. tostring( event.tick )
  flow.smart_cars.caption = "smart_cars: " .. debug_info.get_smart_cars_info()
  flow.orientation.caption = "orientation: " .. (game.player.vehicle and (game.player.vehicle.orientation .. ", " ..
                                                 util.positiontostr( math2.point_along_orientation( game.player.vehicle.position, game.player.vehicle.orientation, 10 ) ) .. ", speed: " .. tostring(game.player.vehicle.speed)  )
                                                or "undefined" )

  flow.position.caption = "position: " .. util.positiontostr( game.player.position ) .. ", sp: " .. tostring( util.distance( last_position, game.player.position ) )
  last_position = game.player.position

  if game.player.selected then
    flow.mouse_position.caption = "mouse position: " .. ( game.player.selected and util.positiontostr( game.player.selected.position ) or "undefined" )
    flow.mouse_orientation.caption = "mouse orientation: " .. ( game.player.selected and math2.orientation( game.player.position, game.player.selected.position  ) or "undefined" )
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
