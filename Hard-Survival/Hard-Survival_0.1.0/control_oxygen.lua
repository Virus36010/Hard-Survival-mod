
local Oxygen = {
  cabsule_durability=100,
  efficiency=1,
  armour_base_efficiency=0,
  oxygen_per_second=1,
  tick_interval=60,
  --[[armour={
    ["armour-1"] = {efficiency = 1},
    ["armour-2"] = {efficiency = 2}
  }]]
  equipment={
    --["oxygen-mask"] = {efficiency = 2}
    ["personal-oxygen-generator"] = {efficiency = 4}
  }
  canisters={
    {
      name="oxyn-ore",
      used="",
      oxygen=10
    },
    {
      name="oxyn-canister",
      used="empty-oxyn-canister",
      oxygen=50
    },
    {
      name="big-oxyn-canister",
      used="empty-oxyn-canister",
      oxygen=100
    }
  },
  tech_bar={
    {name = "oxygen", size = 150},
    {name = "more-oxygen", size = 350},
    {name = "more-oxygen-2", size = 750}
  },
}

function Oxygen.seconds_to_clock(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds / 60) - (h * 60))
  local s = math.floor(seconds - (m * 60) - (h * 3600))

  local str_h = string.format("%02d", h)
  local str_m_s = string.format("%02d:%02d", m, s)

  if h > 0 then
    return str_h .. ":" .. str_m_s
  else
    return str_m_s
  end
end

function Oxygen.oxygen_left(player)
  local character = player.character or player_get_character(player)
  local oxygen_left = 0

  if character then
    local inv = character.get_main_inventory()
    if inv and inv.valid then
      for _, canister in pairs(Oxygen.canisters) do
        oxygen_left = oxygen_left + inv.get_item_count(canister.name) * canister.oxygen
      end
    end
  end

  return oxygen_left
end

function Oxygen.time_left(player)
  local efficiency = Oxygen.oxygen_efficiency(player)
  local tick_interval = Oxygen.tick_interval

  local ticks = tick_interval * efficiency
  local oxygen_left = Oxygen.oxygen_left(player)

  local time = oxygen_left/ticks

  return Oxygen.seconds_to_clock(time)
end

function Oxygen.oxygen_efficiency(player)
  local character = player.character or player_get_character(player)
  if not character then return end

  local oxygen_efficiency = 0

  local armor_inv = character.get_inventory(defines.inventory.character_armor)
  if armor_inv and armor_inv[1] and armor_inv[1].valid_for_read then
    --if util.table_contains(armor_inv[1].name) then
    --  has_armour = true
    --end
    local armor_efficiency = 0

    local equipment_efficiency = Oxygen.efficiency
    if character.grid then
      for name, count in pairs(character.grid.get_contents()) do
        if Oxygen.equipment[name] ~= nil then
          equipment_efficiency = equipment_efficiency + (Oxygen.equipment[name].efficiency or 0)
        end
      end
    end
  end

  oxygen_efficiency = oxygen_efficiency + equipment_efficiency + armor_efficiency

  return oxygen_efficiency
end

function Oxygen.consume_oxygen(player)
  local tick_interval = Oxygen.tick_interval
  local efficiency = Oxygen.oxygen_efficiency()
  local ticks = tick_interval * efficiency

  local character = player.character or player_get_character(player)
  if not character then return end

  local oxygen = player.gui.relative_gui_position.bottom.oxygen_bar.value
  local max_oxygen = player.gui.relative_gui_position.bottom.oxygen_bar.size

  if max_oxygen - oxygen == 100 then
    oxygen = oxygen +
  end
end

function Oxygen.consume_canister(player, playerdata, character)
  local inventory = character.get_main_inventory()
  if inventory and inventory.valid then
    local prod_stats = player.force.item_production_statistics
    for _, oxygen_canister in pairs(Oxygen.canisters) do
      local count = inventory.get_item_count(oxygen_canister.name)
      if count > 0 then
        inventory.remove({name=oxygen_canister.name, count=1})
        local inserted = inventory.insert({name=oxygen_canister.used, count=1})
        if inserted < 1 then
          local position = character.position
          character.surface.spill_item_stack(position, {name=oxygen_canister.used, count=1}, true, character.force, false)
          character.surface.create_entity{
            name = "flying-text",
            position = position,
            text = {
              "inventory-restriction.player-inventory-full",
              "[img=item/" .. lifesupport_canister.used .. "]",
              {"inventory-full-message.main"}
            },
            render_player_index = player.index
          }
        end
        prod_stats.on_flow(oxygen_canister.name, -1)
        prod_stats.on_flow(oxygen_canister.used, 1)
        playerdata.oxygen = (playerdata.oxygen or 0) + oxygen_canister.oxygen
        --player.play_sound { path = oxygen.name_sound_used_canister }
        return
      end
    end
  end
end

function Oxygen.damage_character(player, character, damage)
  if damage > character.health then
    character.die("neutral")
    return
  end
  character.damage(damage, "neutral", "suffocation")
end

function Oxygen.gui(player)
  local frame=player.gui.left.add({
    type="frame",
    name="oxygen-gui",
    direction="vertical"
  })

  frame.add({
    type="label",
    name="oxygen-left",
    caption={"Oxygen left: "..Oxygen.oxygen_left()}
  })

  frame.add({
    type="label",
    name="time-left",
    caption={"Time left: "..Oxygen.time_left()}
  })

  player.gui.relative_gui_position.bottom.add({
    type="progressbar",
    name="oxygen_bar",
    size=Oxygen.tech_bar[1].size,
    value=0,
    style="progressbar",
    direction="horisontal"
  })
end

return Oxygen
