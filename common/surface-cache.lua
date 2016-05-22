require "common.helpers"

local surface_cache = {}
surface_cache.__index = surface_cache

---
---
---
function surface_cache:get_cell( x, y )

  local surface = self.surface

  local row = self[y]
  if row ~= nil then
    local cell = row[x]
    if cell ~= nil then
      return cell
    end
  end

  if row == nil then
    row = {}
    self[y] = row
  end

  local tile = surface.get_tile( x, y )
  local cell = { passable = not tile.collides_with( "player-layer" ), state = 0 }
  row[x] = cell
  return cell

end

return {
  new = function( surface )
    prnt( "  Creating surface cache. Surface: " .. surface.name )
    return setmetatable( { surface = surface }, surface_cache )
  end
}
