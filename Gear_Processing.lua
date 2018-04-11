
function find_all_values(item)
	-- notice(item.id)
	local temp = check_for_augments(item)
	local augs = Extdata.decode(item).augments
	
	local item = res.items:with('id', item.id)
	
	if item.flags:contains('Equippable') then
	
		if res.item_descriptions[item.id] then
			item.discription = string.gsub(res.item_descriptions:with('id', item.id ).en, '\n', ' ') 
		else
			item.discription = 'none'
		end
		
		descript_table = T{}
		descript_table = desypher_description(item.discription, item)
		
		item.defined_job = T{}
		
		for k, v in pairs(item.jobs) do
			item.defined_job[k] = res.jobs:with('id', k ).ens	
		end
		
		item.defined_slots = T{}
		for k, v in pairs(item.slots) do
			item.defined_slots[k] = res.slots:with('id', k ).en	
		end
	
		local edited_item = T{en=item.en, id=item.id, category=item.category , discription = item.discription, jobs = item.defined_job, slots = item.defined_slots}
		
			--item_level
		if item.item_level then
			edited_item.item_level = item.item_level
		end
		
		if augs then edited_item.augments = augs end
		
		for k, v in pairs(descript_table) do
			edited_item[k] = v
		end
		
		-- Check "Enhances \"Dual Wield\" effect" Gear for value
		for k, v in pairs(DW_Gear) do
			if item.id == k then
				if  edited_item['Dual Wield'] then
					edited_item['Dual Wield'] = edited_item['Dual Wield'] + v["Dual Wield"]
				else
					edited_item['Dual Wield'] = v["Dual Wield"]
				end
			end
		end
		
		-- Check Unity gear for stat and value.
		for k, v in pairs(Unity_rank) do
			if item.id == k then
				value = math.floor(((v['rank']['max'] - v['rank']['min'])/ 11) * (11 - (settings.player.rank -1))) + v['rank']['min']
				if edited_item[v['Unity Ranking']] then
					-- edited_item[v['Unity Ranking']] = edited_item[v['Unity Ranking']] + v.rank[settings.rank]
					edited_item[v['Unity Ranking']] = edited_item[v['Unity Ranking']] + value
					edited_item['Unity Ranking Bonus Applied'] = v['Unity Ranking'] .. ' + ' ..tostring(value)
				else
					-- edited_item[v['Unity Ranking']] = v['rank'][settings.rank]
					edited_item[v['Unity Ranking']] = value
					edited_item['Unity Ranking Bonus Applied'] = v['Unity Ranking'] .. ' + ' ..tostring(value)
				end 
			end
		end
		
		for k, v in pairs(Set_bonus_by_item_id) do
			if item.id == k then
				edited_item['Set Bonus'] = {["set id"] = v["set id"], ["bonus"] = v["bonus"] }
			end		
		end
		
		if item.category == 'Weapon' then
			for k,v in pairs(item) do
				-- if k == 'delay' then	
					-- edited_item[k] = tonumber(v)
				-- end
				if k == 'skill' then
					local skill = res.skills:with('id', v ).en
					edited_item[k] = skill
				end
			end
		end
		
		if temp then
			local temp_augments = T{}
			for k, v in pairs(temp) do
				temp_augments[k] = v
			end
			
			for k, v in pairs(temp_augments) do
				if edited_item[k] then
					edited_item[k] = edited_item[k] + v
				else
					edited_item[k] = v
				end
			end
		end

		return edited_item
	end
		
end

function check_for_augments(item)
	
	local augs = Extdata.decode(item).augments
	local item_t = res.items:with('id', item.id)
	local temp = T{}
	if augs then
		for k,v in pairs(augs) do
			
			if v:contains('Pet:') or v:contains('Wyvern:') or v:contains('Avatar:') then
			
			else
				for i, j in pairs(desypher_description(v, item_t)) do
					if temp[i] then
						temp[i] = temp[i] + j
					else
						temp[i] = j
					end
				end
			end
		end
		return temp
	else
		return nil
	end
	
end

function desypher_description(discription_string, item_t)
	
	-- string that need modifying to stop clashing
	discription_string = string.gsub(discription_string, 'Ranged Accuracy%s?', 'Ranged_accuracy') 
	discription_string = string.gsub(discription_string, 'Rng.%s?Acc.%s?', 'Ranged_accuracy')  
	discription_string = string.gsub(discription_string, 'Ranged Attack%s?', 'Ranged_attack') 
	discription_string = string.gsub(discription_string, 'Rng.%s?Atk.%s?', 'Ranged_attack') 
	
	discription_string = string.gsub(discription_string, 'Magic Accuracy%s?', 'Magic_accuracy')
	discription_string = string.gsub(discription_string, 'Mag.%s?Acc.%s?', 'Magic_accuracy') 	
	discription_string = string.gsub(discription_string, 'Magic Acc.%s?', 'Magic_accuracy') 
	
	discription_string = string.gsub(discription_string, '\"Magic Atk. Bonus\"', 'Magic Atk. Bonus' )
	discription_string = string.gsub(discription_string, '\"Mag.%s?Atk.%s?Bns.\"', 'Magic Atk. Bonus' ) 
	
	discription_string = string.gsub(discription_string, 'Magic Evasion', 'Magic_evasion' )
	
	discription_string = string.gsub(discription_string, 'Physical damage taken II', 'PDT_2' )
	discription_string = string.gsub(discription_string, 'Physical damage taken', 'PDT' )
	discription_string = string.gsub(discription_string, 'Breath damage taken', 'BDT' )
	discription_string = string.gsub(discription_string, 'Breath dmg. taken', 'BDT' )
	discription_string = string.gsub(discription_string, 'Magic damage taken II', 'MDT_2' )
	discription_string = string.gsub(discription_string, 'Magic damage taken', 'MDT' )
	discription_string = string.gsub(discription_string, 'Phys. dmg. taken', 'PDT' )
	discription_string = string.gsub(discription_string, 'Magic dmg. taken', 'MDT' )
	discription_string = string.gsub(discription_string, 'Damage taken', 'D_T' )
	
	discription_string = string.gsub(discription_string,  "Great Axe skill",  "Great axe skill")
	discription_string = string.gsub(discription_string,  "Great Katana skill",  "Great katana skill")
	discription_string = string.gsub(discription_string,  "Great Sword skill",  "Great sword skill")
	
	local str_table = ''
	
	if discription_string:contains('Pet:') then
		str_table = discription_string:psplit("Pet:")
		discription_string = str_table[1]
	elseif discription_string:contains('Wyvern:') then
		str_table = discription_string:psplit("Wyvern:")
		discription_string = str_table[1]
	elseif discription_string:contains('Avatar:') then
		str_table = discription_string:psplit("Avatar:")
		discription_string = str_table[1]
	elseif discription_string:contains('Latent effect:') then
		str_table = discription_string:psplit("Latent effect:")
		discription_string = str_table[1]
	elseif discription_string:contains('Unity Ranking:') then
		str_table = discription_string:psplit("Unity Ranking:")
		discription_string = str_table[1]
	end

	local valid_strings = L{'Delay','DEF','HP','MP','STR','DEX','VIT','AGI','INT','MND','CHR',
								'Accuracy','Acc.','Attack','Atk.',
								'Ranged_accuracy', 'Ranged_attack',
								'Magic_accuracy', 'Magic Atk. Bonus',
								'Haste','\"Slow\"','\"Store TP\"','\"Dual Wield\"','\"Fast Cast\"','\"Martial Arts\"',
								'DMG','PDT','MDT','BDT','D_T','MDT_2','PDT_2',
								"Hand%-to%-Hand skill", "Dagger skill", "Sword skill", "Great sword skill", "Axe skill", "Great axe skill",  "Scythe skill", "Polearm skill", 
								"Katana skill", "Great katana skill", "Club skill",  "Staff skill", "Archery skill", "Marksmanship skill" , "Throwing skill","Guarding skill","Evasion skill","Shield skill","Parrying skill",
								"Divine Magic skill","Healing Magic skill","Enhancing Magic skill","Enfeebling Magic skill","Elemental Magic skill","Dark Magic skill","Summoning Magic skill","Ninjutsu skill","Singing skill",
								"Stringed Instrument skill","Wind Instrument skill","Blue Magic skill","Geomancy skill","Handbell skill",
								"Phalanx",'All magic skills','All skills','Combat skills','Magic skills',
								}
	
	local temp_table = T{}
	local temp_key = { 
		['Delay'] = 'delay',
		["Acc."] = "Accuracy",
		["Atk."] = 'Attack',
		['\"Slow\"'] = 'Slow',
		['\"Store TP\"'] = 'Store TP', 
		['\"Dual Wield\"'] = 'Dual Wield' ,
		['\"Fast Cast\"'] = 'Fast Cast' ,
		['Magic_accuracy'] = 'Magic Accuracy' , 
		['Ranged_accuracy'] =  'Ranged Accuracy' ,
		['Ranged_attack'] =  'Ranged Attack' ,
		['Magic_evasion'] = 'Magic Evasion',
		["Great axe skill"] = "Great Axe skill" ,
		["Great katana skill"] = "Great Katana skill",
		["Great sword skill"] = "Great Sword skill",
		['DMG'] = 'damage',
		['D_T'] = 'DT',
		['MDT_2'] = 'MDT2',
		['PDT_2'] = 'PDT2',
		['\"Martial Arts\"'] = 'Martial Arts',
	}
	
	for k, v in pairs(valid_strings) do
		-- v = DEF etc
		pattern = "("..v.."):?%s?([+-]?%d+)"
		for key , val in discription_string:gmatch(pattern) do
			
			if temp_key[key] then
				temp_table[temp_key[key]] = tonumber(val)
			else
				temp_table[key] = tonumber(val)	
			end
			-- if item_t then
				-- if item_t.id == 20540 then
					-- notice('('..discription_string .. ') '..key .. ' ' ..val)
				-- end
			-- end
		end
	end
	return temp_table
end

function get_equip_stats(equipment_table)

	local stat_table = { ['Haste'] = 0, ['Slow'] = 0, ['Dual Wield'] = 0, ['Store TP'] = 0, ['Accuracy'] = 0, ['Ranged Accuracy'] = 0,

									['DT'] = 0, ['PDT'] = 0, ['PDT2'] = 0, ['MDT'] = 0, ['MDT2'] = 0, ['BDT'] = 0,
							 
									["MND"]=0, ["AGI"]=0, ["DEX"]=0, ["VIT"]=0, ["STR"]=0, ["INT"]=0,  ["CHR"]=0, 
							 
									["Hand-to-Hand skill"]=0, ["Dagger skill"]=0, ["Sword skill"]=0, ["Great sword skill"]=0, ["Axe skill"]=0, ["Great axe skill"]=0, ["Scythe skill"]=0, ["Polearm skill"]=0, 
									["Katana skill"]=0, ["Great katana skill"]=0,["Club skill"]=0,["Staff skill"]=0,["Archery skill"]=0,["Marksmanship skill"]=0,["Throwing skill"]=0,['Combat skills']=0,
									
									['main'] = {['skill'] = '', value = 0}, ['sub'] = {['skill'] = '', value = 0}, ['range'] = {['skill'] = '', value = 0}, ['ammo'] = {['skill'] = '', value = 0},
								}
								
	local melee_skills = L{"Hand-to-Hand skill", "Dagger skill", "Sword skill", "Great Sword skill", "Axe skill", "Great Axe skill", "Scythe skill", "Polearm skill", "Katana skill", "Great Katana skill", "Club skill", "Staff skill"}
	local ranged_skills = L{"Archery skill", "Marksmanship skill", "Throwing skill"}
							
	local set_bonus = {}
	
	if type(equipment_table) ~= 'table' or equipment_table == nil then
		error('get_equip_stats() function went wrong')
		return stat_table
	else	
		for equip_slot, equipped_item in pairs(equipment_table) do
			for key, value in pairs(equipped_item) do
				if stat_table[key] then
					if equipped_item["category"]=="Weapon" then
						if equipped_item['skill'] then
							stat_table[equip_slot]['skill'] =  equipped_item['skill']
							if 	equipped_item[equipped_item['skill'] ..' skill'] then
								stat_table[equip_slot].value =  equipped_item[equipped_item['skill'] ..' skill']
							end
						end
						if not melee_skills:contains(key) and not ranged_skills:contains(key) then
							if key == 'Haste' then
								stat_table['Haste'] = stat_table['Haste'] + math.floor(value / 100 * 1024)
							elseif key == 'Slow' then
								stat_table['Haste'] = stat_table['Haste'] - math.floor(value / 100 * 1024)
							elseif key == 'Combat skills' then
								stat_table['main'].value = stat_table['main'].value + value
								stat_table['sub'].value = stat_table['sub'].value + value
								stat_table['range'].value = stat_table['range'].value + value
								stat_table['ammo'].value = stat_table['ammo'].value + value
							else
								stat_table[key] = stat_table[key] + value
							end
						end
					else
						if key == 'Haste' then
							stat_table['Haste'] = stat_table['Haste'] + math.floor(value / 100 * 1024)
						elseif key == 'Slow' then
							stat_table['Haste'] = stat_table['Haste'] - math.floor(value / 100 * 1024)
						elseif key == 'Combat skills' then
							stat_table['main'].value = stat_table['main'].value + value
							stat_table['sub'].value = stat_table['sub'].value + value
							stat_table['range'].value = stat_table['range'].value + value
							stat_table['ammo'].value = stat_table['ammo'].value + value
						else
							stat_table[key] = stat_table[key] + value
						end
					end
				elseif equip_slot == 'main' and equipped_item.en == '' then
					stat_table['main']['skill'] = 'Hand-to-Hand'
				end
				if key == "Set Bonus" then
					if  set_bonus[value["set id"]]  then
						set_bonus[value["set id"]] = set_bonus[value["set id"]] + 1
					else
						set_bonus[value["set id"]]  = 1
					end
				end
			end
		end

		for k, v in pairs(set_bonus) do
			if v > 1 then
				if v >= Set_bonus_by_Set_ID[k]["minimum peices"] then
					if Set_bonus_by_Set_ID[k]["bonus"][v] then
						for key, value in pairs(Set_bonus_by_Set_ID[k]["bonus"][v]) do
							if stat_table[key] then
								stat_table[key] = stat_table[key] + value
							end
						end
					end
				end
			end
		end
	end
	-- table.vprint(stat_table['main'])
	stat_table['Haste'] = stat_table['Haste'] + manual_ghaste
	stat_table['Dual Wield'] = stat_table['Dual Wield'] + manual_dw
	stat_table['Store TP'] = stat_table['Store TP'] + manual_stp
	
	return stat_table
	
end

function get_player_acc(stat_table)
	
	local stat_table = stat_table
	
	for skill_name, value in pairs(player_base_skills) do
		--notice(main_hand.skill)
		--log(skill_name  .. ' | ' .. string.gsub(stat_table['main'].skill:lower(), ' ', '_'))
		if skill_name == string.gsub(stat_table['main'].skill:lower(), ' ', '_') then
			--log(stat_table['main'].value..'  ' ..value.. '  '..stat_table[stat_table['main'].skill .. ' skill'])
			
			stat_table['main'].value = stat_table['main'].value + value + stat_table[stat_table['main'].skill .. ' skill']
		end
		if skill_name == string.gsub(stat_table['sub'].skill:lower(), ' ', '_') then
			stat_table['sub'].value = stat_table['sub'].value + value + stat_table[stat_table['sub'].skill .. ' skill']
		end
		if skill_name == string.gsub(stat_table['range'].skill:lower(), ' ', '_') then
			stat_table['range'].value = stat_table['range'].value + value + stat_table[stat_table['range'].skill .. ' skill']
		end
		if skill_name == string.gsub(stat_table['ammo'].skill:lower(), ' ', '_') then
			stat_table['ammo'].value = stat_table['ammo'].value + value + stat_table[stat_table['ammo'].skill .. ' skill']
		end
	end

	for stat, value in pairs(player.stats) do
		if stat_table[stat] then 
			stat_table[stat] = stat_table[stat] + value 
		end	
	end	

	
	stat_table = get_blue_mage_stats_from_equipped_spells(stat_table)
	
	local Total_acc = {main = 0, sub = 0, range = 0, ammo = 0, dex = 0, agi = 0}
	local main_acc_skill = acc_from_skill(stat_table['main'].value)
	local sub_acc_skill = acc_from_skill(stat_table['sub'].value )
	local ranged_acc_skill = racc_from_skill(stat_table['range'].value )
	local ammo_acc_skill = racc_from_skill(stat_table['ammo'].value )
	Total_acc.dex = math.floor(stat_table['DEX'] * 0.75)
	Total_acc.agi = math.floor(stat_table['AGI'] * 0.75)
	
	Total_acc.main = main_acc_skill + (math.floor(stat_table['DEX'] * 0.75)) + stat_table['Accuracy'] + get_player_acc_from_job()

	if player.equipment.sub.id ~= 0 and player.equipment.sub.category == 'Weapon' and player.equipment.sub.damage then
		Total_acc.sub = sub_acc_skill + (math.floor(stat_table['DEX'] * 0.75)) + stat_table['Accuracy'] + get_player_acc_from_job()
	else
		Total_acc.sub = 0
	end
	if player.equipment.range.id ~= 0 and player.equipment.range.category == 'Weapon' then
		Total_acc.range = ranged_acc_skill + math.floor(stat_table['AGI'] * 0.75) + stat_table['Ranged Accuracy'] + get_player_acc_from_job()
	else
		Total_acc.range = 0
	end
	if player.equipment.ammo.id ~= 0 and player.equipment.ammo.category == 'Weapon' and player.equipment.ammo.damage then
		Total_acc.ammo = ammo_acc_skill + math.floor(stat_table['AGI'] * 0.75) + stat_table['Ranged Accuracy'] + get_player_acc_from_job()
	else
		Total_acc.ammo = 0
	end
	
	--notice('Main Acc = '.. Total_acc.main .. ' | Off hand Acc = '.. Total_acc.sub .. ' | Ranged Acc = '.. Total_acc.range .. ' | ammo Acc = '.. Total_acc.ammo)
	--log('Dex = '.. stat_table['DEX'] .. ' | Main skill  = '.. stat_table['main'].value .. ' | Sub skill = '.. stat_table['sub'].value .. ' | job acc = ' ..get_player_acc_from_job() .. ' | gear acc = ' .. stat_table['Accuracy'])
	--log('Agi = '.. stat_table['AGI'] .. ' | Range skill  = '.. stat_table['range'].value .. ' | Ammo skill = '.. stat_table['ammo'].value .. ' | job acc = ' ..get_player_acc_from_job().. ' | gear r.acc = ' .. stat_table['Ranged Accuracy'])
	
	--log(main_acc_skill.. ' ' .. item_acc .. ' ' .. get_player_acc_from_job() .. ' ' .. main_hand.value .. ' ' .. skill_from_gear_main .. ' ' ..item_dex .. ' ' .. player_dex )
	--log(ammo_acc_skill.. ' ' .. item_racc .. ' ' .. get_player_acc_from_job() .. ' ' .. ammo.value .. ' ' .. skill_from_gear_ammo .. ' ' ..item_agi .. ' ' .. player_agi )
	
	return Total_acc
	
	
end

function get_blue_mage_stats_from_equipped_spells(stat_table)

	local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return id end)
	
	for key, spell_id in pairs(spells_set) do
		for stat, value in pairs(Blu_spells[spell_id]) do
			if stat_table[stat] then 
				stat_table[stat] = stat_table[stat] + value 
			end
		end
	end

	return stat_table
end

function get_player_skill_in_gear(equip)
	
	player_base_skills = player.skills
	
	-- string.gsub(sub_hand.skill, ' ', '_')
	local combat_skills = L{"hand_to_hand", "dagger", "sword", "great_sword", "axe", "great_axe",  "scythe", "polearm", 
										"katana", "great_katana", "club",  "staff", "archery", "marksmanship" , "throwing","guard","evasion","shield","parrying",}
	local magic_skills = L{"divine_magic","healing_magic","enhancing_magic","enfeebling_magic","elemental_magic","dark_magic","summoning_magic",
									"ninjutsu","singing","stringed Instrument","wind Instrument","blue_magic","geomancy","handbell"}
	local skills = L{"Hand-to-Hand skill", "Dagger skill", "Sword skill", "Great sword skill", "Axe skill", "Great axe skill",  "Scythe skill", "Polearm skill", 
							"Katana skill", "Great katana skill", "Club skill",  "Staff skill", "Archery skill", "Marksmanship skill" , "Throwing skill","Guard skill","Evasion skill","Shield skill","Parrying skill",
							"Divine Magic skill","Healing Magic skill","Enhancing Magic skill","Enfeebling Magic skill","Elemental Magic skill","Dark Magic skill","Summoning Magic skill","Ninjutsu skill","Singing skill",
							"Stringed Instrument skill","Wind Instrument skill","Blue Magic skill","Geomancy skill","Handbell skill",'All magic skills','Combat skills','Magic skills',
							}
	
	if equip then
		for slot ,item in pairs(equip) do
			if slot == 'main' or slot == 'sub' or slot == 'range' or slot == 'ammo' then
				if item.category == 'Weapon' then
					if item.damage == nil then
						if item.item_level == nil then
							for stat_key, value in pairs(item) do
								if skills:contains(stat_key) then
									str = string.gsub(stat_key, ' skill', '')
									if player_base_skills[string.gsub(str, ' ', '_'):lower()] then
										player_base_skills[string.gsub(str, ' ', '_'):lower()] = player_base_skills[string.gsub(str, ' ', '_'):lower()] - value
										-- notice('value 1 = ' .. value)
										-- break
									elseif player_base_skills['hand_to_hand'] and stat_key == "Hand-to-Hand skill" then
										player_base_skills['hand_to_hand'] = player_base_skills['hand_to_hand'] - value
									elseif stat_key == "Combat skills" then
										for k, player_skill in pairs(player_base_skills) do
											if combat_skills:contains(player_skill) then
												player_base_skills.player_skill = player_base_skills.player_skill - value
											end
										end
									elseif stat_key == 'All magic skills' or stat_key == 'Magic skills' then
										for k, player_skill in pairs(player_base_skills) do
											if magic_skills:contains(player_skill) then
												player_base_skills.player_skill = player_base_skills.player_skill - value
											end
										end
									end
								end
							end
						end
					end
				end
			else
				for stat_key, value in pairs(item) do
					if skills:contains(stat_key) then
						str = string.gsub(stat_key, ' skill', '')
						if player_base_skills[string.gsub(str, ' ', '_'):lower()] then
							player_base_skills[string.gsub(str, ' ', '_'):lower()] = player_base_skills[string.gsub(str, ' ', '_'):lower()] - value
							-- notice('value 2 = ' .. value .. ' for item: ' .. item.en)
							-- break
						elseif player_base_skills['hand_to_hand'] and stat_key == "Hand-to-Hand skill" then
							player_base_skills['hand_to_hand'] = player_base_skills['hand_to_hand'] - value
						elseif stat_key == "Combat skills" then
							for k, player_skill in pairs(player_base_skills) do
								if combat_skills:contains(player_skill) then
									player_base_skills.player_skill = player_base_skills.player_skill - value
								end
							end
						elseif stat_key == 'All magic skills' or stat_key == 'Magic skills' then
							for k, player_skill in pairs(player_base_skills) do
								if magic_skills:contains(player_skill) then
									player_base_skills.player_skill = player_base_skills.player_skill - value
								end
							end
						end
					end
				end
			end
		end
	end
	-- notice(player_base_skills.sword)
end
	
function acc_from_skill(skill)
	
	if skill < 200 then return skill end
	if skill < 400 and skill > 199 then return (math.floor((skill -200) * 0.9) + 200) end
	if skill < 600 and skill > 399 then return (math.floor((skill -400) * 0.8) + 380) end
	if skill > 599 then return (math.floor((skill -600) * 0.9) + 540) end

end

function racc_from_skill(skill)
	
	if skill < 200 then return skill end
	if skill < 400 and skill > 199 then return (math.floor((skill -200) * 0.9) + 200) end
	if skill < 600 and skill > 399 then return (math.floor((skill -400) * 0.8) + 380) end
	if skill > 599 then return (math.floor((skill -600) * 0.9) + 540) end

end

function get_player_acc_from_job()
	
	local sub_job_acc = 0
	local main_job_acc = 0
	local player_has_sj = false
	for k,v in pairs(player) do
		if v == 'sub_job' then
			player_has_sj = true
		end
	end
	
	if player_has_sj == true then
		if player.sub_job:upper() == 'RNG' then
			if player.sub_job_level < 10  then sub_job_acc = 0
			elseif player.sub_job_level < 30 and  player.sub_job_level > 9 then sub_job_acc = 10
			elseif player.sub_job_level > 29 then sub_job_acc = 22
			end
		elseif player.sub_job:upper() == 'DRG' then
			if player.sub_job_level < 30  then sub_job_acc = 0
			elseif player.sub_job_level > 29 then sub_job_acc = 10
			end
		elseif player.sub_job:upper() == 'DNC' then
			if player.sub_job_level < 30  then sub_job_acc = 0
			elseif player.sub_job_level > 29 then sub_job_acc = 10
			end
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
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 36
		elseif jp > 779 and jp < 1530 then jp_acc = 23
		elseif jp > 279 and jp < 780 then jp_acc = 13
		elseif jp > 29 and jp < 280 then jp_acc = 5
		end
		
		--here we look up spells currently equipped to check for DW trait
		local ACC_Spells_Equipped_Level = 0
		local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return blu_spells[id].english end)
		--table.vprint(spells_set)
		local spell_value = 0
		-- here we give each spell a value of 4 or 8 and add the values together
		for index, spell in pairs(spells_set) do
		--for spell in spells_set:it() do
			if spell == "Dimensional Death" or spell == "Frenetic Rip" or spell == "Disseverment" or spell == "Vanity Dive" then
			   spell_value = spell_value + 4
			elseif spell == "Nat. Meditation" or spell == "Anvil Lightning" then 
				spell_value = spell_value + 8
			end
		end
		
		--here we determine the DW level equipped with job points
		if spell_value ~= 0 then
			ACC_Spells_Equipped_Level = math.floor(spell_value / 8) + jp_boost
		else
			ACC_Spells_Equipped_Level = 0
		end
		--the we determine the actuall % value of DW equipped via blu spells 
		if ACC_Spells_Equipped_Level == 0 then main_job_acc = 0
		elseif ACC_Spells_Equipped_Level == 1 then main_job_acc = 10
		elseif ACC_Spells_Equipped_Level == 2 then main_job_acc = 22
		elseif ACC_Spells_Equipped_Level == 3 then main_job_acc = 35
		elseif ACC_Spells_Equipped_Level == 4 then main_job_acc = 48
		elseif ACC_Spells_Equipped_Level == 5 then main_job_acc = 60
		elseif ACC_Spells_Equipped_Level == 5 then main_job_acc = 73
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'WAR' then
	
		local jp = player.job_points['war']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 36
		elseif jp > 779 and jp < 1530 then jp_acc = 23
		elseif jp > 279 and jp < 780 then jp_acc = 13
		elseif jp > 29 and jp < 280 then jp_acc = 5
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'MNK' then
	
		local jp = player.job_points['mnk']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 41
		elseif jp > 779 and jp < 1530 then jp_acc = 26
		elseif jp > 279 and jp < 780 then jp_acc = 15
		elseif jp > 29 and jp < 280 then jp_acc = 6
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'WHM' then
	
		local jp = player.job_points['whm']['jp_spent']
		
		local jp_acc = 0
		if jp > 1619 and jp < 2101 then jp_acc = 14
		elseif jp > 844 and jp < 1620 then jp_acc = 9
		elseif jp > 319 and jp < 845 then jp_acc = 5
		elseif jp > 44 and jp < 320 then jp_acc = 2
		end
		
		main_job_acc = main_job_acc + jp_acc
	
	elseif player.main_job:upper() == 'RDM' then
	
		local jp = player.job_points['rdm']['jp_spent']
		
		local jp_acc = 0
		if jp > 1619 and jp < 2101 then jp_acc = 22
		elseif jp > 844 and jp < 1620 then jp_acc = 14
		elseif jp > 319 and jp < 845 then jp_acc = 8
		elseif jp > 44 and jp < 320 then jp_acc = 3
		end
		
		main_job_acc = main_job_acc + jp_acc
	
	elseif player.main_job:upper() == 'THF' then
	
		local jp = player.job_points['thf']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 36
		elseif jp > 779 and jp < 1530 then jp_acc = 23
		elseif jp > 279 and jp < 780 then jp_acc = 13
		elseif jp > 29 and jp < 280 then jp_acc = 5
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'PLD' then
	
		local jp = player.job_points['pld']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 28
		elseif jp > 779 and jp < 1530 then jp_acc = 18
		elseif jp > 279 and jp < 780 then jp_acc = 10
		elseif jp > 29 and jp < 280 then jp_acc = 4
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'DRK' then
	
		local jp = player.job_points['drk']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 22
		elseif jp > 779 and jp < 1530 then jp_acc = 14
		elseif jp > 279 and jp < 780 then jp_acc = 8
		elseif jp > 29 and jp < 280 then jp_acc = 3
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'BST' then
	
		local jp = player.job_points['bst']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 36
		elseif jp > 779 and jp < 1530 then jp_acc = 23
		elseif jp > 279 and jp < 780 then jp_acc = 13
		elseif jp > 29 and jp < 280 then jp_acc = 5
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'BRD' then
	
		local jp = player.job_points['brd']['jp_spent']
		
		local jp_acc = 0
		if jp > 1444 and jp < 2101 then jp_acc = 21
		elseif jp > 719 and jp < 1445 then jp_acc = 13
		elseif jp > 244 and jp < 720 then jp_acc = 7
		elseif jp > 19 and jp < 245 then jp_acc = 2
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'RNG' then
		if player.main_job_level < 10  then main_job_acc = 0
		elseif player.main_job_level < 30 and  player.main_job_level > 9 then main_job_acc = 10
		elseif player.main_job_level < 50 and  player.main_job_level > 29 then main_job_acc = 22
		elseif player.main_job_level < 70 and  player.main_job_level > 49 then main_job_acc = 35
		elseif player.main_job_level < 86 and  player.main_job_level > 69 then main_job_acc = 48
		elseif player.main_job_level < 96 and  player.main_job_level > 85 then main_job_acc = 60
		elseif player.main_job_level < 100 and  player.main_job_level > 95 then main_job_acc = 73
		end
		
		local jp = player.job_points['rng']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 70
		elseif jp > 779 and jp < 1530 then jp_acc = 45
		elseif jp > 279 and jp < 780 then jp_acc = 25
		elseif jp > 29 and jp < 280 then jp_acc = 10
		end
		
		main_job_acc = main_job_acc + jp_acc
	
	elseif player.main_job:upper() == 'SAM' then
	
		local jp = player.job_points['sam']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 36
		elseif jp > 779 and jp < 1530 then jp_acc = 23
		elseif jp > 279 and jp < 780 then jp_acc = 13
		elseif jp > 29 and jp < 280 then jp_acc = 5
		end
		
		main_job_acc = main_job_acc + jp_acc
	
	elseif player.main_job:upper() == 'NIN' then
	
		local jp = player.job_points['nin']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 56
		elseif jp > 779 and jp < 1530 then jp_acc = 36
		elseif jp > 279 and jp < 780 then jp_acc = 20
		elseif jp > 29 and jp < 280 then jp_acc = 8
		end
		
		main_job_acc = main_job_acc + jp_acc
	
	elseif player.main_job:upper() == 'DRG' then
		if player.main_job_level < 30  then main_job_acc = 0
		elseif player.main_job_level > 29 and player.main_job_level < 60 then main_job_acc = 10
		elseif player.main_job_level > 59 and player.main_job_level < 76 then main_job_acc = 22
		elseif player.main_job_level > 75  then main_job_acc = 35
		end
		
		local jp = player.job_points['drg']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 64
		elseif jp > 779 and jp < 1530 then jp_acc = 41
		elseif jp > 279 and jp < 780 then jp_acc = 23
		elseif jp > 29 and jp < 280 then jp_acc = 9
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'COR' then
	
		local jp = player.job_points['cor']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 36
		elseif jp > 779 and jp < 1530 then jp_acc = 23
		elseif jp > 279 and jp < 780 then jp_acc = 13
		elseif jp > 29 and jp < 280 then jp_acc = 5
		end
		
		main_job_acc = main_job_acc + jp_acc
	
	elseif player.main_job:upper() == 'PUP' then
	
		local jp = player.job_points['pup']['jp_spent']
		
		local jp_acc = 0
		if jp > 1444 and jp < 2101 then jp_acc = 50
		elseif jp > 719 and jp < 1445 then jp_acc = 32
		elseif jp > 244 and jp < 720 then jp_acc = 18
		elseif jp > 19 and jp < 245 then jp_acc = 7
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'DNC' then
	
		if player.main_job_level < 30  then main_job_acc = 0
		elseif player.main_job_level > 29 and player.main_job_level < 60 then main_job_acc = 10
		elseif player.main_job_level > 59 and player.main_job_level < 76 then main_job_acc = 22
		elseif player.main_job_level > 75  then main_job_acc = 35
		end
		
		local jp = player.job_points['dnc']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 64
		elseif jp > 779 and jp < 1530 then jp_acc = 41
		elseif jp > 279 and jp < 780 then jp_acc = 23
		elseif jp > 29 and jp < 280 then jp_acc = 9
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	elseif player.main_job:upper() == 'RUN' then
		if player.main_job_level < 50  then main_job_acc = 0
		elseif player.main_job_level > 49 and player.main_job_level < 70 then main_job_acc = 10
		elseif player.main_job_level > 69 and player.main_job_level < 90 then main_job_acc = 22
		elseif player.main_job_level > 89  then main_job_acc = 35
		end
		
		local jp = player.job_points['run']['jp_spent']
		
		local jp_acc = 0
		if jp > 1529 and jp < 2101 then jp_acc = 56
		elseif jp > 779 and jp < 1530 then jp_acc = 36
		elseif jp > 279 and jp < 780 then jp_acc = 20
		elseif jp > 29 and jp < 280 then jp_acc = 8
		end
		
		main_job_acc = main_job_acc + jp_acc
		
	end

	if sub_job_acc > main_job_acc then
		return sub_job_acc
	else
		return main_job_acc
	end
end



	
			