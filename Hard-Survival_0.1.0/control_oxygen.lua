
local Oxygen = {
  oxygen_max=100,
  oxygen_min=0,
  cabsule_durability=100,
  --efficiency=0.5,
  --armour_base_efficiency=0,
  --min_effective_efficiency=0.25,
  oxygen_per_second=1,
  --name_gui_root="oxygen-gui",
  tick_interval=60,
  --[[armour={
    ["armour-1"] = {efficiency = 1},
    ["armour-2"] = {efficiency = 2}
  }
  equipment={
    ["oxygen-mask"] = {efficiency = 1}
  } ]]
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

function Oxygen.canisters_left(player)
  local character = player.character or player_get_character(player)
  if not character then return end

  local inventory = character.get_main_inventory()
  if not inventory or not inventory.valid then return end

  local counts = {}
  for _,canister in pairs(Oxygen.canisters) do
    counts[canister.name] = inventory.get_item_count(canister.name)
  end

  return counts
end

function Oxygen.oxygen_left(player)
  local playerdata = get_make_playerdata(player)
  local character = player_get_character(player)
  local inv_reserve = 0

  if character then
    local inv = character.get_main_inventory()
    if inv and inv.valid then
      for _, canister in pairs(Oxygen.canisters) do
        inv_reserve = inv_reserve + inv.get_item_count(canister.name) * canister.oxygen
      end
    end
  end

  playerdata.oxygen_left = inv_reserve

  return inv_reserve
end

function Oxygen.oxygen_efficiency(player)
  local character = player_get_character(player)
  if not character then return end

  local playerdata = get_make_playerdata(player)
  local oxygen_efficiency = 0
  local has_armour = false

  local armor_inv = character.get_inventory(defines.inventory.character_armor)
  if armor_inv and armor_inv[1] and armor_inv[1].valid_for_read then
    if util.table_contains(name_thruster_suits, armor_inv[1].name) then
      oxygen_efficiency = Oxygen.armour_base_efficiency
      has_armour = true
    end

    local grid_efficiency = 0
    if character.grid then
      for name, count in pairs(character.grid.get_contents()) do
        if Oxygen.equipment[name] ~= nil then
          grid_efficiency = grid_efficiency + count * (Oxygen.equipment[name].efficiency or 0)
        end
      end
    end
    oxygen_efficiency = oxygen_efficiency + grid_efficiency
  end

  playerdata.oxygen_efficiency = oxygen_efficiency
  playerdata.has_armour = has_armour

  return oxygen_efficiency
end

function Oxygen.consume_oxygen(player)
  local playerdata = get_make_playerdata(player)
  local character = player_get_character(player)
  if not character then return end

  local efficiency = Oxygen.oxygen_efficiency(player)

  local effective_efficiency = math.max(efficiency, Oxygen.min_effective_efficiency)
  local hazard_use_rate_per_s = Oxygen.oxygen_per_second
  local effective_use_rate_per_s = hazard_use_rate_per_s / effective_efficiency
  local effective_use_per_interval = Oxygen.tick_interval * effective_use_rate_per_s

  if efficiency > 0 then
    playerdata.oxygen = (playerdata.oxygen or 0) - effective_use_per_interval
    if playerdata.oxygen <= Oxygen.oxygen_min then
      Oxygen.consume_canister(player, playerdata, character)
    end
    if playerdata.oxygen < 0 then
      Oxygen.damage_character(player, character, -playerdata.oxygen)
      playerdata.oxygen = 0
    end
  else
    Oxygen.damage_character(player, character, effective_use_per_interval)
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
    
  })

  frame.add({
    type="progressbar",
    name="oxygen-bar",
    size=100,
    value=0,
    style="progressbar",
    direction="horisontal"
  })
end

return Oxygen
