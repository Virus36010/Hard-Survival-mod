
local equ = "__Hard-Survival__/graphics/equipment/"

data:extend({
  {----------Personal-oxygen-generator
    type="movement-bonus-equipment",
    name="personal-oxygen-generator",
    energy_consumption = "0kW",
    movement_bonus = 0,
    categories = {"armor"},
    shape={
      width=3,
      height=3,
      type="full"
    },
    energy_source={
      type="electric",
      usage_priority="secondary-input"
    },
    sprite={
      filename = equ.."personal-oxygen-generator.png",
      width = 96,
      height = 96,
      priority = "medium",
      hr_version={
        filename = equ.."hr-personal-oxygen-generator.png",
        width = 192,
        height = 192,
        priority = "medium",
        scale = 0.5
      }
    },
  },

})