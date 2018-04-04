
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
		descript_table = desypher_description(item.discription)
		
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
		
		if item.category == 'Weapon' then
			for k,v in pairs(item) do
				if k == 'delay' then	
					edited_item[k] = tonumber(v)
				end
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
				break
			end
			for i, j in pairs(desypher_description(v, item_t)) do
				if temp[i] then
					temp[i] = temp[i] + j
				else
					temp[i] = j
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
	elseif discription_string:contains('Unity Ranking:') then
		str_table = discription_string:psplit("Unity Ranking:")
		discription_string = str_table[1]
	end

	local valid_strings = L{'DEF','HP','MP','STR','DEX','VIT','AGI','INT','MND','CHR',
								'Accuracy','Acc.','Attack','Atk.',
								'Ranged_accuracy', 'Ranged_attack',
								'Magic_accuracy', 'Magic Atk. Bonus',
								'Haste','\"Slow\"','\"Store TP\"','\"Dual Wield\"','\"Fast Cast\"',
								'DMG','PDT','MDT','BDT','D_T','MDT_2','PDT_2',
								"Hand-to-Hand skill", "Dagger skill", "Sword skill", "Great sword skill", "Axe skill", "Great axe skill",  "Scythe skill", "Polearm skill", 
								"Katana skill", "Great katana skill", "Club skill",  "Staff skill", "Archery skill", "Marksmanship skill" , "Throwing skill","Guard skill","Evasion skill","Shield skill","Parrying skill",
								"Divine Magic skill","Healing Magic skill","Enhancing Magic skill","Enfeebling Magic skill","Elemental Magic skill","Dark Magic skill","Summoning Magic skill","Ninjutsu skill","Singing skill",
								"Stringed Instrument skill","Wind Instrument skill","Blue Magic skill","Geomancy skill","Handbell skill",
								}
	
	local temp_table = T{}
	local temp_key = { 
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
				-- if item_t.id == 25643 then
					-- notice('('..discription_string .. ') '..key .. ' ' ..val)
				-- end
			-- end
		end
	end
	return temp_table
end
		
function get_equip_stats(equipment_table)
	local item_haste = 0
	local item_dw = 0
	local item_stp = 0
	local haste_info_perc = 0
	local item_info = {haste = 0, dual_wield = 0, stp = 0, dt = 0, pdt = 0, mdt = 0, bdt = 0, mdtii = 0, pdtii = 0 }
	
	if type(equipment_table) ~= 'table' or equipment_table == nil then
		windower.add_to_chat(200,'get_equip_stats() function went wrong')
		return item_info
	else
		for k,v in pairs(equipment_table) do
			for i,j in pairs(v) do
				if i == 'Haste' then
					item_haste = item_haste + math.floor(j / 100 * 1024)
				elseif i == 'Slow' then
					item_haste = item_haste - math.floor(j / 100 * 1024)
				elseif i == 'Dual Wield' then 
					item_dw = item_dw + j
				elseif i == 'Store TP' then
					item_stp = item_stp + j
				elseif i == 'DT' then
					item_info.dt = item_info.dt + j
				elseif i == 'PDT' then
					item_info.pdt = item_info.pdt + j
				elseif i == 'PDT2' then
					item_info.pdtii = item_info.pdtii + j
				elseif i == 'MDT' then
					item_info.mdt = item_info.mdt + j
				elseif i == 'MDT2' then
					item_info.mdtii = item_info.mdtii + j
				elseif i == 'BDT' then
					item_info.bdt = item_info.bdt + j
				end
			end
		end
	end
	
	-- Set bonus declaration
	if (player.equipment.right_ear.en == 'Dudgeon Earring' and player.equipment.left_ear.en == 'Heartseeker Earring') or  (player.equipment.right_ear.en == 'Heartseeker Earring' and player.equipment.left_ear.en == 'Dudgeon Earring') then
		item_dw = item_dw + 7
	end
	
	-- haste_info_perc = math.floor(item_haste / 100 * 1024)
	
	--log(haste_info_perc)
	
	-- local temp_info = item_info
	item_info.haste = item_haste + manual_ghaste
	item_info.dual_wield = item_dw + manual_dw
	item_info.stp = item_stp + manual_stp
	--table.vprint(item_info)
	return item_info
	
end

function get_player_skill_in_gear(equip)
	
	-- string.gsub(sub_hand.skill, ' ', '_')
	local skills = L{"Hand-to-Hand skill", "Dagger skill", "Sword skill", "Great sword skill", "Axe skill", "Great axe skill",  "Scythe skill", "Polearm skill", 
							"Katana skill", "Great katana skill", "Club skill",  "Staff skill", "Archery skill", "Marksmanship skill" , "Throwing skill","Guard skill","Evasion skill","Shield skill","Parrying skill",
							"Divine Magic skill","Healing Magic skill","Enhancing Magic skill","Enfeebling Magic skill","Elemental Magic skill","Dark Magic skill","Summoning Magic skill","Ninjutsu skill","Singing skill",
							"Stringed Instrument skill","Wind Instrument skill","Blue Magic skill","Geomancy skill","Handbell skill",
							}
	
	if equip then
		for slot ,item in pairs(equip) do
			if slot == 'main' or slot == 'sub' or slot == 'ranged' or slot == 'ammo' then
				if item.category == 'Weapon' then
					if not item.damage then
						if not item.item_level then
							for stat_key, value in pairs(item) do
								if skills:contains(stat_key) then
									str = string.gsub(stat_key, ' skill', '')
									if player_base_skills[string.gsub(str, ' ', '_'):lower()] then
										player_base_skills[string.gsub(str, ' ', '_'):lower()] = player_base_skills[string.gsub(str, ' ', '_'):lower()] - value
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
						end
					end
				end
			end
		end
	end
	-- notice(player_base_skills.sword)
end

function get_player_acc(equip)
	--get_packet_data()
	--table.vprint(equip)
	
	local main_hand = {skill = 'hand_to_hand', value = 0}
	local sub_hand = {skill = '', value = 0}
	local ranged = {skill = '', value = 0}
	local ammo = {skill = '', value = 0}
	local item_dex = 0
	local item_agi = 0
	local item_acc = 0
	local item_racc = 0
	local player_dex = 0
	local player_agi = 0
	local skill_from_gear_main = 0
	local skill_from_gear_sub = 0
	local skill_from_gear_ranged = 0
	local skill_from_gear_ammo = 0
	
	local melee_skills = L{"Hand-to-Hand", "Dagger", "Sword", "Great Sword", "Axe", "Great Axe", "Scythe", "Polearm", "Katana", "Great Katana", "Club", "Staff"}
	local ranged_skills = L{"Archery", "Marksmanship", "Throwing"}
	
	if equip ~= nil then
		for k,v in pairs(equip) do
			--if v.id == 20677 then table.vprint(v) end
			if k == 'main' and v.id ~= 0 and v.category == 'Weapon' and melee_skills:contains(v.skill) then
				main_hand.skill = v.skill
				main_hand.value = v[main_hand.skill..' skill']
				--table.vprint(main_hand)
			elseif k == 'sub' and v.id ~= 0 and v.category == 'Weapon' and melee_skills:contains(v.skill) then
				if v.damage then
					sub_hand.skill = v.skill
					sub_hand.value = v[sub_hand.skill..' skill']
				end
			end
			if k == 'range' and v.id ~= 0 and v.category == 'Weapon' and ranged_skills:contains(v.skill) then
				ranged.skill = v.skill
				ranged.value = v[ranged.skill..' skill']
				--table.vprint(main_hand)
			elseif k == 'ammo' and v.id ~= 0 and v.category == 'Weapon' and ranged_skills:contains(v.skill) then
				--if v.en == 'Ochu' then table.vprint(v) end
				if v.damage then
					ammo.skill = v.skill
					ammo.value = v[ammo.skill..' skill']
				end
			end
		end
		for k,v in pairs(equip) do
			for i,j in pairs(v) do
				if i == 'DEX' then
					item_dex = item_dex + j
				elseif i == 'Accuracy' then 
					item_acc = item_acc + j
					--log(item_acc .. ' '..v.en)
				elseif i == 'AGI' then 
					item_agi = item_agi + j
				elseif i == 'Ranged Accuracy' then 
					item_racc = item_racc + j
				elseif v.category == "Armor" then
					--log(i .. ' ' .. string.gsub(main_hand.skill, ' ', '_')..'_skill')
					if i == main_hand.skill..' skill' then
						skill_from_gear_main = skill_from_gear_main + j
					end
					if i == sub_hand.skill..' skill' then 
						skill_from_gear_sub = skill_from_gear_sub + j
					end
					if i ==ranged.skill..' skill' then
						skill_from_gear_ranged = skill_from_gear_ranged + j
					end
					if i == ammo.skill..' skill' then
						skill_from_gear_ammo = skill_from_gear_ammo + j
					end
				end
			end
		end
	end
	--log(string.gsub(main_hand.skill, ' ', '_')..'_skill'..' '..skill_from_gear_main ..' '..string.gsub(sub_hand.skill, ' ', '_')..'_skill'..' '..skill_from_gear_sub)
	for k,v in pairs(player_base_skills) do
		if k == string.gsub(main_hand.skill:lower(), ' ', '_') then
			main_hand.value = main_hand.value + v
		end
		if k == string.gsub(sub_hand.skill:lower(), ' ', '_') then
			sub_hand.value = sub_hand.value + v
		end
		if k == string.gsub(ranged.skill:lower(), ' ', '_') then
			ranged.value = ranged.value + v
		end
		if k == string.gsub(ammo.skill:lower(), ' ', '_') then
			ammo.value = ammo.value + v
		end
	end
	
	for k,v in pairs(player) do
		if k == 'stats' then 
			for i,j in pairs(v) do
				if i == 'DEX' then 
					player_dex = j 
				elseif i == 'AGI' then 
					player_agi = j 
				end	
			end	
		end
	end	
	
	local Total_acc = {main = 0, sub = 0, range = 0, ammo = 0, dex = 0, agi = 0}
	local main_acc_skill = acc_from_skill(main_hand.value + skill_from_gear_main )
	local sub_acc_skill = acc_from_skill(sub_hand.value + skill_from_gear_sub )
	local ranged_acc_skill = racc_from_skill(ranged.value + skill_from_gear_ranged )
	local ammo_acc_skill = racc_from_skill(ammo.value + skill_from_gear_ammo )
	
	Total_acc.main = main_acc_skill + (math.floor((item_dex + player_dex + get_blu_spells_dex()) * 0.75)) + item_acc + get_player_acc_from_job()

	if player.equipment.sub.id ~= 0 and player.equipment.sub.category == 'Weapon' and player.equipment.sub.damage then
		Total_acc.sub = sub_acc_skill + math.floor((item_dex + player_dex + get_blu_spells_dex()) * 0.75) + item_acc + get_player_acc_from_job()
	else
		Total_acc.sub = 0
	end
	if player.equipment.range.id ~= 0 and player.equipment.range.category == 'Weapon' then
		Total_acc.range = ranged_acc_skill + math.floor((item_agi + player_agi) * 0.75) + item_racc + get_player_acc_from_job()
	else
		Total_acc.range = 0
	end
	if player.equipment.ammo.id ~= 0 and player.equipment.ammo.category == 'Weapon' and player.equipment.ammo.damage then
		Total_acc.ammo = ammo_acc_skill + math.floor((item_agi + player_agi) * 0.75) + item_racc + get_player_acc_from_job()
	else
		Total_acc.ammo = 0
	end
	--log(main_acc_skill.. ' ' .. item_acc .. ' ' .. get_player_acc_from_job() .. ' ' .. main_hand.value .. ' ' .. skill_from_gear_main .. ' ' ..item_dex .. ' ' .. player_dex )
	--log(ammo_acc_skill.. ' ' .. item_racc .. ' ' .. get_player_acc_from_job() .. ' ' .. ammo.value .. ' ' .. skill_from_gear_ammo .. ' ' ..item_agi .. ' ' .. player_agi )
	Total_acc.dex = item_dex + player_dex + get_blu_spells_dex()
	Total_acc.agi = item_agi + player_agi
	
	return Total_acc
end
	
function acc_from_skill(skill)
	
	if skill < 200 then return skill end
	if skill < 400 and skill > 199 then return (math.floor((skill -200) * 0.9) + 200) end
	if skill < 600 and skill > 399 then return (math.floor((skill -400) * 0.8) + 380) end
	if skill > 599 then return (math.floor((skill -600) * 0.9) + 540) end

end

function racc_from_skill(skill)
	
	if skill < 200 then return skill end
	if skill < 400 and skill > 199 then return (math.floor(skill * 0.9)) end
	if skill < 600 and skill > 399 then return (math.floor(skill * 0.9)) end
	if skill > 599 then return (math.floor(skill * 0.9)) end

end

function get_blu_spells_dex()

	local dex = 0
	local spells_set = T(windower.ffxi.get_mjob_data().spells):filter(function(id) return id ~= 512 end):map(function(id) return blu_spells[id].english end)
	-- here we give each spell a value of 4 or 8 and add the values together
	for index, spell in pairs(spells_set) do
	--for spell in spells_set:it() do
		if spell == 'Acrid Stream' then dex = dex + 2 end
		if spell == 'Anvil Lightning' then dex = dex + 8 end
		if spell == 'Barbed Crescent' then dex = dex + 4 end
		if spell == 'Battle Dance' then dex = dex + 2 end
		if spell == 'Benthic Typhoon' then dex = dex - 1 end
		if spell == 'Blitzstrahl' then dex = dex + 3 end
		if spell == 'Cannonball' then dex = dex + 1 end
		if spell == 'Charged Whisker' then dex = dex + 2 end
		if spell == 'Cimicine Discharge' then dex = dex + 1 end
		if spell == 'Dimensional Death' then dex = dex + 1 end
		if spell == 'Fantod' then dex = dex + 2 end
		if spell == 'Frypan' then dex = dex + 2 end
		if spell == 'Glutinous Dart' then dex = dex + 3 end
		if spell == 'Goblin Rush' then dex = dex + 2 end
		if spell == 'Head Butt' then dex = dex + 2 end
		if spell == 'Hysteric Barrage' then dex = dex + 2 end
		if spell == 'Jet Stream' then dex = dex + 2 end
		if spell == 'Nat. Meditation' then dex = dex + 6 end
		if spell == 'Orcish Counterstance' then dex = dex -2 end
		if spell == 'Palling Salvo' then dex = dex + 6 end
		if spell == 'Paralyzing Triad' then dex = dex + 4 end
		if spell == 'Plasma Charge' then dex = dex + 3 end
		if spell == 'Quadratic Continuum' then dex = dex + 3 end
		if spell == 'Sinker Drill' then dex = dex + 4 end
		if spell == 'Sudden Lunge' then dex = dex + 1 end
		if spell == 'Thunder Breath' then dex = dex + 2 end
		if spell == 'Uppercut' then dex = dex + 1 end
		if spell == 'Whirl of Rage' then dex = dex + 2 end
		if spell == 'Thrashing Assault' then dex = dex + 8 end		
	end

	return dex
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
		if jp > 1529 and jp < 2101 then jp_acc = 41
		elseif jp > 779 and jp < 1530 then jp_acc = 26
		elseif jp > 279 and jp < 780 then jp_acc = 15
		elseif jp > 29 and jp < 280 then jp_acc = 6
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



	
			