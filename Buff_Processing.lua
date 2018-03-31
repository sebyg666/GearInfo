buff_info = {h_spikes = false }

function check_buffs()
	
	local marches = {417, 419, 420}
	marches[417] = 127
	marches[419] = 107
	marches[420] = 163
	local total_haste = 0
	local song_found = false
	local song_found2 = false
	
	for index, buff in pairs(_ExtraData.player.buff_details) do
		local this_buff = _ExtraData.player.buff_details[index]
		if buff.id == 64 then -- last resort
			if player.main_job:upper() == 'DRK' and player.main_job_level == 99 then
				this_buff['ja_haste'] = math.ceil(((player.merits.desperate_blows * 2) + 15)/100*1024)
			elseif player.main_job:upper() == 'DRK' and player.main_job_level < 99 and player.main_job_level > 75 then
				this_buff['ja_haste'] = math.ceil(((player.merits.desperate_blows * 2) + 5)/100*1024)
			elseif player.main_job:upper() == 'DRK' and player.main_job_level < 75 then
				this_buff['ja_haste'] = 52
			elseif player.sub_job:upper() == 'DRK' then
				this_buff['ja_haste'] = 52
			end
		elseif buff.id == 353 then -- Hasso
			this_buff['ja_haste'] = 103
		elseif buff.id == 604 then -- mighty_guard
			this_buff['ma_haste'] = 150
		elseif buff.id == 228 then -- Embrava max 266 @ 500 Enhancing magic skill
			this_buff['ma_haste'] = 260
		elseif buff.id == 580 then -- indi_haste 
			this_buff['ma_haste'] = 307
		elseif buff.id == 33 then -- haste 
			if buff.full_name == "Haste II" then
				this_buff['ma_haste'] = 307
			elseif buff.full_name == "Erratic Flutter" then
				this_buff['ma_haste'] = 307
			elseif buff.full_name == "Hastega II" then
				this_buff['ma_haste'] = 307
			else
				this_buff['ma_haste'] = 150
			end
		elseif buff.id == 227 then
			this_buff['STP'] = 10
		end
		
		local caster = 'Unknown'
		local song_names = S{'Honor March', 'Victory March', 'Advancing March'}
		if buff.name == "March" then
			if table.containskey(buff, "full_name") then
				if buff.full_name ~= 'March' then
					if not table.containskey(buff, "potency") then
						local potency = 0
						local All_songs = 0
						if table.containskey(settings.Bards, buff.Caster) then
							All_songs = settings.Bards[buff.Caster]
							caster = buff.Caster
						else
							All_songs = manual_bard_duration_bonus
						end

						if table.containskey(buff, 'Marcato') and buff.Marcato == true then 
							potency = 0.5
						end
						if table.containskey(buff, 'SV') and buff.SV == true then 
							potency = 1
						end
						
						local spell = res.spells:with('en', buff.full_name)
						if buff.full_name == "Honor March" then 
							All_songs = All_songs - 4
						end
						potency = potency + (All_songs / 10)+ 1
						this_buff['ma_haste'] = math.floor(marches[spell.id] * potency)
						this_buff['potency'] = potency
						this_buff['All_songs'] = All_songs
						song_found = buff.full_name
					end
					if table.containskey(buff, 'reported') then
						if buff['reported'] == false then 
							local msg = ''
							if table.containskey(buff, "Marcato") and buff.Marcato == true then
								msg = msg .. ' Marcato'
							end
							if table.containskey(buff, 'SV') and buff.SV == true then 
								msg = msg .. ' SV'
							end
							notice('① ' .. caster:ucfirst() .. ' → "'..buff.full_name ..'": '.. this_buff['ma_haste'] .. ', Potency = ' .. (this_buff['potency']*100) .. '%, All Songs +' .. this_buff['All_songs']  .. msg)
							this_buff['reported'] = true
						end
					else
						local msg = ''
						if table.containskey(buff, "Marcato") and buff.Marcato == true then
							msg = msg .. ' Marcato'
						end
						if table.containskey(buff, 'SV') and buff.SV == true then 
							msg = msg .. ' SV'
						end
						notice('① ' .. caster:ucfirst().. ' → "'..buff.full_name ..'": '.. this_buff['ma_haste'] .. ', Potency = ' .. (this_buff['potency']*100) .. '%, All Songs +' .. this_buff['All_songs']  .. msg)
						this_buff['reported'] = true
					end
				else
					if song_found2 then
						this_buff['ma_haste'] = math.floor(marches[417] * ((manual_bard_duration_bonus - 4)/ 10 + 1))
						this_buff['potency'] = (manual_bard_duration_bonus - 4) / 10 + 1
					else
						song_found2 = true
						this_buff['ma_haste'] = math.floor(marches[419] * (manual_bard_duration_bonus / 10 + 1))
						this_buff['potency'] = manual_bard_duration_bonus / 10 + 1
					end
					this_buff['All_songs'] = 0
					if table.containskey(buff, 'reported') then
						if buff['reported'] == false then 
							notice('② ' .. caster:ucfirst() .. ' → "'..buff.name ..'": '.. this_buff['ma_haste'] .. ', Potency = ' .. (this_buff['potency']*100) .. '%, All Songs +' .. this_buff['All_songs']  )
							this_buff['reported'] = true
						end
					else
						notice('② ' .. caster:ucfirst() .. ' → "'..buff.name ..'": '.. this_buff['ma_haste'] .. ', Potency = ' .. (this_buff['potency']*100) .. '%, All Songs +' .. this_buff['All_songs']  )
						this_buff['reported'] = true
					end
				end
			else
				if song_found2 then
					this_buff['ma_haste'] = math.floor(marches[417] * ((manual_bard_duration_bonus - 4)/ 10 + 1))
					this_buff['potency'] = (manual_bard_duration_bonus - 4) / 10 + 1
				else
					song_found2 = true
					this_buff['ma_haste'] = math.floor(marches[419] * (manual_bard_duration_bonus / 10 + 1))
					this_buff['potency'] = manual_bard_duration_bonus / 10 + 1
				end
				this_buff['All_songs'] = 0
				if table.containskey(buff, 'reported') then
					if buff['reported'] == false then 
						notice('③ ' .. caster:ucfirst() .. ' → "'..buff.name ..'": '.. this_buff['ma_haste'] .. ', Potency = ' .. (this_buff['potency']*100) .. '%, All Songs +' .. this_buff['All_songs']  )
						this_buff['reported'] = true
					end
				else
					notice('③ ' .. caster:ucfirst() .. ' → "'..buff.name ..'": '.. this_buff['ma_haste'] .. ', Potency = ' .. (this_buff['potency']*100) .. '%, All Songs +' .. this_buff['All_songs'] )
					this_buff['reported'] = true
				end
			end
		end
		
	end
	-- if check_it then
		-- table.vprint(_ExtraData.player.buff_details)
	-- end
end

function calculate_total_haste()
	Buffs_inform.magic_haste = 0
	Buffs_inform.ja_haste = 0
	Buffs_inform.STP = 0
	local hasso_bonus = 0
	
	if buff_info.h_spikes and windower.ffxi.get_player().status == 1 then
		if dancer_main then
			Buffs_inform.ja_haste = Buffs_inform.ja_haste + 101
		else
			Buffs_inform.ja_haste = Buffs_inform.ja_haste + 51
		end
	else
		Buffs_inform.ja_haste = 0
		buff_info.h_spikes = false
	end
		
	for index, buff in pairs(_ExtraData.player.buff_details) do
		if buff.id == 353 then -- Hasso
			for k,v in pairs(player.equipment.hands) do
				if k == 'en' then
					if player.equipment.hands.en:lower() == "wakido kote" then	
						hasso_bonus = hasso_bonus + 10
					elseif player.equipment.hands.en:lower() == "wakido kote +1" then	
						hasso_bonus = hasso_bonus + 20
					elseif player.equipment.hands.en:lower() == "wakido kote +2" then	
						hasso_bonus = hasso_bonus + 30
					elseif player.equipment.hands.en:lower() == "wakido kote +3" then	
						hasso_bonus = hasso_bonus + 40
					end
				end		
			end
			for k,v in pairs(player.equipment.legs) do
				if k == 'en' then
					if player.equipment.legs.en:lower() == "unkai haidate +1" then	
						hasso_bonus = hasso_bonus + 15
					elseif player.equipment.legs.en:lower() == "unkai haidate +2" then	
						hasso_bonus = hasso_bonus + 25
					elseif player.equipment.legs.en:lower() == "kasuga haidate" then	
						hasso_bonus = hasso_bonus + 25
					elseif player.equipment.legs.en:lower() == "kasuga haidate +1" then	
						hasso_bonus = hasso_bonus + 30
					end
				end		
			end
			for k,v in pairs(player.equipment.feet) do
				if k == 'en' then
					if player.equipment.feet.en:lower() == "wakido sune. +2" then	
						hasso_bonus = hasso_bonus + 10
					elseif player.equipment.feet.en:lower() == "wakido sune. +3" then	
						hasso_bonus = hasso_bonus + 20
					end
				end		
			end
		end
	end
	for index, buff in pairs(_ExtraData.player.buff_details) do
		if table.containskey(buff, 'ma_haste') then
			Buffs_inform.magic_haste = Buffs_inform.magic_haste + buff['ma_haste']
		elseif table.containskey(buff, 'ja_haste') then
			Buffs_inform.ja_haste = Buffs_inform.ja_haste + buff['ja_haste'] + hasso_bonus
		elseif table.containskey(buff, 'STP') then
			Buffs_inform.STP = Buffs_inform.STP + buff['STP']	
		end
	end
	
	return Buffs_inform
end