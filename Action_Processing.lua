
function on_action(action)

	-- 1. Melee attack
	-- 2. Finish ranged attack
	-- 3. Finish weapon skill
	-- 4. Finish spell casting
	-- 5. Finish item use
	-- 6. Use job ability
	-- 7. Begin weapon skill or TP move
	-- 8. Begin spell casting or interrupt casting
	-- 9. Begin item use or interrupt usage
	-- 10. Unknown – Probably was intended to be the “readies” messages for JAs, which was unnecessary because they are instant.
	-- 11. Finish TP move
	-- 12. Begin ranged attack
	-- 13. Pet completes ability/WS
	-- 14. Unblinkable job ability
	-- 15. Some RUN job abilities
	
	-- Must verify that all potential actors exist, if using windower.ffxi.get_mob_by_####### after zoning,
	-- then it will return nil as the mob structure does not exist yet,
	-- so we use currently saved mob structures with our party list to aquire relevent information
	
	if action == nil then return end
	local actor = {}
	for index, m_table in pairs(member_table) do
		if member_table[index].id == action.actor_id then
			actor = member_table[index].mob
			break
		end
	end
	if actor == nil then return end
	
	local spells_to_watch = S{'Marcato', 'Soul Voice', 'Haste', 'Haste II', 'Hastega', 'Hastega II', "Erratic Flutter", 'Refueling', 'Honor March', 'Victory March', 'Advancing March'}
	
	if action.actor_id == player.id and action.category == 1 then
		if action.targets[1].actions[1].reaction == 8 then
			if action.targets[1].actions[1].add_effect_animation == 23 then
				--add_to_chat(122, 'haste spikes')
				if buff_info.h_spikes ~= true then
					buff_info.h_spikes = true
				end
			elseif action.targets[1].actions[1].add_effect_animation ~= 23 then
				if buff_info.h_spikes == true then
					buff_info.h_spikes = false
				end
			end
		end
	end
	-- if action.category == 3 and ((actor.is_npc and actor.charmed) or not actor.is_npc) and (action.param < 781 and action.param > 15 )then
		-- local job_abil = res.job_abilities:with('id', action.param)
		-- if spells_to_watch:contains(job_abil.en) then -- Garuda Hastega II
			-- for index, target in pairs(action.targets) do
				-- if type(target) == "table" then
					-- if target.id == player.id then
						-- -- member_table[windower.ffxi.get_mob_by_id(action.actor_id).name].Last_Spell = job_abil.en
						-- -- table.vprint(member_table[windower.ffxi.get_mob_by_id(action.actor_id).name])
						-- -- log('param 3 ' .. job_abil.en .. ' ' .. action.actor_id)
					-- end
				-- end
			-- end
		-- end
	-- end
	-- if action.category == 6 and ((actor.is_npc and actor.charmed) or not actor.is_npc) and (action.param < 781 and action.param > 15 )then
		-- local job_abil = res.job_abilities:with('id', action.param)
		-- if spells_to_watch:contains(job_abil.en) then -- Garuda Hastega II
			-- for index, target in pairs(action.targets) do
				-- if type(target) == "table" then
					-- if target.id == player.id then
						-- --member_table[windower.ffxi.get_mob_by_id(action.actor_id).name].Last_Spell = job_abil.en
						-- --table.vprint(member_table[windower.ffxi.get_mob_by_id(action.actor_id).name])
						-- --log('param 6 ' .. job_abil.en .. ' ' .. action.actor_id)
					-- end
				-- end
			-- end
		-- end
	-- end
	if action.category == 7 and ((actor.is_npc and actor.charmed) or not actor.is_npc) then
		for index, target in pairs(action.targets) do
			if type(target) == "table" then
				local job_abil = res.job_abilities:with('id', target.actions[1].param)
				 -- Garuda is doing Hastega / II, need to check who garuda belongs to
				for index, m_table in pairs(member_table) do
					if member_table[index].id == target.id then
						Pet_belongs_to = index
						break
					end
				end
			end
		end
		
	end
	--pet abilities
	if action.category == 13 and ((actor.is_npc and actor.charmed) or not actor.is_npc) and (action.param < 781 and action.param > 15 )then
		--table.vprint(action)
		local job_abil = res.job_abilities:with('id', action.param)
		if spells_to_watch:contains(job_abil.en) then -- Garuda Hastega / II
			for index, target in pairs(action.targets) do
				if type(target) == "table" then
					if target.id == player.id then
						if Pet_belongs_to then
							member_table[Pet_belongs_to].Last_Spell = job_abil.en
							Pet_belongs_to = nil
						end
					end
				end
			end
		end
	end
	if action.category == 4 and ((actor.is_npc and actor.charmed) or not actor.is_npc) and (action.param < 879 and action.param > 0 ) then
		local spell = res.spells:with('id', action.param)
		for index, target in pairs(action.targets) do
			if type(target) == "table" then
				if target.id == player.id then
					if spells_to_watch:contains(spell.en) then
						for index, m_table in pairs(member_table) do
							if member_table[index].id == action.actor_id then
								member_table[index].Last_Spell = spell.en
								break
							end
						end
					end
				end
			end
		end
	end
end

windower.register_event('action', function(act)
	if loged_in_bool == false and loged_out_bool == false then
		on_action(act)
	end
end)

function check_player_movement(player)
	if player.position == nul then
		player.position = T{} 
		player.position = {x = 0, y = 0, x = 0} 
	end
	if windower.ffxi.get_mob_by_index(player.index) ~= null then
        current_pos_x = windower.ffxi.get_mob_by_index(player.index).x
        current_pos_y = windower.ffxi.get_mob_by_index(player.index).y
		current_pos_z = windower.ffxi.get_mob_by_index(player.index).z
		if player.position.x ~= current_pos_x and player.position.y ~= current_pos_y then
			player.is_moving = true
		else
			player.is_moving = false
		end
		player.position.x = current_pos_x
		player.position.y = current_pos_y
		player.position.z = current_pos_z
	end
	
	return player.is_moving
end