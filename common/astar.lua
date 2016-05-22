local heap = require "common.heap"
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
function node:new( x, y, g, h, prev )
  return setmetatable( { x = x, y = y, g = g, h = h, f = g + h, prev = prev }, self )
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

local successors = {
  { dx = 0, dy = -1, dg = 10 },
  { dx = 1, dy = -1, dg = 14 },
  { dx = 1, dy = 0, dg = 10 },
  { dx = 1, dy = 1, dg = 14 },
  { dx = 0, dy = 1, dg = 10 },
  { dx = -1, dy = 1, dg = 14 },
  { dx = -1, dy = 0, dg = 10 },
  { dx = -1, dy = -1, dg = 14 },
}

---
--- Performs pathfinding
---
function a_star:find_path( from, to, coroutine_mode )

  prnt( "a_star:find_path()" )

  local from_x = math.floor( from.x )
  local from_y = math.floor( from.y )
  local to_x = math.floor( to.x )
  local to_y = math.floor( to.y )

  --  Store local references
  local h = function( x, y, to_x, to_y )
    return (math.abs( x - to_x ) + math.abs( y - to_y )) * 10
  end

  local successors_count = 8
  local successors = successors


  prnt( table.concat{ "Searching path from [", from_x, "; ", from_y, "] to [", to_x, "; ",  to_y, "]" } )
  prnt( "Init data structures..." )

  --  Init structures
  local surf_cache = surface_cache.new( self.surface )
  prnt( "Cell cache: Ready" )

  local open = heap.new()
  prnt( "Open nodes heap: Ready" )

  local first_cell = surf_cache:get_cell( from_x, from_y )
  prnt_table( first_cell, "First cell" )

  local first_node = node:new(from_x, from_y, 0, h( from_x, from_y, to_x, to_y ))
  prnt_table( first_node, "First node" )

  open:push( first_node )
  prnt( "Open is_empty: " .. tostring( open:is_empty() ) )

  local last_node

  local step = 0

  --  Start search
  while not open:is_empty() do

    step = step + 1

    local curr_node = open:pop()

--    prnt( step .. ") Popped node " .. tostring ( curr_node ) )

    if curr_node.x == to_x and curr_node.y == to_y then
      last_node = curr_node
      prnt( "Found target" )
      break;
    end

    local curr_cell = surf_cache:get_cell( curr_node.x, curr_node.y )
--    prnt_table( curr_cell, step .. ") Matching surface cell" )

    if curr_cell.state ~= 2 then

      self.surface.create_entity{ name = "iron-ore", position = { curr_node.x, curr_node.y } }

      curr_cell.state = 2  -- closed

      for i = 1, successors_count do

        local succ = successors[i]
        local succ_x = curr_node.x + succ.dx
        local succ_y = curr_node.y + succ.dy

        local succ_cell = surf_cache:get_cell( succ_x, succ_y )
--        prnt_table( succ_cell, tostring(i) .. ". Successor cell [" .. succ.dx .. "; " .. succ.dy .. " -> " .. succ_x .. ";" .. succ_y .. "]" )

        if succ_cell.passable then
          local cell_state = succ_cell.state
          if cell_state == 0 then
            local succ_node = node:new( succ_x, succ_y, curr_node.g + succ.dg, h( succ_x, succ_y, to_x, to_y ), curr_node)
            open:push( succ_node )
            succ_cell.state = 1
          end
        end

      end
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
    prnt( "  Creating a_star finder. Surface: " .. surface.name )
    return setmetatable( { surface = surface }, a_star )
  end
}

