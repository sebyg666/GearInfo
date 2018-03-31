function get_tp_per_hit(equip)
	-- tp_per_hit = {melee = 0, range = 0}
	local tp_per_hit = determine_Base_tp_hit()
	local tp_per_hit_zanshin = 0
	local Job_STP = determine_stp()
	local Return_table = T{}
	local buff = Buffs_inform.STP

	--log("base delay =" ..base_delay.. ' | tp_per_hit :' .. tp_per_hit .. ' | Job_traits :'.. Job_STP )
	if player.main_job:upper() == 'SAM' then
		
		local jp = player.job_points['sam']['jp_spent']
		local jp_tp_bonus = 0
		
		if jp > 124 and jp < 450 then jp_tp_bonus = 2
		elseif jp > 449 and jp < 1050 then jp_tp_bonus = 4
		elseif jp > 1049 and jp < 1900 then jp_tp_bonus = 6
		elseif jp > 1899 and jp < 2101 then jp_tp_bonus = 8
		end
		
		--log('Main job is SAM Job points TP bonus value:' .. jp_tp_bonus)
		if Gear_info.stp ~= nil then
			local zanshin = tp_per_hit.melee + (3 * player.merits.ikishoten)
			--log('ikishoten merits = '.. player.merits.ikishoten .. ' STP merits: ' ..player.merits.store_tp_effect  )
			--log('zanshin = tp_per_hit + 3 x merits + jp bonus : ' .. zanshin)
			local merit_STP = (player.merits.store_tp_effect * 2)
			tp_per_hit_zanshin =  math.floor(zanshin * (100 + Gear_info.stp + Job_STP + merit_STP + jp_tp_bonus + buff) / 100 )
			--log('zanshin tp return = ' ..global_tp_hit_zanshin .. ' where gear STP = ' ..  Gear_info.stp)
			tp_per_hit.melee = math.floor(tp_per_hit.melee * (100 + Gear_info.stp + merit_STP + jp_tp_bonus + Job_STP + buff) / 100 )
			tp_per_hit.range = math.floor(tp_per_hit.range * (100 + Gear_info.stp + merit_STP + jp_tp_bonus + Job_STP + buff) / 100 )
		end
	else
		if Gear_info.stp ~= nil then
			tp_per_hit.melee = math.floor(tp_per_hit.melee * (100 + Gear_info.stp + Job_STP + buff) / 100 )
			tp_per_hit.range = math.floor(tp_per_hit.range * (100 + Gear_info.stp + Job_STP + buff) / 100 )
			tp_per_hit_zanshin = 0
		end
	end
	Return_table = {tp_per_hit_melee = tp_per_hit.melee, tp_per_hit_zanshin = tp_per_hit_zanshin, tp_per_hit_range = tp_per_hit.range }
	return Return_table
end

function determine_Base_tp_hit()
	
	--Weapon_Delay = T{melee_delay = 0, sub = false, ranged_delay = 0, range = false, ammo = false}
	
	local total_dw = 0
	local weapons = determine_Weapon_Delay()
	local DW = determine_DW()
	
	if Gear_info.dual_wield ~= nil and DW ~= nil then
		total_dw = Gear_info.dual_wield + DW
	end
	
	local base_delay = {melee = 0, range = 0}
	if weapons.sub then
		base_delay.melee = math.floor((weapons.melee_delay * (1 - (total_dw/100 ))) / 2)
		base_delay.range = weapons.ranged_delay
	else
		base_delay.melee = weapons.melee_delay
		base_delay.range = weapons.ranged_delay
	end
	--print('base delay: ' .. base_delay ..' | weapon: ' ..determine_Weapon_Delay() .. ' | DW: ' .. total_dw )
	local tp_per_hit = {melee = 0, range = 0}
	
	for k,v in pairs(base_delay) do
		if base_delay[k] < 181 and base_delay[k] > 0 then
			tp_per_hit[k] = 61 + ((base_delay[k] -180) * 63 / 360)
		elseif base_delay[k] > 180 and base_delay[k] < 541 then
			tp_per_hit[k] = 61 + ((base_delay[k] -180) * 88 / 360)
		elseif base_delay[k] > 540 and base_delay[k] < 631 then
			tp_per_hit[k] = 149 + ((base_delay[k] - 540) * 20 / 360)
		elseif base_delay[k] > 630 and base_delay[k] < 721 then
			tp_per_hit[k] = 154 + ((base_delay[k] - 630) * 28 / 360)
		elseif base_delay[k] > 720 and base_delay[k] < 901 then
			tp_per_hit[k] = 161 + ((base_delay[k] - 720) * 24 / 360)
		elseif base_delay[k] > 900 then
			tp_per_hit[k] = 173 + ((base_delay[k] - 900) * 28 / 360)
		else	
			tp_per_hit[k] = 0
		end
		--log('tp_per_hit.'..k..': ' .. tp_per_hit[k])
		tp_per_hit[k] = math.floor(tp_per_hit[k])
	end
	
	return tp_per_hit
end

function determine_stp()

	local sub_job_tp = 0
	local main_job_tp = 0
	local player_has_sj = false
	for k,v in pairs(player) do
		if k == 'sub_job' then
			--log(v)
			player_has_sj = true
		end
	end
	--log('player_has_sj ' .. tostring(player_has_sj))
	if player_has_sj == true then
		if player.sub_job:upper() == 'SAM' and player.sub_job_level < 10  then 
			sub_job_tp = 0
		elseif player.sub_job:upper() == 'SAM' and player.sub_job_level < 30 and  player.sub_job_level > 9 then 
			sub_job_tp = 10
		elseif player.sub_job:upper() == 'SAM' and player.sub_job_level < 50 and  player.sub_job_level > 31 then 
			sub_job_tp = 15
			--log('sub_job_tp = 15')
		end
	end
	
	if player.main_job:upper() == 'BLU' then
		-- here we look up job points spent on blue for the DW bonus
		local jp_boost = 0
		local jp = player.job_points['blu']['jp_spent']
		if jp < 100 then
			jp_boost = 0
		elseif jp >= 100 and jp < 1200 then
			jp_boost = 1
		elseif jp >= 1200 then
			jp_boost = 2
		end
		
		--here we look up spells currently equipped to check for DW trait
		local TP_Spells_Equipped_Level = 0
		local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return blu_spells[id].english end)
		--table.vprint(spells_set)
		local spell_value = 0
		-- here we give each spell a value of 4 or 8 and add the values together
		for index, spell in pairs(spells_set) do
		--for spell in spells_set:it() do
			if spell == "Sickle Slash" or spell == "Tail Slap" or spell == "Fantod" or spell == "Sudden Lunge" then
			   spell_value = spell_value + 4
			elseif spell == "Diffusion Ray" then 
				spell_value = spell_value + 8
			end
			--add_to_chat(122, '[Spell: '.. spell .. '] [Spell value: ' .. spell_value.. ']')
		end
		--add_to_chat(122, '[Spell value: ' .. spell_value.. ']')
		
		--here we determine the DW level equipped with job points
		if spell_value ~= 0 then
			TP_Spells_Equipped_Level = math.floor(spell_value / 8) + jp_boost
		else
			TP_Spells_Equipped_Level = 0
		end
		
		--the we determine the actuall % value of DW equipped via blu spells 
		if TP_Spells_Equipped_Level == 0 then main_job_tp = 0
		elseif TP_Spells_Equipped_Level == 1 then main_job_tp = 10
		elseif TP_Spells_Equipped_Level == 2 then main_job_tp = 15
		elseif TP_Spells_Equipped_Level == 3 then main_job_tp = 20
		elseif TP_Spells_Equipped_Level == 4 then main_job_tp = 25
		elseif TP_Spells_Equipped_Level == 5 then main_job_tp = 30
		end
		--add_to_chat(122, '[Sub dw: ' .. sub_job_dw .. '] [Main dw: ' .. main_job_dw .. ']')
	elseif player.main_job:upper() == 'SAM' then
		--log('entered job traits function')
		main_job_tp = 0
		if player.main_job:upper() == 'SAM' and player.main_job_level < 10  then main_job_tp = 0
		elseif player.main_job:upper() == 'SAM' and player.main_job_level < 30 and  player.main_job_level > 9 then main_job_tp = 10
		elseif player.main_job:upper() == 'SAM' and player.main_job_level < 50 and  player.main_job_level > 31 then main_job_tp = 15
		elseif player.main_job:upper() == 'SAM' and player.main_job_level < 70 and  player.main_job_level > 51 then main_job_tp = 20
		elseif player.main_job:upper() == 'SAM' and player.main_job_level < 90 and  player.main_job_level > 71 then main_job_tp = 25
		elseif player.main_job:upper() == 'SAM' and player.main_job_level < 100 and  player.main_job_level > 91 then main_job_tp = 30
		end
		
	end
	
	-- if the sub job DW is higher return that instead of blue mage spell DW
	if sub_job_tp > main_job_tp then
		--log(sub_job_tp .. ' sub_job_tp')
		return sub_job_tp
	else
		--log(main_job_tp .. ' main_job_tp')
		return main_job_tp
	end
end

function determine_Weapon_Delay()
	local Weapon_Delay = T{melee_delay = 480, sub = false, ranged_delay = 0, range = false, ammo = false}
	
	for k,v in pairs(player.equipment.main) do
		if k == 'delay' then
			Weapon_Delay.melee_delay = player.equipment.main.delay
		end		
	end
	for k,v in pairs(player.equipment.sub) do
		if player.equipment.sub.category == 'Weapon' then
			if k == 'damage' and v > 0 then
				Weapon_Delay.melee_delay = Weapon_Delay.melee_delay + player.equipment.sub.delay
				Weapon_Delay.sub = true
			end	
		end
	end
	for k,v in pairs(player.equipment.range) do
		if k == 'damage' and v > 0 then
			Weapon_Delay.ranged_delay = Weapon_Delay.ranged_delay + player.equipment.range.delay
			Weapon_Delay.range = true
		end		
	end
	for k,v in pairs(player.equipment.ammo) do
		if k == 'damage' and v > 0 then
			Weapon_Delay.ranged_delay = Weapon_Delay.ranged_delay + player.equipment.ammo.delay
			Weapon_Delay.ammo = true
		end		
	end
	--table.vprint(player.equipment.range)
	return Weapon_Delay
end

function determine_DW()

	local sub_job_dw = 0
	local main_job_dw = 0
	local player_has_sj = false
	for k,v in pairs(player) do
		if v == 'sub_job' then
			player_has_sj = true
		end
	end
	if player_has_sj == true then
		if player.sub_job:upper() == 'DNC' then sub_job_dw = 15
		elseif player.sub_job:upper() == 'NIN' then sub_job_dw = 25
		end
	end
	
	if player.main_job:upper() == 'BLU' then
		-- here we look up job points spent on blue for the DW bonus
		local jp_boost = 0
		local jp = player.job_points['blu']['jp_spent']
		if jp < 100 then
			jp_boost = 0
		elseif jp >= 100 and jp < 1200 then
			jp_boost = 1
		elseif jp >= 1200 then
			jp_boost = 2
		end
		
		--here we look up spells currently equipped to check for DW trait
		local DW_Spells_Equipped_Level = 0
		local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return blu_spells[id].english end)
		--table.vprint(spells_set)
		local spell_value = 0
		-- here we give each spell a value of 4 or 8 and add the values together
		for index, spell in pairs(spells_set) do
		--for spell in spells_set:it() do
			if spell == "Animating Wail" or spell == "Blazing Bound" or spell == "Quad. Continuum" or spell == "Delta Thrust" or spell == "Mortal Ray" or spell == "Barbed Crescent" then
			   spell_value = spell_value + 4
			elseif spell == "Molting Plumage" then 
				spell_value = spell_value + 8
			end
			--add_to_chat(122, '[Spell: '.. spell .. '] [Spell value: ' .. spell_value.. ']')
		end
		--add_to_chat(122, '[Spell value: ' .. spell_value.. ']')
		
		--here we determine the DW level equipped with job points
		if spell_value ~= 0 then
			DW_Spells_Equipped_Level = math.floor(spell_value / 8) + jp_boost
		else
			DW_Spells_Equipped_Level = 0
		end
		
		--the we determine the actuall % value of DW equipped via blu spells 
		if DW_Spells_Equipped_Level == 0 then main_job_dw = 0
		elseif DW_Spells_Equipped_Level == 1 then main_job_dw = 10
		elseif DW_Spells_Equipped_Level == 2 then main_job_dw = 15
		elseif DW_Spells_Equipped_Level == 3 then main_job_dw = 25
		elseif DW_Spells_Equipped_Level == 4 then main_job_dw = 30
		elseif DW_Spells_Equipped_Level == 5 then main_job_dw = 35
		elseif DW_Spells_Equipped_Level == 6 then main_job_dw = 40
		end
	elseif player.main_job:upper() == 'NIN' then
		
		if 	   player.main_job:upper() == 'NIN' and player.main_job_level < 10 and  player.main_job_level > 0 then main_job_dw = 0
		elseif player.main_job:upper() == 'NIN' and player.main_job_level < 25 and  player.main_job_level > 9 then main_job_dw = 10
		elseif player.main_job:upper() == 'NIN' and player.main_job_level < 45 and  player.main_job_level > 24 then main_job_dw = 15
		elseif player.main_job:upper() == 'NIN' and player.main_job_level < 65 and  player.main_job_level > 44 then main_job_dw = 25
		elseif player.main_job:upper() == 'NIN' and player.main_job_level < 85 and  player.main_job_level > 64 then main_job_dw = 30
		elseif player.main_job:upper() == 'NIN' and player.main_job_level < 100 and  player.main_job_level > 84 then main_job_dw = 35
		end
	elseif player.sub_job:upper() == 'NIN' then
		
		if 	   player.sub_job:upper() == 'NIN' and player.sub_job_level < 10 and  player.sub_job_level > 0 then sub_job_dw = 0
		elseif player.sub_job:upper() == 'NIN' and player.sub_job_level < 25 and  player.sub_job_level > 9 then sub_job_dw = 10
		elseif player.sub_job:upper() == 'NIN' and player.sub_job_level < 45 and  player.sub_job_level > 24 then sub_job_dw = 15
		elseif player.sub_job:upper() == 'NIN' and player.sub_job_level < 65 and  player.sub_job_level > 44 then sub_job_dw = 25
		elseif player.sub_job:upper() == 'NIN' and player.sub_job_level < 85 and  player.sub_job_level > 64 then sub_job_dw = 30
		elseif player.sub_job:upper() == 'NIN' and player.sub_job_level < 100 and  player.sub_job_level > 84 then sub_job_dw = 35
		end
	
	elseif player.main_job:upper() == 'DNC' then
	
		if 	   player.main_job:upper() == 'DNC' and player.main_job_level < 20 and  player.main_job_level > 0 then main_job_dw = 0
		elseif player.main_job:upper() == 'DNC' and player.main_job_level < 40 and  player.main_job_level > 19 then main_job_dw = 10
		elseif player.main_job:upper() == 'DNC' and player.main_job_level < 60 and  player.main_job_level > 39 then main_job_dw = 15
		elseif player.main_job:upper() == 'DNC' and player.main_job_level < 80 and  player.main_job_level > 59 then main_job_dw = 25
		elseif player.main_job:upper() == 'DNC' and player.main_job_level < 100 and  player.main_job_level > 79 then main_job_dw = 30
		end
		
		local jp = player.job_points['dnc']['jp_spent']
		local jp_dw_bonus = 0
		
		if jp > 549 then jp_dw_bonus = 5 end
		
		main_job_dw = main_job_dw + jp_dw_bonus
	
	elseif player.sub_job:upper() == 'DNC' then
	
		if 	   player.sub_job:upper() == 'DNC' and player.sub_job_level < 20 and  player.sub_job_level > 0 then sub_job_dw = 0
		elseif player.sub_job:upper() == 'DNC' and player.sub_job_level < 40 and  player.sub_job_level > 19 then sub_job_dw = 10
		elseif player.sub_job:upper() == 'DNC' and player.sub_job_level < 60 and  player.sub_job_level > 39 then sub_job_dw = 15
		elseif player.sub_job:upper() == 'DNC' and player.sub_job_level < 80 and  player.sub_job_level > 59 then sub_job_dw = 25
		elseif player.sub_job:upper() == 'DNC' and player.sub_job_level < 100 and  player.sub_job_level > 79 then sub_job_dw = 30
		end
		
	elseif player.main_job:upper() == 'THF' then
	
		if 	   player.main_job:upper() == 'THF' and player.main_job_level < 83 and  player.main_job_level > 0 then main_job_dw = 0
		elseif player.main_job:upper() == 'THF' and player.main_job_level < 90 and  player.main_job_level > 82 then main_job_dw = 10
		elseif player.main_job:upper() == 'THF' and player.main_job_level < 98 and  player.main_job_level > 89 then main_job_dw = 15
		elseif player.main_job:upper() == 'THF' and player.main_job_level < 100 and  player.main_job_level > 97 then main_job_dw = 25
		end
		
		local jp = player.job_points['thf']['jp_spent']
		local jp_dw_bonus = 0
		
		if jp > 549 then jp_dw_bonus = 5 end
		
		main_job_dw = main_job_dw + jp_dw_bonus
	end
	--add_to_chat(122, '[Sub dw: ' .. sub_job_dw .. '] [Main dw: ' .. main_job_dw .. ']')
	
	-- if the sub job DW is higher return that instead of blue mage spell DW
	if sub_job_dw > main_job_dw then
		return sub_job_dw
	else
		return main_job_dw
	end
end

function get_total_haste()
	local gear_haste = 0
	local magic_haste = 0
	local ja_haste = 0
	local total = 0
	
	if (Gear_info.haste + manual_ghaste) > 256 then
		gear_haste = 256
	else
		gear_haste = Gear_info.haste + manual_ghaste
	end
	if (Buffs_inform.magic_haste + manual_mhaste) > 448 then
		magic_haste = 448
	else
		magic_haste = Buffs_inform.magic_haste + manual_mhaste
	end
	if (Buffs_inform.ja_haste + manual_jahaste)> 256 then
		ja_haste = 256
	else
		ja_haste = Buffs_inform.ja_haste + manual_jahaste
	end
	total = gear_haste + magic_haste + ja_haste
	return total
end

function dual_wield_needed()
	local DW_needed = 0
	local Weapon_Delay = determine_Weapon_Delay()
	local total_delay = Weapon_Delay.melee_delay
		
	if player.equipment.main.delay > 0 and Weapon_Delay.sub then	
		DW_needed = math.floor((((total_delay * 0.2) / total_delay / ((1024 - (get_total_haste())) / 1024 ) -1) * -1 * 100) - determine_DW())
	end
	
	return DW_needed
end

