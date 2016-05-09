require "defines"

function prnt( text )
  if game and #game.players > 0 then
    game.player.print( text )
  end
end

function prnt_bool( value )
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