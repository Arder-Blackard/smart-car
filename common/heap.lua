local heap = {}
heap.__index = heap

function heap:push( value )

  local heap = self.heap
  local value_index = #heap + 1

  while value_index > 1 do
    local parent_index = (value_index - value_index % 2) / 2
    local parent = heap[parent_index]

    if parent > value then
      heap[value_index] = parent
      value_index = parent_index
    else
      heap[value_index] = value
      break
    end
  end

  heap[value_index] = value
end


function heap:pop()

  local heap = self.heap
  local ret_value = heap[1]

  local size = #heap
  local node_value = heap[size]
  heap[size] = nil

  if size == 1 then
    return ret_value
  end

  local node_index = 1

  while true do

    local left_index = 2 * node_index
    local right_index = left_index + 1

    local smallest_index = node_index
    local smallest_value = node_value

    if left_index < size then
      local left_value = heap[left_index]
      if left_value < smallest_value then
        smallest_index = left_index
        smallest_value = left_value
      end
    end

    if right_index < size then
      local right_value = heap[right_index]
      if right_value < smallest_value then
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

  return ret_value
end


function heap:is_empty()
  return self.heap[1] == nil
end


return {
  new = function()
    return setmetatable( { heap = {} }, heap )
  end
}
