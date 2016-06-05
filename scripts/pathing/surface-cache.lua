require "scripts.common.helpers"

local surface_cache = {}
surface_cache.__index = surface_cache

---
---
---
function surface_cache:check_cell_passability( x, y, size )

  local surface = self.surface
  local cache = self.cache

  local is_ref_cell_passable = 0

  for row = y - size, y + size do

    --  Get or create row
    local cells_row = cache[row]
    if not cells_row then
      cells_row = {}
      cache[row] = cells_row
    end

    for column = x - size, x + size do

      --  Skip the reference cell
      if column ~= x or row ~= y then

        --  Get or create cell
        local cell = cells_row[column]
        if not cell then
          if surface.get_tile( column, row ).collides_with( "player-layer" ) then
            cells_row[column] = { state = 4 }
            is_ref_cell_passable = 3
          else
            cells_row[column] = { state = -1 }
          end
        else
          if cell.state == 4 then
            is_ref_cell_passable = 3
          end
        end
      end

    end
  end

  return is_ref_cell_passable
end

---
---
---
function surface_cache:get_cell( x, y, size )

  local cache = self.cache

  local cell

  local cells_row = cache[y]
  if cells_row ~= nil then
    cell = cells_row[x]
  else
    cells_row = {}
    cache[y] = cells_row
  end

  if cell then
    if cell.state == -1 then
      cell.state = self:check_cell_passability( x, y, size )
    end
  else
    local is_blocking = self.surface.get_tile( x, y ).collides_with( "player-layer" )
    cell = { state = is_blocking and 4 or self:check_cell_passability( x, y, size ) }
  end

  return cell

end

return {
  new = function( surface )
    debug( "  Creating surface cache. Surface: " .. surface.name )
    return setmetatable( { surface = surface, cache = {} }, surface_cache )
  end
}
