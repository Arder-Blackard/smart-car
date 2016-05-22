require "defines"
require "common.helpers"

local a_star = require "common.astar"

local function sign(value)
  return value > 0 and 1 or -1
end


local road_paver = {}

function road_paver.place_road(surface, position, road_lane_width)
  --  Prepare tiles
  local tiles = {}
  for row = -road_lane_width, road_lane_width do
    for column = -road_lane_width, road_lane_width do
      table.insert(tiles, { name = "asphalt", position = { position.x + column, position.y + row } })
    end
  end
  surface.set_tiles(tiles)
end

function road_paver.get_shift(from, to)
  local dx = to.x - from.x
  local dy = to.y - from.y
  local abs_x = math.abs(dx)
  local abs_y = math.abs(dy)

  local shift_x = 0
  local shift_y = 0

  if abs_x >= abs_y then
    shift_x = sign(dx)
  end
  if abs_x <= abs_y then
    shift_y = sign(dy)
  end
  return { x = shift_x, y = shift_y }
end

function road_paver.pave( surface, from, to )

  event_manager.execute_coroutine( function()

    prnt( "road_paver.pave() coroutine" )

    a_star.new( surface ):find_path( from, to, true )

    if path then
      prnt( "Pathfinding succeded: " .. tostring( path ) )
      local tiles = {}
      for i = 1,#path do
        tiles[i] = { name = "asphalt", position = path[i] }
      end
      surface.set_tiles(tiles)
    else
      prnt( "Path not found" )
    end

  end)

end

function road_paver.road_node_placed( entity, player )

  local position = entity.position

  entity.destroy()
  player.insert { name = "asphalt-node" }

  if not road_paver.last_node then
    road_paver.place_road(player.surface, position, 0)
    road_paver.last_node = position
  else
    road_paver.pave(player.surface, road_paver.last_node, position)
  end
end

return road_paver
