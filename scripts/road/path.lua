local math2 = require "scripts.common.math2"

local path = {}
path.__index = path

function path:new( points)

  local waypoints = {}

  for i = 1, #points do
    local p = points[i]
    local type = ((i == 1) and 0) or ((i == #points) and 1) or 2
    local angle
    if type > 1 then
      angle = math2.orientation_delta( math2.orientation( points[i-1], p ), math2.orientation( p, points[i+1] ) )
    end

    table.insert(
      waypoints,
      {
        x = p.x,
        y = p.y,
        type = type,
        angle = angle
      }
    )

  end

  return setmetatable(
    {
      waypoints = waypoints,
      current_target = 1
    },
    path
  )

end

---
---
---
function path:get_current_target()
  return self.waypoints[ self.next ]
end

---
---
---
function path:goto_next_point()
  self.next = self.next + 1
end

---
---
---
function path:is_finished ()
  return self.next > #self.waypoints
end


return {
  new = function( points )
    return path:new( points )
  end
}
