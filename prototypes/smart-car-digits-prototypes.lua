local function define_digit( digit )
  return {
    type = "decorative",
    name = "gui-digit-" .. tostring( digit ),
    flags = {"placeable-off-grid", "not-on-map"},
    selectable_in_game = false,
    collision_box = { {-0.1, -0.1}, {0.1, 0.1} },
    collision_mask = {"not-colliding-with-itself"},
    render_layer = "smoke",
    pictures =
    {
      filename = "__smart-car-control__/graphics/gui/digits.png",
      priority = "low",
      x = 5 * digit,
      y = 0,
      scale = 1,
      width = 5,
      height = 10,
      shift = { -5/2/32, 5/32 }, -- hand in the left corner
    }
  }
end

data:extend{
  define_digit( 0 ),
  define_digit( 1 ),
  define_digit( 2 ),
  define_digit( 3 ),
  define_digit( 4 ),
  define_digit( 5 ),
  define_digit( 6 ),
  define_digit( 7 ),
  define_digit( 8 ),
  define_digit( 9 )
}
