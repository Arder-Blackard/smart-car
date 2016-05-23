local nodes_heap = {}
nodes_heap.__index = nodes_heap

---
--- Inserts 'value' into the queue
---
function nodes_heap:push( value )

  local heap = self.heap
  local size = #heap + 1
  heap[size] = value
  self:heapify_up( size )

end

---
--- Restores heap correctness in supertree with leaf in 'node_index'
---
function nodes_heap:heapify_up( node_index )

  local heap = self.heap
  local value = heap[node_index]
  local value_f = value.f

  while node_index > 1 do
    local parent_index = (node_index - node_index % 2) / 2
    local parent = heap[parent_index]

    if parent.f > value_f then
      heap[node_index] = parent
      node_index = parent_index
    else
      heap[node_index] = value
      break
    end
  end

  heap[node_index] = value
  return node_index
end

---
--- Restores heap correctness in subtree with root in 'node_index'
---
function nodes_heap:heapify_down( node_index )

  local heap = self.heap
  local size = #heap
  local node_value = heap[node_index]

  while true do

    local left_index = 2 * node_index
    local right_index = left_index + 1

    local smallest_index = node_index
    local smallest_value = node_value

    if left_index < size then
      local left_value = heap[left_index]
      if left_value.f < smallest_value.f then
        smallest_index = left_index
        smallest_value = left_value
      end
    end

    if right_index < size then
      local right_value = heap[right_index]
      if right_value.f < smallest_value.f then
        smallest_index = right_index
        smallest_value = right_value
      end
    end

    if smallest_index ~= node_index then
      heap[node_index] = smallest_value
      node_index = smallest_index
    else
      heap[node_index] = node_value
      break
    end
  end

  return node_index
end

---
--- Searches for a node by its coordinates
---
function nodes_heap:find( x, y )
  local heap = self.heap
  for i = 1, #heap do
    local item = heap[i]
    if item.x == x and item.y == y then
      return i, item
    end
  end
  return -1, nil
end

---
--- Searches for a node by its coordinates
---
function nodes_heap:replace( index, value )
  local heap = self.heap
  heap[index] = value
  self:heapify_down( index )
end

---
--- Takes the value at the head of the queue
---
function nodes_heap:pop()

  local heap = self.heap
  local ret_value = heap[1]

  local size = #heap
  heap[ 1 ] = heap[size]
  heap[size] = nil

  if size > 1 then
    self:heapify_down( 1 )
  end

  return ret_value
end

---
--- Checks whether the queue is empty
---
function nodes_heap:is_empty()
  return self.heap[1] == nil
end


---
--- Converts to string
---
function nodes_heap:__tostring()
  local heap = self.heap
  local nodez = {}
  for i = 1, #heap do
    nodez[i] = tostring(heap[i] and heap[i].f or "")
  end
  return table.concat(nodez, ", ")
end

return {
  new = function()
    return setmetatable( { heap = {} }, nodes_heap)
  end
}
