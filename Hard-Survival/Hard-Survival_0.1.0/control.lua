
Oxygen = require("control_oxygen")
require("util")

starting_items={["big-oxyn-canister"] = 5}

script.on_init(function()
  local items = remote.call("freeplay", "get_created_items")
  for k,v in pairs(starting_items) do
    items[k] = v
  end
  remote.call("freeplay", "set_created_items", items)
end)

script.on_event(defines.events.on_player_created, function(event)
  --Oxygen.gui(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_respawned, function(event)
	util.insert_safe(game.players[event.player_index], {["oxyn-canister"] = 1})
end)

script.on_configuration_changed(function(data)
	if data.mod_changes ~= nil and data.mod_changes["Oxygen"] ~= nil then
		for i,p in pairs(game.players) do
			util.insert_safe(game.players[i], starting_items)
		end
	end
end)

local ticks = 0
script.on_tick(function(player)
  if ticks == Oxygen.tick_interval then 
    Oxygen.
  else end
end)
