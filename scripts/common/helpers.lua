require "defines"

function debug( text )
  if game and #game.players > 0 then
    game.player.print( text )
  end
end

function debug_table( tbl, name )
  local t = { (name and (name .. ": ") or ""), "[ " }
  for k,v in pairs( tbl ) do
    t[#t+1] = tostring( k )
    t[#t+1] =  "="
    t[#t+1] = tostring( v )
    t[#t+1] = "; "
  end
  t[#t+1] = "]"
  debug( table.concat( t ) )
end

function debug_bool( value )
  if value then
    game.player.print( "true" )
  else
    game.player.print( "false" )
  end
end

function table_contains( table, value )
  for k,v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function array_remove( array, value )
  for index, contained_value in ipairs( array ) do
    if contained_value == value then
      table.remove( array, value )
      return true
    end
  end
  return false
end


function table_remove_value( tbl, value )
  for key, contained_value in pairs( tbl ) do
    if contained_value == value then
      tbl[key] = nil
      return true
    end
  end
  return false
end

---
--- Mimics mining the mineable entity by destroying it
--- and giving the player entity result products
---

function mine_entity( entity, player )
  if entity.prototype and
     entity.prototype.mineable_properties and
     entity.prototype.mineable_properties.products
  then
    local products = entity.prototype.mineable_properties.products

    entity.destroy()
    for i, product in ipairs( products ) do
      player.insert{
        name = product.name,
        count = product.amount
      }
    end
  end
end

function get_digits( number )
  local digits_reversed = {}
  local size = 0

  while number >= 1 do
    size = size + 1
    digits_reversed[ size ] = math.floor( number % 10 )
    number = number / 10
  end

  if size == 0 then
    return { 0 }
  end

  local digits = {}
  for i = size,1,-1 do
    digits[size - i + 1] = digits_reversed[i]
  end
  return digits
end

local scale = 5 / 32

function draw_number( surface, x, y, number, right, bottom)

  local digits = get_digits( number )
  local length = #digits

  local x_offset = math.floor( x ) + (right and (0.95 - length * scale) or 0.05 )
  local y_offset = math.floor( y ) + (bottom and 0.6875 or 0)

  for i = 1, length do
    local digit_x = x_offset + i * scale
    local digit_y = y_offset
    surface.create_entity{
      name = "gui-digit-" .. digits[i],
      position = { digit_x, digit_y }
    }
  end
end
