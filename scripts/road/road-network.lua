local algorithm = require "scripts.common.algorithm"

if global.road_network then
  return global.road_network
end

local network_node = {
}

function network_node:new( x, y )
  return { x = x, y = y }
end



local road_network = {
  nodes = {},
  adjacency = {}
}

---
--- Adds a node to the road network
---
function road_network:add_node( x, y, adjacent_nodes )

  --  Create node itself
  local node = network_node:new( x, y )
  local nodes = self.nodes
  node.index = #nodes + 1
  nodes[node.index] = node

  --  Add node connections
  local node_adjacency = {}
  for i = 1, #adjacent_nodes do

    local n = adjacent_nodes[i]
    local t = type( n )
    if t == "number" then
      table.insert( node_adjacency, n )
    elseif t == "table" then
      table.insert( node_adjacency, n.index )
    end

  end

end

---
--- Searches for the node with coordinates (x, y)
---
function road_network:find_node( x, y )

end


---
--- Connects the node with index 'source' to the node with index 'target'
---
function road_network:connect_nodes( source, target, bidirectional )

  if source == target then
    return
  end

  local adjacency = self.adjacency
  local index, insert_position = algorithm.binary_search( adjacency, target )
  if not index then
    table.insert( adjacency, target, insert_position )
  end

  if bidirectional then
    self:connect_nodes( target, source, false )
  end

end

global.road_network = road_network
return global.road_network
