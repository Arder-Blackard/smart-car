require "defines"

math2 = {

  ---
  --- Scales angle in radians to Factorio-style orinetation [0..1]
  ---
  scale = 1 / math.pi / 2;

  ---
  --- Detects the orientation of a vector 'from' -> 'to'
  ---
  orientation = function( from, to )
    return 0.5 - math.atan2( to.x - from.x, to.y - from.y ) * math2.scale;
  end,

  orientation_delta = function( source_orientation, target_orientation )
    local delta = target_orientation - source_orientation
    if delta > 0.5 then
      delta = delta - 1
    elseif delta < -0.5 then
      delta = delta + 1
    end
    return delta
  end,

  orientation_to_radians = function( orientation )
    return orientation * 6.2831853071795864769
  end,

  get_rotation_direction = function( orientation_delta, epsilon )
    epsilon = epsilon or 0.05
    if orientation_delta < epsilon and orientation_delta > -epsilon then
      return defines.riding.direction.straight
    elseif orientation_delta > 0 then
      return defines.riding.direction.right
    else
      return defines.riding.direction.left
    end
  end,


}

