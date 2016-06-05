require "scripts.common.helpers"
local math2 = require "scripts.common.math2"

local road_path = {}
road_path.__index = road_path

function road_path:new( points )

  debug( "road_path:new( table#" .. #points .. " )" )

  local waypoints = {}

  for i = 1, #points do

    local p = points[i]
    local type = ((i == 1) and 0) or ((i == #points) and 1) or 2
    local angle
    if type > 1 then
      angle = math2.orientation_delta( math2.orientation( points[i-1], p ), math2.orientation( p, points[i+1] ) )
    end

    local waypoint = {
      x = p.x,
      y = p.y,
      type = type,
      angle = angle
    }

    debug_table( waypoint, "wp#".. i )

    table.insert( waypoints, waypoint )
  end

  debug( "Generated RoadPath consisting of " .. #waypoints .. " points" )

  return setmetatable(
    {
      waypoints = waypoints,
      current_point = 1
    },
    road_path
  )

end

---
---
---
function road_path:get_current_point()
  return self.waypoints[ self.current_point ]
end

---
---
---
function road_path:goto_next_point()
  self.current_point = self.current_point + 1
end

---
---
---
function road_path:is_finished ()
  return self.current_point > #self.waypoints
end


return {
  new = function( points )
    return road_path:new( points )
  end
}
