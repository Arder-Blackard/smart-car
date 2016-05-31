local algorithm = {}

---
--- Performs binary search in array.
--- @param array the array to search in. Must be sorted in ascending order.
--- @param value the value to search for.
--- @returns index of the value if it is found, pair of (false, insert_position) otherwise
function algorithm.binary_search( array, value )
  local left, right = 1, #array
  while left <= right do
    local mid = math.floor( (left + right) / 2 )
    local item_value = array[ mid ]
    if item_value == value then
      return mid
    elseif value < item_value then
      right = mid - 1
    else
      left = mid + 1
    end
  end

  return false, left
end

return algorithm
