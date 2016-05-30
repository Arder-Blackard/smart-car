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

function road_network:add_node( x, y, adjacent_nodes )
  local node = network_node:new( x, y )
  local nodes = self.nodes
  node.index = #nodes + 1
  nodes[node.index] = node

  local node_adjacency = {}
  for i = 1,#adjacent_nodes do
    local n = adjacent_nodes[i]
    local t = type( n )
    if t == "number" then
      table.insert( node_adjacency, n )
    elseif t == "table" then
      table.insert( node_adjacency, n.index )
    end
  end

end

function road_network:find_node( x, y )



end

global.road_network = road_network
return global.road_network
