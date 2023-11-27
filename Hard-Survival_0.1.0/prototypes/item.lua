
local icon="__Hard-Survival__/graphics/icons/"

data:extend({
  {----------Oxyn-ore
    type="item",
    name="oxyn-ore",
    icon=icon.."oxyn-ore.png",
    icon_size=64, scale=0.5, icon_mipmaps = 4,
    pictures={
      {size = 64, filename = icon.."oxyn-ore.png", scale = 0.25, mipmap_count = 4 },
    },
    subgroup = "raw-resource",
    order="c[oxyn]",
    stack_size = 50
  },

  {----------Empty-oxyn-canister
    type="item",
    name="empty-oxyn-canister",
    icon=icon.."empty-oxyn-canister.png",
    icon_size=64, scale=0.5, icon_mipmaps=1,
    subgroup="oxygen-capsule",
    order="a",
    stack_size=50
  },

  {----------Oxyn-canister
    type="item",
    name="oxyn-canister",
    icon=icon.."oxyn-canister.png",
    icon_size=64, scale=0.5, icon_mipmaps=1,
    subgroup="oxygen-capsule",
    order="b",
    stack_size=50
  },

  {----------Big-oxyn-canister
    type="item",
    name="big-oxyn-canister",
    icon=icon.."oxyn-canister.png",
    icon_size=64, scale=0.5, icon_mipmaps=1,
    subgroup="oxygen-capsule",
    order="c",
    stack_size=50
  },
})
