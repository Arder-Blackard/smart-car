asphalt = {
  type = "tile",
  name = "asphalt",
  needs_correction = false,
--  minable = { hardness = 0.2, mining_time = 0.5, result = "asphalt" },
  mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
  collision_mask = { "ground-tile" },
  walking_speed_modifier = 2,
  layer = 61,
  decorative_removal_probability = 0,
  variants =
  {
    main =
    {
      {
        picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt1.png",
        count = 16,
        size = 1
      },
      {
        picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt2.png",
        count = 4,
        size = 2,
        probability = 0.39,
      },
      {
        picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt4.png",
        count = 4,
        size = 4,
        probability = 1,
      },
    },
    inner_corner =
    {
      picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt-inner-corner.png",
      count = 16
    },
    outer_corner =
    {
      picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt-outer-corner.png",
      count = 8
    },
    side =
    {
      picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt-side.png",
      count = 8
    },
    u_transition =
    {
      picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt-u.png",
      count = 8
    },
    o_transition =
    {
      picture = "__smart-car-control__/graphics/terrain/asphalt/asphalt-o.png",
      count = 1
    }
  },
  walking_sound =
  {
    {
      filename = "__base__/sound/walking/concrete-01.ogg",
      volume = 1.2
    },
    {
      filename = "__base__/sound/walking/concrete-02.ogg",
      volume = 1.2
    },
    {
      filename = "__base__/sound/walking/concrete-03.ogg",
      volume = 1.2
    },
    {
      filename = "__base__/sound/walking/concrete-04.ogg",
      volume = 1.2
    }
  },
  map_color = { r = 100, g = 100, b = 100 },
  ageing = 0,
  vehicle_friction_modifier = 0.6
}


asphalt_item = {
  type = "item",
  name = "asphalt",
  icon = "__smart-car-control__/graphics/icons/asphalt.png",
  flags = { "goes-to-main-inventory" },
  subgroup = "terrain",
  order = "b[concrete]",
  stack_size = 100,
  place_as_tile =
  {
    result = "asphalt",
    condition_size = 4,
    condition = { "water-tile" }
  }
}

asphalt_recipe = {
  type = "recipe",
  name = "asphalt",
  energy_required = 10,
  enabled = false,
  category = "crafting-with-fluid",
  ingredients =
  {
    { "stone-brick", 5 },
    { "iron-ore", 1 },
    { type = "fluid", name = "water", amount = 10 }
  },
  result = "asphalt",
  result_count = 10
}

data:extend { asphalt, asphalt_item, asphalt_recipe }
