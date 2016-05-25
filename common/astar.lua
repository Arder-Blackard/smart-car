local nodes_heap = require "common.nodes-heap"
local surface_cache = require "common.surface-cache"
require "common.helpers"

---
--- A single path node
---
local node = {}
node.__index = node

---
--- Creates a new path node
---
function node:new( x, y, g, h, prev, dir )
  return setmetatable(
    {
      x = x,
      y = y,
      g = g,
      h = h,
      f = g + h,
      prev = prev,
      dir = dir
    },
    self
  )
end

function node.__tostring( node )
  return table.concat{ "[", node.x, ";", node.y, "] {", node.g, "+", node.h, "=", node.f, "}" }
end

function node.__lt( lhs, rhs )
  return lhs.f < rhs.f
end

function node.__le( lhs, rhs )
  return lhs.f <= rhs.f
end


---
--- Implements A* pathfinding algorithm
---
local a_star = {}

a_star.__index = a_star

local straight = 10
local diagonal = 14

local successors = {
  { dx = 0, dy = -1, dg = straight },
  { dx = 1, dy = -1, dg = diagonal },
  { dx = 1, dy = 0, dg = straight },
  { dx = 1, dy = 1, dg = diagonal },
  { dx = 0, dy = 1, dg = straight },
  { dx = -1, dy = 1, dg = diagonal },
  { dx = -1, dy = 0, dg = straight },
  { dx = -1, dy = -1, dg = diagonal },
}



local manhattan_distance = function ( x, y, to_x, to_y )
  return global.astar_d1 *( math.abs( x - to_x ) + math.abs( y - to_y ) )
end

local diagonal_distance = function ( x, y, to_x, to_y )
  local dx = math.abs(x - to_x)
  local dy = math.abs(y - to_y)
  return global.astar_d1 * ( dx + dy ) + ( global.astar_d2 - 2 * global.astar_d1 ) * math.min( dx, dy )
end

local euclide_distance = function ( x, y, to_x, to_y )
  return global.astar_d1 * ( (( x - to_x )^2 + ( y - to_y )^2) ^ 0.5 )
end

---
--- Performs pathfinding
---
function a_star:find_path( from, to, coroutine_mode )

  debug( "a_star:find_path()" )

  local from_x = math.floor( from.x )
  local from_y = math.floor( from.y )
  local to_x = math.floor( to.x )
  local to_y = math.floor( to.y )

  --  Store local references
  local h
  if global.astar_distance_type == "manhattan_distance" then
    h = manhattan_distance
  elseif global.astar_distance_type == "diagonal_distance" then
    h = diagonal_distance
  else
    h = euclide_distance
  end

  local penalty = global.astar_turn_penalty

  local successors_count = 8
  local successors = successors


  debug( table.concat{ "Searching path from [", from_x, "; ", from_y, "] to [", to_x, "; ",  to_y, "]" } )
  debug( "Init data structures..." )

  --  Init structures
  local surf_cache = surface_cache.new( self.surface )
  debug( "Cell cache: Ready" )

  local open = nodes_heap.new()
  debug( "Open nodes heap: Ready" )

  --  Put in the first node
  local first_node = node:new(from_x, from_y, 0, h( from_x, from_y, to_x, to_y ) * 10 )
  open:push( first_node )

  --  Put in the matching cell
  local first_cell = surf_cache:get_cell( from_x, from_y )
  first_cell.g = 0    --  first_node.g

  --  Will be filled in if the search succeeds
  local last_node

  --  ------------  --
  --  Start search  --
  --  ------------  --
  local step = 0
  while not open:is_empty() do

    step = step + 1
--    debug( "Step " .. step )

--    debug( step .. ". ------------------------------- ")
--    debug( step .. ". " .. tostring( open ) )
    local curr_node = open:pop()
--    debug( step .. ". " .. tostring( open ) )

--    debug_table( curr_node, "curr_node" )

    draw_number( self.surface, curr_node.x, curr_node.y, curr_node.g )
    draw_number( self.surface, curr_node.x, curr_node.y, curr_node.h, true )
    draw_number( self.surface, curr_node.x, curr_node.y, curr_node.f, false, true )

    --  Check whether we have reached the target
    if curr_node.x == to_x and curr_node.y == to_y then
      last_node = curr_node
      debug( "Found target" )
      break;
    end

    --  Get matching cell
    local curr_cell = surf_cache:get_cell( curr_node.x, curr_node.y )

--    debug_table( curr_cell, "curr_cell" )

    --  If cell is not closed
    if curr_cell.state ~= 2 then

      curr_cell.state = 2  -- closed

      --  For each successor
      for dir = 1, successors_count do

        --  Get successor and it's position
        local succ = successors[dir]
        local succ_x = curr_node.x + succ.dx
        local succ_y = curr_node.y + succ.dy

        --  Get successor cell
        local succ_cell = surf_cache:get_cell( succ_x, succ_y )

--        debug_table( succ_cell, "succ_cell" )

        --  Skip impassable cells
        local succ_cell_state = succ_cell.state

        local _, err = pcall( function()

        --  For a new cell - add to open list
        if succ_cell_state == 0 then

          local succ_g = curr_node.g + succ.dg

          local succ_penalty = curr_node.dir and ((math.abs(curr_node.dir - dir) % successors_count) * penalty) or 0
          debug(  (curr_node.dir and curr_node.dir or "nil").. "->" .. dir .. ": " .. succ_penalty  )

          local succ_node = node:new(succ_x, succ_y, succ_g + succ_penalty, h(succ_x, succ_y, to_x, to_y) * 10, curr_node, dir )

--          debug_table( succ_node, "succ_node" )

          open:push(succ_node)
          succ_cell.state = 1
          succ_cell.g = succ_g


        --  For an open cell - update if more optimal path was found
        elseif succ_cell_state == 1 then
          local succ_g = curr_node.g + succ.dg
          local succ_penalty = curr_node.dir and ((math.abs(curr_node.dir - dir) % successors_count) * penalty) or 0
          if succ_g + succ_penalty < succ_cell.g then

            debug( "Wow! So optimizations! Much " .. succ_cell.g .. " to " .. succ_g + succ_penalty )

            local index, succ_node = open:find( succ_x, succ_y )
            assert( succ_node ~= nil )

--            debug( "Wow! So optimizations! Much at " .. index .. ". " .. succ_node.f .. " to " .. succ_g + succ_node.h )

            succ_cell.g = succ_g + succ_penalty
            succ_node.g = succ_g + succ_penalty
            succ_node.f = succ_g + succ_penalty + succ_node.h
            succ_node.prev = curr_node
            succ_node.dir = dir
--            debug( step .. ". " .. tostring( open ) )
            open:heapify_up( index )
--            debug( step .. ". " .. tostring( open ) )
--            debug( "Wow! Much hippyfied " )
          end

        end

        end)

        debug( tostring( err ))

      end

    end

--    debug( "Iteration finished" )

    if step % 1000 == 0 then
      debug( step )
    end

    if coroutine_mode and step % 250 == 0 then
      coroutine.yield( 2 )
    end

  end

  --  restore path or return fail
  if not last_node then
    return nil
  end

  local path_reversed = {}
  local path_size = 0

  while last_node do
    path_size = path_size + 1
    path_reversed[path_size] = { x = last_node.x, y = last_node.y }
    last_node = last_node.prev
  end

  local path = {}

  for i = path_size, 1, -1 do
    path[path_size - i + 1] = path_reversed[i]
  end

  return path
end



return {
  new = function ( surface )
    debug( "  Creating a_star finder. Surface: " .. surface.name )
    return setmetatable( { surface = surface }, a_star )
  end
}

