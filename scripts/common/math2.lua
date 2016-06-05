require "defines"

local math2 = {
  ---
  --- Scales angle in radians to Factorio-style orinetation [0..1]
  ---
  scale = 1 / math.pi / 2
}
  ---
  --- Detects the orientation of a vector 'from' -> 'to'
  ---
function math2.orientation( from, to )
  return 0.5 - math.atan2( to.x - from.x, to.y - from.y ) * math2.scale;
end

function math2.orientation_delta( source_orientation, target_orientation )
  local delta = target_orientation - source_orientation
  if delta > 0.5 then
    delta = delta - 1
  elseif delta < -0.5 then
    delta = delta + 1
  end
  return delta
end

function math2.orientation_to_radians( orientation )
  return orientation * 6.2831853071795864769
end

function math2.rotation_direction( orientation_delta, epsilon )
  epsilon = epsilon or 0.01
  if orientation_delta < epsilon and orientation_delta > -epsilon then
    return defines.riding.direction.straight
  elseif orientation_delta > 0 then
    return defines.riding.direction.right
  else
    return defines.riding.direction.left
  end
end

function math2.opposite_direction ( direction )
  if direction == defines.riding.direction.left then
    return defines.riding.direction.right
  elseif direction == defines.riding.direction.right then
    return defines.riding.direction.left
  else
    return direction
  end
end

function math2.distance_sqr( from, to )
  local dx = from.x - to.x
  local dy = from.y - to.y
  return dx * dx + dy * dy
end

function math2.point_along_orientation( position, orientation, distance )
  local angle = math2.orientation_to_radians( orientation )
  return {
    x = position.x + distance * math.sin( angle ),
    y = position.y - distance * math.cos( angle )
  }
end

function math2.reverse_orientation( orientation )
  if orientation > 0.5 then
    return orientation - 0.5
  else
    return orientation + 0.5
  end
end

function math2.sign( value )
  if value > 0 then
    return 1
  elseif value < 0 then
    return -1
  else
    return 0
  end
end

return math2
