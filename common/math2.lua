require "defines"

math2 = {

  scale = 1 / math.pi / 2;

  orientation_to_radians = function( orientation )
    return orientation * 6.2831853071795864769
  end,

  orientation = function( from, to )
    return 0.5 - math.atan2( to.x - from.x, to.y - from.y ) * math2.scale;
  end,


  get_rotation_direction = function ( source_orientation, target_orientation, epsilon )
    local delta = target_orientation - source_orientation
    if delta < 0 then
      delta = delta + 1
    end

    epsilon = epsilon or 0.05
    if delta < epsilon or delta > (1 - epsilon) then
      return defines.riding.direction.straight
    else
      return delta > 0.5 and defines.riding.direction.left or defines.riding.direction.right
    end
  end,
}
