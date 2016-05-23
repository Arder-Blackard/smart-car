require "util"

-- local tank_red, tank_red_item, tank_red_recipe = createTank( "tank-red", {r=1, g=0, b=0, a=0.5}, 0.1 )
-- local tank_green, tank_green_item, tank_green_recipe = createTankUnit( "tank-unit-green", 0.2 )

local recipe = {
  type = "recipe",
  name = "smart-car-controller-recipe",
  enabled = true,
  ingredients = { { "iron-plate", 1 } },
  result = "smart-car-controller-item"
}

local item = {
  type = "item",
  name = "smart-car-controller-item",
  icon = "__smart-car-control__/graphics/icons/car.png",
  flags = {"goes-to-quickbar"},
  subgroup = "other",
  order = "b-b-b",
  place_result = "smart-car-controller",
  stack_size = 1,
}

local entity = {
  type = "decorative",
  name = "smart-car-controller",
  flags = { "placeable-neutral", "placeable-off-grid", "not-on-map" },
  icon = "__smart-car-control__/graphics/icons/car.png",
  collision_mask = { "ghost-layer" },
  subgroup = "grass",
  order = "b[decorative]-b[smart-car-controller]",
  collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
  selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
  selectable_in_game = false,
  render_layer = "object",
  pictures = { { filename = "__smart-car-control__/graphics/icons/car.png", width = 32, height = 32 } },
  minable = { mining_time = 0.1, result = "smart-car-controller-item" }
}

local mark = {
  type = "decorative",
  name = "mark",
  icon = "__smart-car-control__/graphics/entities/shoot.png",
  flags = { "placeable-neutral", "placeable-off-grid", "not-on-map" },
  collision_mask = { "not-colliding-with-itself" },
  subgroup = "grass",
  order = "b[decorative]-b[smart-car-controller]",
  collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
  selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
  selectable_in_game = false,
  render_layer = "smoke",
  pictures = { { filename = "__smart-car-control__/graphics/entities/shoot.png", width = 32, height = 32 } },
}

--
--  TODO: Provide a different look for an automated driver
--
local driver = {
    type = "player",
    name = "smart-car-driver",
    icon = "__base__/graphics/icons/player.png",
    flags = {"pushable", "placeable-off-grid", "not-repairable", "not-on-map"},
    max_health = 100,
    alert_when_damaged = false,
    healing_per_tick = 0.01,
    collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    selection_box = {{-0.4, -1.4}, {0.4, 0.2}},
    crafting_categories = {"crafting"},
    mining_categories = {"basic-solid"},
    inventory_size = 60,
    build_distance = 6,
    drop_item_distance = 6,
    reach_distance = 6,
    reach_resource_distance = 2.7,
    ticks_to_keep_gun = 600,
    ticks_to_keep_aiming_direction = 100,
    damage_hit_tint = {r = 0, g = 0, b = 0, a = 0},
    running_speed = 0.15,
    distance_per_frame = 0.13,
    maximum_corner_sliding_distance = 0.7,
    subgroup = "creatures",
    order="a",
    eat =
    {
      {
        filename = "__base__/sound/eat.ogg",
        volume = 0
      }
    },
    heartbeat =
    {
        filename = "__base__/sound/eat.ogg",
        volume = 0
    },
    animations =
    {
      {
        idle =
        {
          layers =
          {
            playeranimations.level1.idle,
            playeranimations.level1.idlemask,
          }
        },
        idle_with_gun =
        {
          layers =
          {
            playeranimations.level1.idlewithgun,
            playeranimations.level1.idlewithgunmask,
          }
        },
        mining_with_hands =
        {
          layers =
          {
            playeranimations.level1.miningwithhands,
            playeranimations.level1.miningwithhandsmask,
          }
        },
        mining_with_tool =
        {
          layers =
          {
            playeranimations.level1.miningwithtool,
            playeranimations.level1.miningwithtoolmask,
          }
        },
        running_with_gun =
        {
          layers =
          {
            playeranimations.level1.runningwithgun,
            playeranimations.level1.runningwithgunmask,
          }
        },
        running =
        {
          layers =
          {
            playeranimations.level1.running,
            playeranimations.level1.runningmask,
          }
        }
      }
    },
    mining_speed = 0,
    mining_with_hands_particles_animation_positions = {29, 63},
    mining_with_tool_particles_animation_positions = {28},
    running_sound_animation_positions = {5, 16}
}

data:extend {
  recipe, item, entity, driver, mark
}
