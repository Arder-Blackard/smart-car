
local road_node_item = {
  type = "item",
  name = "asphalt-node",
  icon = "__smart-car-control__/graphics/icons/asphalt-node.png",
  flags = {"goes-to-quickbar"},
  subgroup = "other",
  order = "b-b-b",
  place_result = "asphalt-node",
  stack_size = 1,
}

local road_node_entity = {
  type = "decorative",
  name = "asphalt-node",
  flags = { "placeable-neutral", "not-on-map" },
  icon = "__smart-car-control__/graphics/icons/asphalt-node.png",
  collision_mask = { "ghost-layer" },
  subgroup = "grass",
  order = "b[decorative]-b[smart-car-controller]",
  collision_box = { { -0.4, -0.4 }, { 0.4, 0.4 } },
  selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
  selectable_in_game = false,
  render_layer = "object",
  pictures = { { filename = "__smart-car-control__/graphics/icons/asphalt-node.png", width = 32, height = 32 } },
}

data:extend{ road_node_item, road_node_entity }
