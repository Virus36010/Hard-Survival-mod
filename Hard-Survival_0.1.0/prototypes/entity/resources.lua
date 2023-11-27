
local resource_autoplace = require('resource-autoplace')
local noise = require("noise")
local tne = noise.to_noise_expression
local resource_autoplace = require("resource-autoplace")
local sounds = require("sounds")

local icon = "__Hard-Survival__/graphics/icons/"
local ent = "__Hard-Survival__/graphics/entities/"

resource_autoplace.initialize_patch_set("oxyn-ore", true)

data:extend({
  {----------Oxyn-ore
    type="resource",
    name="oxyn-ore",
    icon = icon.."oxyn-ore.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral"},
    subgroup="raw-resource",
    order="b-b-d",
    tree_removal_probability = 0.8,
    tree_removal_max_distance = 32 * 32,
    map_color = {r=70, g=168, b=185},
    minable = {
      mining_particle = "oxyn-ore-particle",
      mining_time = 1,
      result = "oxyn-ore"
    },
    walking_sound = sounds.ore,
    collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace=resource_autoplace.resource_autoplace_settings{
      base_density = 7,
      regular_rq_factor_multiplier = 1.10,
      starting_rq_factor_multiplier = 1.5,
      name = "oxyn-ore",
      order = "d",
      has_starting_area_placement = true,
      base_spots_per_km2 = 10,
    },
    stage_counts = {15000, 9500, 5500, 2900, 1300, 400, 150, 80},
    stages = {
      sheet = {
        filename = ent.."oxyn-ore.png",
        priority = "extra-high",
        size = 64,
        frame_count = 8,
        variation_count = 8,
        hr_version = {
          filename = ent.."hr-oxyn-ore.png",
          priority = "extra-high",
          size = 128,
          frame_count = 8,
          variation_count = 8,
          scale = 0.5
        }
      }
    },
  },
  {
    type = "autoplace-control",
    category = "resource",
    name = "oxyn-ore",
    richness = true,
    order = "b-b-d"
	},
  {
    type = "noise-layer",
    name = "oxyn-ore"
	},

})
