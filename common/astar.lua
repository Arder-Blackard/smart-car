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
      f = g + h - ( (prev and (dir == prev.dir )) and 1 or 0),
      prev = prev,
      dir = dir or -1
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
local diagonal = 19

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
  local h = function( x, y, to_x, to_y )
    return (( x - to_x )^2 + ( y - to_y )^2) ^ 0.5 * 10
--    return (math.abs( x - to_x ) + math.abs( y - to_y )) * 10
--    return math.min( math.abs( x - to_x ), math.abs( y - to_y ) ) * 10
  end

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
  local first_node = node:new(from_x, from_y, 0, h( from_x, from_y, to_x, to_y ) )
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
      for i = 1, successors_count do

        --  Get successor and it's position
        local succ = successors[i]
        local succ_x = curr_node.x + succ.dx
        local succ_y = curr_node.y + succ.dy

        --  Get successor cell
        local succ_cell = surf_cache:get_cell( succ_x, succ_y )

--        debug_table( succ_cell, "succ_cell" )

        --  Skip impassable cells
        local succ_cell_state = succ_cell.state

        --  For a new cell - add to open list
        if succ_cell_state == 0 then

          local succ_g = curr_node.g + succ.dg
          local succ_node = node:new(succ_x, succ_y, succ_g, h(succ_x, succ_y, to_x, to_y), curr_node)

--          debug_table( succ_node, "succ_node" )

          open:push(succ_node)
          succ_cell.state = 1
          succ_cell.g = succ_g


        --  For an open cell - update if more optimal path was found
        elseif succ_cell_state == 1 then
          local succ_g = curr_node.g + succ.dg
          if succ_g < succ_cell.g then

            local index, succ_node = open:find( succ_x, succ_y )
            assert( succ_node ~= nil )

--            debug( "Wow! So optimizations! Much at " .. index .. ". " .. succ_node.f .. " to " .. succ_g + succ_node.h )

            succ_cell.g = succ_g
            succ_node.g = succ_g
            succ_node.f = succ_g + succ_node.h
            succ_node.prev = curr_node
--            debug( step .. ". " .. tostring( open ) )
            open:heapify_up( index )
--            debug( step .. ". " .. tostring( open ) )
--            debug( "Wow! Much hippyfied " )
          end

        end

      end

    end

--    debug( "Iteration finished" )

    if step % 1000 == 0 then
      debug( step )
    end

    if coroutine_mode and step % 50 == 0 then
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

