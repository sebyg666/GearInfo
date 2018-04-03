
function find_all_values(item)
	
	if item == nil then return nil end
	
	local new_item = res.items:with('id', item.id)
	
	if new_item.flags:contains('Equippable') then
		local bad = false
		for k,v in pairs(bad_ids) do
			if v == item.id then
				bad = true
			end
		end
		
		local str = ''
		if bad == false then
			str = res.item_descriptions:with('id', item.id ).en
		end
		
		str = string.gsub(str, '\n', ' ')
		
		local valid_strings = L{'DEF','HP','MP','STR','DEX','VIT','AGI','INT','MND','CHR','Accuracy','Attack','Haste','Store TP','Dual Wield', 
								'Ranged Accuracy', 'Ranged Attack', 'Rng.Acc.'}
		
		local temp_table = T{}
		local key = 0
		local str_table = str
		temp_table.id = item.id
		temp_table.en = new_item.en
		temp_table.category = new_item.category
		
		for k,v in pairs(new_item) do
			if k == 'delay' then	
				temp_table[k] = tonumber(v)
			end
			if k == 'damage' then
				temp_table[k] = tonumber(v)
			end
			if k == 'skill' then
				local skill = res.skills:with('id', v ).en
				temp_table[k] = skill
			end
			for i,j in pairs(res.skills) do
				if j.id > 0 and j.id < 28 and j.id ~= 24 and j.id ~= 23 and j.id ~= 22	then
					valid_strings:append(j.en.. ' skill')
				end
			end
		end
		--if new_item.id == 14739 then table.vprint(valid_strings) end
		
		if str:contains('Pet:') then
			str_table = str:psplit("Pet:")
			str_table = str_table[1]
		elseif str:contains('Wyvern:') then
			str_table = str:psplit("Wyvern:")
			str_table = str_table[1]
		elseif str:contains('Avatar:') then
			str_table = str:psplit("Avatar:")
			str_table = str_table[1]
		end
		str_table = str_table:psplit("[+-]?%d+")
		--table.vprint(str_table)
		
		for k,v in pairs(str_table) do
			if v == '%' then break end
			if type(v) == 'string' then
				if v:contains('Enhances \"Dual Wield\" effect') then
					--str_table[k] = string.gsub(v, "Enhances \"Dual Wield\" effect", '')
					v = string.gsub(v, "Enhances \"Dual Wield\" effect ", '')
					--log(item.id .. ' = ' .. new_item.en)
				end
				if v:contains('Unity Ranking: \"Store TP\"') then
					--str_table[k] = string.gsub(v, 'Unity Ranking: \"Store TP\"[+-]%d+%p[+-]%d+', '')
					v = string.gsub(v, 'Unity Ranking: \"Store TP\"[+-]?%d+%p[+-]?%d+', '')
				end
				if #v < 2 then
					break
				end
			else
				break
			end
			if #v < 40 then  
				--if item.id == 28477 then table.vprint(str_table) end
				local startpos, endpos = str:find(v)
				--if item.id == 28477 then log(v.. ' ' ..tostring(startpos)..' '..tostring(endpos)) end
				local startpos, endpos = str:find("%a+%s?%a+%s?%a+", startpos)
				--if item.id == 28477 then log(v.. ' ' ..str:sub(startpos, endpos)) end
				if startpos ~= nil then 
					local word = str:sub(startpos, endpos)
					
					if valid_strings:contains(word) then
						local key = word
						--if item.id == 20677 then log(word .. ' '..table.vprint(valid_strings)) end
						local startpos2, endpos2 = str:find(word)
						local startpos3, endpos3 = str:find("[+-]?%d+", endpos2 - 1)
						if startpos3 ~= nil and endpos2 ~= nil then
							if (startpos3 - endpos2) < 3 then									
								key = string.gsub(word, ' ', '_')
								temp_table[key] = tonumber(str:sub(startpos3, endpos3))
							end
						end
					end
				else
					break
				end
			end
		end
		
		local stp = check_gear_stp(new_item.en)
		local dw = check_gear_dw(new_item.en)
		
		for k, v in pairs(temp_table) do
			if v == "Store_TP" and stp > 0 then
				temp_table[v] = temp_table[v] + stp
				stp = 0
			end
			if v == "Dual_Wield" and dw > 0 then
				temp_table[v] = temp_table[v] + dw
				dw = 0
			end
		end
		
		if stp > 0 then temp_table.Store_TP = stp end
		if dw > 0 then temp_table.Dual_Wield = dw end
		

		local item_has_augment = Extdata.decode(item)
		temp_table.augments = item_has_augment.augments
		
		if item_has_augment.augments then
			
			for k,v in pairs(temp_table.augments) do
				
				if v:contains('Pet:') or v:contains('Wyvern:') or v:contains('Avatar:') then
					break
				end
				
				local key = 0
				local j = 0
				
				for i = 0 , #v do
					if i == j then
						valid_strings:append('DMG')
						local startpos, endpos = v:find("%a+%.?%s?%a+%.?", i)
						if startpos ~= nil then
							j = endpos
							local word = v:sub(startpos, endpos)
							if valid_strings:contains(word) then
								--local startpos2, endpos2 = v:find(word, i)
								local startpos2, endpos2 = v:find("[+-]?%d+",endpos)
								local value = tonumber(v:sub(startpos2, endpos2))
								if word == 'Rng.Acc.' then
									word = 'Ranged Accuracy'
								elseif word == 'DMG' then
									word = 'damage'
								end
								key = string.gsub(word, ' ', '_')
								--log(new_item.en .. ' '..new_item.id..' '..temp_key.. ' '..v..' '..word)
								--if new_item.id == 27404 then log(new_item.en .. ' '..new_item.id..' '..key..' '..value) end
								if (startpos2 - endpos) < 3 then 
									if temp_table[key] ~= nil then
										temp_table[key] = temp_table[key] + value
										j = endpos2
									else
										temp_table[key] = value
										j = endpos2
									end
								else
									break
								end
							else
								break
							end
						else
							break
						end
					end
				end				
			end
		end
		
		return temp_table
	end
end

function check_gear_stp(item)
		
	local stp_info = 0
	
	if item:lower() == 'anathema harpe' then
		-- 1 - 5
		if settings.rank == 1 then stp_info = stp_info + 5
		elseif settings.rank == 2 then stp_info = stp_info + 4
		elseif settings.rank == 3 then stp_info = stp_info + 3
		elseif settings.rank == 4 then stp_info = stp_info + 2
		elseif settings.rank == 5 then stp_info = stp_info + 1
		end
	elseif item:lower() == 'anathema harpe +1' then
		-- 1 - 5
		if settings.rank == 1 then stp_info = stp_info + 5
		elseif settings.rank == 2 then stp_info = stp_info + 4
		elseif settings.rank == 3 then stp_info = stp_info + 3
		elseif settings.rank == 4 then stp_info = stp_info + 2
		elseif settings.rank == 5 then stp_info = stp_info + 1
		end
	elseif item:lower() == 'tatenashi haramaki' then
		-- 5 - 9
		if settings.rank == 1 then stp_info = stp_info + 9
		elseif settings.rank == 2 then stp_info = stp_info + 8
		elseif settings.rank == 3 then stp_info = stp_info + 7
		elseif settings.rank == 4 then stp_info = stp_info + 6
		elseif settings.rank == 5 then stp_info = stp_info + 5
		end
	elseif item:lower() == 'tatenashi haramaki +1' then
		-- 5 - 9
		if settings.rank == 1 then stp_info = stp_info + 9
		elseif settings.rank == 2 then stp_info = stp_info + 8
		elseif settings.rank == 3 then stp_info = stp_info + 7
		elseif settings.rank == 4 then stp_info = stp_info + 6
		elseif settings.rank == 5 then stp_info = stp_info + 5
		end
	elseif item:lower() == 'tatenashi gote' then
		-- 4 - 8
		if settings.rank == 1 then stp_info = stp_info + 8
		elseif settings.rank == 2 then stp_info = stp_info + 7
		elseif settings.rank == 3 then stp_info = stp_info + 6
		elseif settings.rank == 4 then stp_info = stp_info + 5
		elseif settings.rank == 5 then stp_info = stp_info + 4
		end
	elseif item:lower() == 'tatenashi gote +1' then
		-- 4 - 8
		if settings.rank == 1 then stp_info = stp_info + 8
		elseif settings.rank == 2 then stp_info = stp_info + 7
		elseif settings.rank == 3 then stp_info = stp_info + 6
		elseif settings.rank == 4 then stp_info = stp_info + 5
		elseif settings.rank == 5 then stp_info = stp_info + 4
		end
	elseif item:lower() == 'tatenashi haidate' then
		-- 4 - 8
		if settings.rank == 1 then stp_info = stp_info + 8
		elseif settings.rank == 2 then stp_info = stp_info + 7
		elseif settings.rank == 3 then stp_info = stp_info + 6
		elseif settings.rank == 4 then stp_info = stp_info + 5
		elseif settings.rank == 5 then stp_info = stp_info + 4
		end
	elseif item:lower() == 'tatenashi haidate +1' then
		-- 4 - 8
		if settings.rank == 1 then stp_info = stp_info + 8
		elseif settings.rank == 2 then stp_info = stp_info + 7
		elseif settings.rank == 3 then stp_info = stp_info + 6
		elseif settings.rank == 4 then stp_info = stp_info + 5
		elseif settings.rank == 5 then stp_info = stp_info + 4
		end
	elseif item:lower() == 'tatenashi sune-ate' then
		-- 4 - 8
		if settings.rank == 1 then stp_info = stp_info + 8
		elseif settings.rank == 2 then stp_info = stp_info + 7
		elseif settings.rank == 3 then stp_info = stp_info + 6
		elseif settings.rank == 4 then stp_info = stp_info + 5
		elseif settings.rank == 5 then stp_info = stp_info + 4
		end
	elseif item:lower() == 'tatenashi sune-ate +1' then
		-- 4 - 8
		if settings.rank == 1 then stp_info = stp_info + 8
		elseif settings.rank == 2 then stp_info = stp_info + 7
		elseif settings.rank == 3 then stp_info = stp_info + 6
		elseif settings.rank == 4 then stp_info = stp_info + 5
		elseif settings.rank == 5 then stp_info = stp_info + 4
		end
	elseif item:lower() == 'kentarch belt' then
		-- 1 - 5
		if settings.rank == 1 then stp_info = stp_info + 5
		elseif settings.rank == 2 then stp_info = stp_info + 4
		elseif settings.rank == 3 then stp_info = stp_info + 3
		elseif settings.rank == 4 then stp_info = stp_info + 2
		elseif settings.rank == 5 then stp_info = stp_info + 1
		end
	elseif item:lower() == 'kentarch belt +1' then
		-- 1 - 5
		if settings.rank == 1 then stp_info = stp_info + 5
		elseif settings.rank == 2 then stp_info = stp_info + 4
		elseif settings.rank == 3 then stp_info = stp_info + 3
		elseif settings.rank == 4 then stp_info = stp_info + 2
		elseif settings.rank == 5 then stp_info = stp_info + 1
		end
	end
	
	return stp_info
end

function check_gear_dw(item)
	local dw_info = 0
	if item:lower() == 'suppanomimi' then
		dw_info = dw_info + 5
	elseif item:lower() == 'sarashi' then
		dw_info = dw_info + 1
	elseif item:lower() == 'ninja chainmail' then
		dw_info = dw_info + 5
	elseif item:lower() == 'ninja chainmail +1' then
		dw_info = dw_info + 5
	elseif item:lower() == 'koga hakama' then
		dw_info = dw_info + 5
	elseif item:lower() == 'koga hakama +1' then
		dw_info = dw_info + 5
	elseif item:lower() == 'charis necklace' then
		dw_info = dw_info + 3	
	elseif item:lower() == 'auric dagger' then
		dw_info = dw_info + 5
	elseif item:lower() == 'raider\'s boomerang' then
		dw_info = dw_info + 3
	elseif item:lower() == 'iga zukin +2' then
		dw_info = dw_info + 5
	elseif item:lower() == 'iga mimikazari' then
		dw_info = dw_info + 1
	elseif item:lower() == 'charis casaque +1' then
		dw_info = dw_info + 5
	elseif item:lower() == 'charis casaque +2' then
		dw_info = dw_info + 10
	elseif item:lower() == 'koga chainmail +2' then
		dw_info = dw_info + 3
	elseif item:lower() == 'koga hakama +2' then
		dw_info = dw_info + 7
	elseif item:lower() == 'patentia sash' then
		dw_info = dw_info + 5
	elseif item:lower() == 'skadi\'s cuirie +1' then
		dw_info = dw_info + 7
	elseif item:lower() == 'thurandaut chapeau' then
		dw_info = dw_info + 5
	elseif item:lower() == 'thurandaut chapeau +1' then
		dw_info = dw_info + 5
	elseif item:lower() == 'hachiya chainmail' then
		dw_info = dw_info + 7
	elseif item:lower() == 'hachiya chainmail +1' then
		dw_info = dw_info + 8
	elseif item:lower() == 'hachiya hakama' then
		dw_info = dw_info + 3
	elseif item:lower() == 'hachiya hakama +1' then
		dw_info = dw_info + 3
	elseif item:lower() == 'mochizuki chainmail' then
		dw_info = dw_info + 6
	elseif item:lower() == 'mochizuki hakama' then
		dw_info = dw_info + 8
	elseif item:lower() == 'dudgeon earring' then
		dw_info = dw_info + 0
	elseif item:lower() == 'heartseeker earring' then
		dw_info = dw_info + 0
	end
	
	return dw_info
	
end

bad_ids = {10293,6102,6103,6104,6105,6106,6107,6108,6109,6110,6111,6112,6113,6114,6115,6116,6117,6118,6119,6120,6121,6122,6123,6124,6125,6126,6127,6128,6129,6130,6132,
			11697,11988,11989,11990,11991,11992,11993,11994,11995,11996,11997,11998,11999,12000,12001,12002,12003,12004,12005,12006,12007,12491,12619,13121,13122,
			13147,13517,13842,14117,14242,14628,14629,14647,14648,15847,15848,15930,15931,15932,16008,16285,16286,16287,16288,16289,16290,16295,17345,17353,17356,18338}

		
function get_equip_stats(equipment_table)
	local item_haste = 0
	local item_dw = 0
	local item_stp = 0
	local haste_info_perc = 0
	local item_info = {haste = 0, dual_wield = 0, stp = 0 }
	
	if type(equipment_table) ~= 'table' or equipment_table == nil then
		windower.add_to_chat(200,'get_equip_stats() function went wrong')
		return item_info
	else
		for k,v in pairs(equipment_table) do
			for i,j in pairs(v) do
				if i == 'Haste' then
					item_haste = item_haste + j
				elseif i == 'Dual_Wield' then 
					item_dw = item_dw + j
				elseif i == 'Store_TP' then
					item_stp = item_stp + j
				end
			end
		end
	end
	
	-- Set bonus declaration
	if (player.equipment.right_ear.en == 'Dudgeon Earring' and player.equipment.left_ear.en == 'Heartseeker Earring') or  (player.equipment.right_ear.en == 'Heartseeker Earring' and player.equipment.left_ear.en == 'Dudgeon Earring') then
		item_dw = item_dw + 7
	end
	
	haste_info_perc = math.floor(item_haste / 100 * 1024)
	
	--log(haste_info_perc)
	
	-- local temp_info = item_info
	item_info.haste = haste_info_perc + manual_ghaste
	item_info.dual_wield = item_dw + manual_dw
	item_info.stp = item_stp + manual_stp
	--table.vprint(item_info)
	return item_info
	
end

function get_player_acc(equip)
	get_packet_data()
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
				--table.vprint(main_hand)
			elseif k == 'sub' and v.id ~= 0 and v.category == 'Weapon' and melee_skills:contains(v.skill) then
				--if v.en == 'Ochu' then table.vprint(v) end
				if v.damage > 0 then
					sub_hand.skill = v.skill
				end
			end
			if k == 'range' and v.id ~= 0 and v.category == 'Weapon' and ranged_skills:contains(v.skill) then
				ranged.skill = v.skill
				--table.vprint(main_hand)
			elseif k == 'ammo' and v.id ~= 0 and v.category == 'Weapon' and ranged_skills:contains(v.skill) then
				--if v.en == 'Ochu' then table.vprint(v) end
				if v.damage > 0 then
					ammo.skill = v.skill
				end
			end
		end
		for k,v in pairs(equip) do
			for i,j in pairs(v) do
				if k == 'main' and v.id ~= 0 and v.category == 'Weapon' then
					local key = string.gsub(main_hand.skill, ' ', '_')
					if i == key..'_skill' then
						main_hand.value = main_hand.value + v[key..'_skill']
					end
				end
				if k == 'sub' and v.id ~= 0 and v.category == 'Weapon' then
					if v.damage > 0 then
						local key = string.gsub(sub_hand.skill, ' ', '_')
						if i == key..'_skill' then
							sub_hand.value = sub_hand.value + v[key..'_skill']
						end
					end
				end
				if k == 'range' and v.id ~= 0 and v.category == 'Weapon' then
					local key = string.gsub(ranged.skill, ' ', '_')
					if i == key..'_skill' then
						ranged.value = ranged.value + v[key..'_skill']
					end
				end
				if k == 'ammo' and v.id ~= 0 and v.category == 'Weapon' then
					if v.damage > 0 then
						local key = string.gsub(ammo.skill, ' ', '_')
						if i == key..'_skill' then
							ammo.value = ammo.value + v[key..'_skill']
						end
					end
				end
				if i == 'DEX' then
					item_dex = item_dex + j
				elseif i == 'Accuracy' then 
					item_acc = item_acc + j
					--log(item_acc .. ' '..v.en)
				elseif i == 'AGI' then 
					item_agi = item_agi + j
				elseif i == 'Ranged_Accuracy' then 
					item_racc = item_racc + j
				elseif v.category == "Armor" then
					--log(i .. ' ' .. string.gsub(main_hand.skill, ' ', '_')..'_skill')
					if i == string.gsub(main_hand.skill, ' ', '_')..'_skill' then
						skill_from_gear_main = skill_from_gear_main + j
					end
					if i == string.gsub(sub_hand.skill, ' ', '_')..'_skill' then 
						skill_from_gear_sub = skill_from_gear_sub + j
					end
					if i == string.gsub(ranged.skill, ' ', '_')..'_skill' then
						skill_from_gear_ranged = skill_from_gear_ranged + j
					end
					if i == string.gsub(ammo.skill, ' ', '_')..'_skill' then
						skill_from_gear_ammo = skill_from_gear_ammo + j
					end
				end
			end
		end
	end
	--log(string.gsub(main_hand.skill, ' ', '_')..'_skill'..' '..skill_from_gear_main ..' '..string.gsub(sub_hand.skill, ' ', '_')..'_skill'..' '..skill_from_gear_sub)
	for k,v in pairs(player) do
		if k == 'skill' then 
			--table.vprint(v)
			for i,j in pairs(v) do
				--log(i:lower() .. ' '.. string.gsub(main_hand.skill:lower(), ' ', '_') )
				if i:lower() == string.gsub(main_hand.skill:lower(), ' ', '_') then
					main_hand.value = main_hand.value + j
				end
				if i:lower() == string.gsub(sub_hand.skill:lower(), ' ', '_') then
					sub_hand.value = sub_hand.value + j
				end
				if i:lower() == string.gsub(ranged.skill:lower(), ' ', '_') then
					ranged.value = ranged.value + j
				end
				if i:lower() == string.gsub(ammo.skill:lower(), ' ', '_') then
					ammo.value = ammo.value + j
				end
			end
		end	
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

	if player.equipment.sub.id ~= 0 and player.equipment.sub.category == 'Weapon' and player.equipment.sub.damage > 0 then
		Total_acc.sub = sub_acc_skill + math.floor((item_dex + player_dex + get_blu_spells_dex()) * 0.75) + item_acc + get_player_acc_from_job()
	else
		Total_acc.sub = 0
	end
	if player.equipment.range.id ~= 0 and player.equipment.range.category == 'Weapon' then
		Total_acc.range = ranged_acc_skill + math.floor((item_agi + player_agi) * 0.75) + item_racc + get_player_acc_from_job()
	else
		Total_acc.range = 0
	end
	if player.equipment.ammo.id ~= 0 and player.equipment.ammo.category == 'Weapon' and player.equipment.ammo.damage > 0 then
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



	
			