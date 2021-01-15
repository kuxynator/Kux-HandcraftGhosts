require "mod-gui"

script.on_init( function()
  global.player_info = {}

	for _, p in pairs( game.players ) do
		if not mod_gui.get_button_flow( p ).PlayerGhostCraft then
			local button = mod_gui.get_button_flow( p ).add{ type = "sprite-button", name = "PlayerGhostCraft", sprite = "item/iron-plate", tooltip = "Craft Ghost Queue", style="icon_button"}
		end
	end
end )

function autoCraft(player)
  local info = global.player_info[player.index]
  if not info then
    info = {
      player_position = player.position,
      next = 0,
      ghosts = {}
    }
    global.player_info[player.index] = info
  end

  local dx = player.position.x - info.player_position.x
  local dy = player.position.y - info.player_position.y
  info.player_position = player.position

  local reach = player.character.reach_distance
  if info.next >= #info.ghosts then
    local aabb =
    {
      left_top = {player.position.x - reach, player.position.y - reach},
      right_bottom = {player.position.x + reach, player.position.y + reach}
    }
    local ghosts = player.surface.find_entities_filtered{area=aabb, force=player.force, type="entity-ghost"}
    info.next = 1
    info.ghosts=ghosts
  end

  while info.next <= #info.ghosts do
    local ghost = info.ghosts[info.next]
    info.next = info.next + 1

    if ghost.valid then
      local dx = player.position.x - ghost.position.x
      local dy = player.position.y - ghost.position.y
      if dx*dx + dy*dy <= reach*reach then
        for _,stack in pairs(ghost.ghost_prototype.items_to_place_this) do

          local recipe = game.recipe_prototypes[stack.name]
		  local item = stack.name
          if player.force.recipes[item] ~= nil and ((player.get_craftable_count(item) > 0  and player.force.recipes[item].enabled == true)) then
            if recipe ~= nil and recipe.allow_as_intermediate then
              if player.begin_crafting({count=1, recipe=stack.name, silent=true}) > 0 then
	  		  player.print("Crafting " .. stack.name)

              end
			end
          end

        end
      end
    end
  end
end


script.on_event( defines.events.on_gui_click, function( event )
	local element = event.element
	local name = element.name
	local player = game.players[event.player_index]

	if not name then return end

	if name == "PlayerGhostCraft" then
	    autoCraft(player)
	end
end )

script.on_event( defines.events.on_player_created, function( event )
	local button = mod_gui.get_button_flow( game.players[event.player_index] ).add{ type = "sprite-button", sprite = "item/iron-plate", name = "PlayerGhostCraft", tooltip = "Handcraft Ghosts" }
end )