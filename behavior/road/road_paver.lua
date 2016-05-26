require "util"
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

local function is_diagonal_move( pos1, pos2 )
  debug( ( pos1 and util.positiontostr( pos1 ) or "nil") .. " -> " .. ( pos2 and util.positiontostr( pos2 ) or "nil" ) )
  if not pos1 or not pos2 then
    return false
  end
  return pos1.x ~= pos2.x and pos1.y ~= pos2.y
end

local road_node = {
  [1] = {
    [1] = {
      origin = { 0, 3 },
      pattern = { "ooooooo" }
    },
    [2] = {
      origin = { 3, 3 },
      pattern = {
        "  o    ",
        " ooo   ",
        "ooooo  ",
        "oooooo ",
      }
    },
    [3] = {
      origin = { 3, 3 },
      pattern = {
        "oooo",
        "oooo",
        "oooo",
        "oooo",
      }
    }
  },
  [2] = {
    [1] = {
      origin = { 0, 0 },
      pattern = {
        "oooo",
        " ooo",
        "  o ",
      }
    },
    [1] = {
      origin = { 1, 4 },
      pattern = { "ooooooo" }
    },

    [3] = {
      origin = { 4, 4 },
      pattern = {
        "oooo",
        "oooo",
        "oooo",
        "oooo",
      }
    }
  },
}


---
---
---
function road_paver.pave( surface, from, to )

  event_manager.execute_coroutine( function()

    debug( "road_paver.pave() coroutine" )

    local path = a_star.new( surface ):find_path( from, to, true )

    if path then
      debug( "Pathfinding succeded: " .. tostring( #path ) .. " nodes" )

      local tiles = {}

      local prev_path_node
      for i = 1,#path do
--
          local path_node = path[i]
          local diagonal = path_node.dir and (path_node.dir % 2 == 0)
          local road_width = diagonal and 2 or 3

          for dy = -road_width,road_width do
            for dx = -road_width,road_width do
              tiles[#tiles + 1] = { name = "asphalt", position = { path_node.x + dx, path_node.y + dy } }
            end
          end

        surface.create_entity{ name = "small-lamp", position = path[i] }
      end

        debug( "Tiles: " .. #tiles )
        surface.set_tiles( tiles )

    else
      debug( "Path not found" )
    end

  end)

end


---
---
---
function road_paver.road_node_placed( entity, player )

  local position = entity.position

  entity.destroy()
  player.insert { name = "asphalt-node" }

  if not road_paver.last_node then
    road_paver.place_road(player.surface, position, 0)
    road_paver.last_node = position
  else
    road_paver.pave(player.surface, road_paver.last_node, position)
    road_paver.last_node = nil
  end
end

return road_paver
