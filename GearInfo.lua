_addon.name = 'GearInfo'
_addon.author = 'Sebyg666'
_addon.version = '1.6.2.1'
_addon.commands = {'gi','gearinfo'}


require('tables')
require('lists')
require('strings')
require('logger')
require('lists')
require('pack')

res = require('resources')
skills_from_resources = res.skills
Extdata = require("extdata")
texts = require('texts')
config = require('config')
files = require('files')
blu_spells = res.spells:type('BlueMagic')
timer = require('timeit')
packets = require('packets')
bit = require('bit')

require 'Statics'
require 'Gear_Processing'
require 'Calculator'
require 'Action_Processing'
require 'Buff_Processing'
require 'Packet_parsing'

defaults = {}
defaults.player = {}
defaults.player.show_total_haste = true
defaults.player.show_tp_Stuff = true
defaults.player.show_acc_Stuff = true
defaults.player.update_gs = true
defaults.player.rank = 1
defaults.Bards = {}
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 150
defaults.display.bg.visible = true
defaults.display.flags = {}
defaults.display.flags.draggable = true
defaults.display.flags.bold = false
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12
defaults.display.text.stroke = {}
defaults.display.text.stroke.width = 2
defaults.display.text.stroke.alpha = 255
defaults.display.text.stroke.red = 0
defaults.display.text.stroke.green = 0
defaults.display.text.stroke.blue = 0

settings = config.load('data\\'..windower.ffxi.get_player().name..'_settings.xml',defaults)

text_box = texts.new(settings.display, settings)

text_box:register_event('reload', initialize)

initialize = function(text, t)
    local properties = L{}
	
	properties:append('${title}')
	properties:append('${tp_per__hit}')
	properties:append('${tp_per__hit_range}')
	properties:append('${zanshin}')
	properties:append('${wstp}')
	properties:append('${tp_to_100}')
	properties:append('${Rtp_to_100}')
	properties:append('${title2}')
	properties:append('${stp}')
	properties:append('${dw}')
	properties:append('${bstp}')
	properties:append('${dw_needed}')
	properties:append('${ghaste}')
	properties:append('${mhaste}')
	properties:append('${jhaste}')
	properties:append('${thaste}')
	properties:append('${T_acc}')
	properties:append('${T_racc}')
	properties:append('${ugs}')
	
    text:clear()
    text:append(properties:concat(''))
end

initialize(text_box)

windower.register_event('load', function()
	if player ~= nil then
		options_load()
		text_box:show()
		doloop = true
		--loop()
	end
end)

windower.register_event('logout', function()
	loged_out_bool = true

	player = {}
	player.equipment = T{}
	buff = 0
	full_gear_table_from_file = T{}
	
	manual_stp = 0
	manual_dw = 0
	manual_ghaste = 0
	WSTP = 0
	
	-- print('Gearinfo detected logout')
end)

windower.register_event('login',function ()
	timer:start()
	loged_in_bool = true
	-- print('Gearinfo detected login')   
end)

function options_load()
	if windower.ffxi.get_player() then
		player = windower.ffxi.get_player()
		update_party()
		initialize_packet_parsing()
		local this_file = files.new('data\\'..player.name..'_data.lua',true)
		
		if not files.exists('data\\'..player.name..'_data.lua') then
			this_file:create()
			local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w+')
			--f:write(temp)
			-- Quick method
			f:write('return {\n}')
			f:close()
			print(player.name..'_data.lua created by GearInfo')
			parse_inventory()
		else
			full_gear_table_from_file = get_equipment_from_file()
		end
		manual_stp = 0
		manual_dw = 0
		manual_ghaste = 0
	end
	
end

windower.register_event('addon command', function(command, ...)
	local args = {...}
    command = command and command:lower()
    if command then
        if command:lower() == 'parse' then
			log('Parsing all inventories to file')
			parse_inventory()
		elseif command:lower() == 'rank' then
			--table.vprint(args)
			if type(tonumber(args[1])) == 'number' and tonumber(args[1]) < 6 then
				settings.player.rank = tonumber(args[1])
				log('Changed \'Unity Rank\' to '..tonumber(args[1])..'.')
				config.save(settings)
			elseif type(tonumber(args[1])) == 'number' and tonumber(args[1]) > 5 then
				settings.player.rank = 5
				log('Changed \'Unity Rank\' to lowest: 5.')
			else
				log('Your current \'Unity Rank\' setting is: '..settings.player.rank..'.')
			end
			settings:save()
		elseif command:lower() == 'stp' and type(tonumber(args[1])) == 'number' then
			manual_stp = tonumber(args[1])
			log('Set maunal Store TP to ' .. tostring(manual_stp))
		elseif command:lower() == 'dw' and type(tonumber(args[1])) == 'number' then
			manual_dw = tonumber(args[1])
			log('Set maunal Dual Wield to ' .. tostring(manual_dw))
		elseif command:lower() == 'ghaste' and type(tonumber(args[1])) == 'number' then
			manual_ghaste = tonumber(args[1])
			log('Set maunal Gear Haste to ' .. tostring(manual_ghaste))
		elseif command:lower() == 'mhaste' and type(tonumber(args[1])) == 'number' then
			manual_mhaste = tonumber(args[1])
			log('Set maunal Magic Haste to ' .. tostring(manual_mhaste))
		elseif command:lower() == 'jahaste' and type(tonumber(args[1])) == 'number' then
			manual_jahaste = tonumber(args[1])
			log('Set maunal Job Ability Haste to ' .. tostring(manual_jahaste))
		elseif command:lower() == 'dwn' and type(tonumber(args[1])) == 'number' then	
			manual_dw_needed = tonumber(args[1])
			log('Set maunal DW needed to ' .. tostring(manual_dw_needed))
		elseif command:lower() == 'r' or command:lower() == 'reload' then
			log('Reloading')
			windower.send_command('lua r gearinfo;')
		elseif command:lower() == 'save' or command:lower() == 's' then
			if args[1]:lower() == 'wstp' then
				WSTP = get_tp_per_hit(player.equipment).tp_per_hit_melee
			else
				log('Misstype: use //gi save wstp')
			end
		elseif command:lower() == 'delete' or command:lower() == 'd' then
			if args[1]:lower() == 'wstp' then
				WSTP = 0
			else
				log('Misstype: use //gi delete wstp')
			end	
		elseif command:lower() == 'hide' then
			if text_box:visible() then
				manual_hide = true
				text_box:hide()
				log('Hiding Display')
			else
				manual_hide = false
				text_box:show()
				log('Showing Display')
			end
		elseif command:lower() == 'update' then
			update_gs(DW, (DW_needed + manual_dw_needed), get_total_haste())
		elseif command:lower() == 'updategs' or command:lower() == 'ugs' then
			if args[1] == nil then
				if settings.player.update_gs == false then
					settings.player.update_gs = true
				elseif settings.player.update_gs then
					settings.player.update_gs = false
				end
			elseif args[1]:lower() == 'true' then
				settings.player.update_gs = true
			elseif args[1]:lower() == 'false' then
				settings.player.update_gs = false
			end
			log('Auto update Gearswap = '..tostring(settings.player.update_gs))
			settings:save()
		elseif command:lower() == 'brd' then
			if type(tonumber(args[1])) == 'number' then
				manual_bard_duration_bonus = tonumber(args[1])
				log('Set Brd song+ bonus to ' .. tostring(manual_bard_duration_bonus) .. '.')
			elseif args[1]:lower() == 'add' and type(tostring(args[2])) == 'string' and type(tonumber(args[3])) == 'number' then
				settings.Bards[args[2]:lower()] = tonumber(args[3])
				settings:save()
				log('Added ' .. tostring(args[2]:lower()) .. ' as a known bard with ' .. tonumber(args[3]) .. ' Song+ !')
			elseif args[1]:lower() == 'delete' and type(tostring(args[2])) == 'string' then
				settings.Bards[tostring(args[2])] = nil
				settings:save()
				log('Removed ' .. tostring(args[2]:lower()) .. ' as a known bard!')
			end
		elseif command:lower() == 'dnc' then
			if dancer_main then
				dancer_main = false
			else
				dancer_main = true
			end
			log('toggled DNC buff from main job to -> ' .. tostring(dancer_main) .. '.')
		elseif command:lower() == 'show' then
			
			if args[1]:lower() == 'haste' then
				if settings.player.show_total_haste == false then
					settings.player.show_total_haste = true
				elseif settings.player.show_total_haste then
					settings.player.show_total_haste = false
				end
				log('Show Total Haste = '..tostring(settings.player.show_total_haste))
			elseif args[1]:lower() == 'tp' then
				if settings.player.show_tp_Stuff == false then
					settings.player.show_tp_Stuff = true
				elseif settings.player.show_tp_Stuff then
					settings.player.show_tp_Stuff = false
				end
				log('Show Tp calculations = '..tostring(settings.player.show_tp_Stuff))
			elseif args[1]:lower() == 'acc' then
				if settings.player.show_acc_Stuff == false then
					settings.player.show_acc_Stuff = true
				elseif settings.player.show_acc_Stuff then
					settings.player.show_acc_Stuff = false
				end
				log('Show Total Acc = '..tostring(settings.player.show_acc_Stuff))
			end
			settings:save()
		elseif command:lower() == 'test' then
			--player.stats = get_packet_data_base_stats()
			get_packet_data()
			Total_acc = get_player_acc(check_equipped())
			log(player.stats.DEX .. ' '.. Total_acc.dex .. ' '.. Total_acc.main.. ' '.. Total_acc.sub)
			log(player.stats.AGI .. ' '.. Total_acc.agi .. ' '.. Total_acc.range.. ' '.. Total_acc.ammo)
		elseif command:lower() == 'debug' then
			if debug_mode == false then
				debug_mode = true
			else
				debug_mode = false
			end
			log('Toggled Debug Mode to '..tostring(debug_mode))
		elseif command:lower() == 'help' then
			
			local chat_purple = string.char(0x1F, 200)
			local chat_grey = string.char(0x1F, 160)
			local chat_red = string.char(0x1F, 167)
			local chat_white = string.char(0x1F, 001)
			local chat_green = string.char(0x1F, 214)
			local chat_yellow = string.char(0x1F, 036)
			local chat_d_blue = string.char(0x1F, 207)
			local chat_pink = string.char(0x1E, 5)
			local chat_l_blue = string.char(0x1E, 6)
			
			windower.add_to_chat(6, ' ')
			windower.add_to_chat(6, chat_white.. 	'                         --------------------------' )
			windower.add_to_chat(6, chat_d_blue.. 	'                         Welcome to GearInfo help!' )
			windower.add_to_chat(6, chat_white.. 	'                         --------------------------' )
			windower.add_to_chat(6, ' ')
			windower.add_to_chat(6, chat_d_blue.. 	'Commands available:' )
			windower.add_to_chat(6, ' ')
			windower.add_to_chat(6, chat_l_blue.. 	'\'\/\/gi parse\'' .. chat_white .. '  --  Will reload your inventory to file (eg. after changing unity rank).')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi rank\'' .. chat_white .. '   --  Shows current unity rank setting.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi rank #\'' .. chat_white .. '  --  Change # to your unity rank, anything over 5 is set to 5.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi stp #\'' .. chat_white .. '  --  Change # to + or - \'Store TP\' manually. eg. ' .. chat_yellow .. ' \/\/gs stp +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs stp 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi dw #\'' .. chat_white .. '  --  Change # to + or - \'Dual Wield\' manually. eg. ' .. chat_yellow .. ' \/\/gs dw +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs dw 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi haste #\'' .. chat_white .. '  --  Change # to + or - \'Haste\' manually. eg. ' .. chat_yellow .. ' \/\/gs haste +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs haste 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi dwn #\'' .. chat_white .. '  --  Change # to + or - \'DW needed\'. eg. ' .. chat_yellow .. ' \/\/gs dwn +10'.. chat_white ..' or ' .. chat_yellow  .. '\/\/gs dwn 10')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi save/s wstp\'' .. chat_white .. '  --  saves current tp/hit into new line.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi delete/d wstp\'' .. chat_white .. '  --  deletes previously created line.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi brd #\'' .. chat_white .. '  --  Change # to equal your parties BRD max March Bonus.')
			windower.add_to_chat(6, chat_l_blue..	'          add \'name\' \'bonus\'' .. chat_white .. '  --  Save the bard with name and Bonus for future use.')
			windower.add_to_chat(6, chat_yellow..	'eg. \/\/gi brd add bob 7' .. chat_white .. '  --  This will add bob to the list with +7 March Bonus.')
			windower.add_to_chat(6, chat_l_blue..	'          delete \'name\'' .. chat_white .. '  --  Delete a bard from the list.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi dnc\'' .. chat_white .. '  --  Toggle if your party is getting Haste Samba from a main DNC or not.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi hide\'' .. chat_white .. '  --  Toggle hide and unhide box.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi show\'' .. chat_white .. '  --  add subcommand.')
			windower.add_to_chat(6, chat_l_blue..	'              \'haste\'' .. chat_white .. '  --  Toggle hide Total haste.')
			windower.add_to_chat(6, chat_l_blue..	'              \'tp\'' .. chat_white .. '  --  Toggle hide TP Calculator.')
			windower.add_to_chat(6, chat_l_blue..	'              \'acc\'' .. chat_white .. '  --  Toggle hide Acc Calculations.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi help\'' .. chat_white .. '  --  This command or any mistakes will show this menu.')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi updategs'.. chat_white ..' or ' .. chat_l_blue .. 'ugs\'' .. chat_white .. '  --  toggle Send info to GearSwap for use, Can add true / false')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi update\'' .. chat_white .. '  --  forces 1 update to gearswap')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi debug\'' .. chat_white .. '  --  toggle debug mode')
			windower.add_to_chat(6, chat_l_blue..	'\'\/\/gi r'.. chat_white ..' or ' .. chat_l_blue .. 'reload\'' .. chat_white .. '  --  Reload addon GearInfo.')
			windower.add_to_chat(6, ' ')

		-- elseif command:lower() == 'test' then	
			-- check_none_existant_ids()
		else
			windower.send_command('gi help')
		end
	else
		windower.send_command('gi help')
	end
end)

function save_table_to_file(item_table)

	local new_item = item_table
	
	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','w+')
	--f:write(temp)
	-- Quick method
	f:write('return ' .. T(new_item):tovstring())
    f:close()
end

function get_equipment_from_file()

	local f = io.open(windower.addon_path..'data/'..player.name..'_data.lua','r')
	local t = f:read("*all")
	t = assert(loadstring(t))()
	f:close()
	
	return t
end

function parse_inventory()
	
	local items_in_bag = T{}
	local full_gear_table_rw = T{}
	for k,v in pairs(res.bags) do
		for i,n in pairs(windower.ffxi.get_items(v.id)) do
			items_in_bag[#items_in_bag +1] = n
		end
	end
	for k,v in pairs(items_in_bag) do
		if v ~= nil and type(v) == 'table' then
			if v.id ~= 0 then
				local this_item = find_all_values(v)
				if this_item ~= nil then
					full_gear_table_rw[#full_gear_table_rw +1] = this_item
				end
			end
		end	
	end
	
	full_gear_table_from_file = full_gear_table_rw
	save_table_to_file(full_gear_table_from_file)
end

function parse_new_single_item(item)

	if item ~= nil and type(item) == 'table' then
		if item.id ~= 0 then
			local this_item = find_all_values(item)
			if this_item ~= nil then
				full_gear_table_from_file[#full_gear_table_from_file +1] = this_item
			end
			
			save_table_to_file(full_gear_table_from_file)
			
			return this_item
		end
	end
end

function check_equipped()

	local new_gear_table = T{}
	local local_gear_table = T{}
	local items_equipped = windower.ffxi.get_items().equipment
	
	local default_slot = T{'sub','range','ammo','head','body','hands','legs','feet','neck','waist', 'left_ear', 'right_ear', 'left_ring', 'right_ring','back'}
	default_slot[0]= 'main'	
	
	if items_equipped then
		for id,name in pairs(default_slot) do
			items_equipped[name] = {
                    slot = items_equipped[name],
                    bag = items_equipped[name..'_bag']
                    }
                    items_equipped[name..'_bag'] = nil
			
		end
	end
	
	for k,v in pairs(items_equipped) do
		if v.slot == 0 then
			new_gear_table[k] = {count = 0 ,status = 0,id = 0,slot = 0,bazaar = 0,extdata = ''}
		else
			new_gear_table[k] = windower.ffxi.get_items(v.bag, v.slot)
		end
	end

	local sloted_items = new_gear_table
	for k,v in pairs(new_gear_table) do
		if v.count > 0 then
			local item_has_augment = Extdata.decode(v)
			local no_match = true
			local temp_item = new_gear_table[k]

			for x,y in pairs(full_gear_table_from_file) do
				if v.id == y.id then
					if type(item_has_augment.augments) == 'table' and table.length(item_has_augment.augments) > 0 then
						for i, j in pairs(y) do
							local int = 0
							if i == 'augments' then
								for a,b in pairs(item_has_augment.augments) do
									if j[a]:contains(b) then
										int = int +1
									end
								end
								if int == table.length(item_has_augment.augments) then
									y.augments = item_has_augment.augments
									local_gear_table[#local_gear_table +1] = y
									sloted_items[k] = local_gear_table[#local_gear_table]
									no_match = false
									break
								end
							end
						end
					else
                        no_match = false
						local_gear_table[#local_gear_table+1] = y
						sloted_items[k] = local_gear_table[#local_gear_table]
					end
				end	
			end

			if no_match == true then

				local_gear_table[#local_gear_table+1] = parse_new_single_item(temp_item)
				sloted_items[k] = local_gear_table[#local_gear_table]
				no_match = false
			end			
		else
			local_gear_table[#local_gear_table+1] = {id = 0, en = '', category = '', delay = 0, haste = 0, dual_wield = 0, stp = 0, augments = '' }
			sloted_items[k] = local_gear_table[#local_gear_table]
		end
	end
	
	--log(table.length(local_gear_table) .. ' ' .. table.length(sloted_items))
	
	player.equipment = sloted_items
	
	return sloted_items
end

options_load()
			
windower.register_event('job change',function()
	player = windower.ffxi.get_player()
	--player.stats = get_packet_data_base_stats()
    initialize(text_box,settings)
end)

function incoming_chunk(id,data,modified,injected,blocked)
        
    if not injected and parse.i[id] then
		update_party()
        parse.i[id](data,blocked)
    end
end

function outgoing_chunk(id,original,data,injected,blocked)
    
    if not blocked and parse.o[id] then
        parse.o[id](data,injected)
    end
end

windower.register_event('incoming chunk',incoming_chunk)
windower.register_event('outgoing chunk',outgoing_chunk)

function update()
	local inform = {}
						
	if loged_out_bool == true then
		if text_box:visible() then
			text_box:hide()
		end
	end
	if loged_in_bool == true then
		loged_out_bool = false
		if timer:check() > 10 then
			options_load()
			loged_in_bool = false
			timer:stop()
			text_box:show()
		end
	elseif loged_in_bool == false and loged_out_bool == false then
		
		if manual_hide == true then
			text_box:hide()
		else
			if zoning_bool == true then
				text_box:hide()
			else
				text_box:show()
			end
		end
	
		local white = '(220,220,220)'
		local blue = '(150,150,235)'
		local red = '(255,0,0)'
		
		----------------------------------------------- TP calc Stuff ------------------------------------------
		
		if settings.player.show_tp_Stuff == true then 
		
			Gear_TP = get_tp_per_hit(check_equipped())
			
			inform.title = ' \\cs'..blue..'[\\cr\\cs'..white..'TP Calculator\\cr\\cs'..blue..'] \n\\cr'
			inform.tp_per__hit = ' \\cs'..blue..'[Tp/hit:\\cr\\cs'..white..Gear_TP.tp_per_hit_melee.. '\\cr\\cs'..blue..'] \n\\cr'
			if Gear_TP.tp_per_hit_range > 0 then
				inform.tp_per__hit_range = ' \\cs'..blue..'[R.Tp/hit:\\cr\\cs'..white..Gear_TP.tp_per_hit_range.. '\\cr\\cs'..blue..'] \n\\cr'
			else
				inform.tp_per__hit_range = ''
			end
			if player.main_job:upper() == 'SAM' then
				inform.zanshin = ' \\cs'..blue..'[Zanshin Tp/hit:\\cr\\cs'..white..Gear_TP.tp_per_hit_zanshin.. '\\cr\\cs'..blue..'] \n\\cr'
			else
				inform.zanshin = ('')
			end
			
			if WSTP > 0 then
				inform.tp_to_100 = ' \\cs'..blue..'[hits after WS:\\cr\\cs'..white..(math.ceil((10000 - (WSTP *10))/Gear_TP.tp_per_hit_melee)/10).. '\\cr\\cs'..blue..'] \n\\cr'
				inform.wstp = ' \\cs'..blue..'[tp for WS:\\cr\\cs'..white..WSTP.. '\\cr\\cs'..blue..'] \n\\cr'
				if Gear_TP.tp_per_hit_range > 0 then
					inform.Rtp_to_100 = ' \\cs'..blue..'[R.hits after WS:\\cr\\cs'..white..(math.ceil(10000/Gear_TP.tp_per_hit_range)/10).. '\\cr\\cs'..blue..'] \n\\cr'
				else
					inform.Rtp_to_100 = ''
				end
			else
				inform.tp_to_100 = (Gear_TP.tp_per_hit_melee > 0 and
										' \\cs'..blue..'[hits to WS:\\cr\\cs'..white..(math.ceil(10000/Gear_TP.tp_per_hit_melee)/10).. '\\cr\\cs'..blue..'] \n\\cr'
									or	
										' \\cs'..blue..'[hits to WS:\\cr\\cs'..white..'N/A'.. '\\cr\\cs'..blue..'] \n\\cr')
				inform.wstp = ('')
				if Gear_TP.tp_per_hit_range > 0 then
					inform.Rtp_to_100 = ' \\cs'..blue..'[R.hits to WS:\\cr\\cs'..white..(math.ceil(10000/Gear_TP.tp_per_hit_range)/10).. '\\cr\\cs'..blue..'] \n\\cr'
				else
					inform.Rtp_to_100 = ''
				end
			end
		else
			inform.title = ''
			inform.tp_per__hit = ''
			inform.tp_per__hit_range = ''
			inform.zanshin = ''
			inform.tp_to_100 = ''
			inform.wstp = ''
			inform.Rtp_to_100 = ''
		end
		
		----------------------------------------------------- Haste Stuff ------------------------------------------
		Gear_info = get_equip_stats(check_equipped())
		
		inform.title2 = ' \\cs'..blue..'[\\cr\\cs'..white..'Gear Info\\cr\\cs'..blue..'] \n\\cr'
		inform.stp = ' \\cs'..blue..'[STP:\\cr\\cs'..white..Gear_info.stp.. '\\cr\\cs'..blue..']\\cr'
		inform.dw = ' \\cs'..blue..'[DW:\\cr\\cs'..white..Gear_info.dual_wield.. '\\cr\\cs'..blue..'] \n\\cr'
		if Buffs_inform.STP > 0 then
			inform.bstp = ' \\cs'..blue..'[Buff STP:\\cr\\cs'..white..Buffs_inform.STP.. '\\cr\\cs'..blue..'] \n\\cr'
		else
			inform.bstp = ''
		end
		
		inform.ghaste = ( Gear_info.haste < 257 and
							' \\cs'..blue..'[G.Haste:\\cr\\cs'..red..Gear_info.haste.. '\\cr\\cs'..blue..'/256] \\cr'
						or Gear_info.haste > 256 and
							' \\cs'..blue..'[G.Haste:\\cr\\cs'..white..Gear_info.haste.. '\\cr\\cs'..blue..'/256] \\cr')
		
		if (Buffs_inform.magic_haste + manual_mhaste) > 0 then
			inform.mhaste = ( (Buffs_inform.magic_haste + manual_mhaste) < 449 and
							'\n \\cs'..blue..'[M.Haste:\\cr\\cs'..white..(Buffs_inform.magic_haste + manual_mhaste).. '\\cr\\cs'..blue..'/448] \\cr'
						or (Buffs_inform.magic_haste + manual_mhaste) > 448 and
							'\n \\cs'..blue..'[M.Haste:\\cr\\cs'..red..(Buffs_inform.magic_haste + manual_mhaste).. '\\cr\\cs'..blue..'/448] \\cr')
		else
			inform.mhaste = ''
		end
		if (Buffs_inform.ja_haste + manual_jahaste) > 0 then
			inform.jhaste = ( (Buffs_inform.ja_haste + manual_jahaste) < 257 and
							'\n \\cs'..blue..'[J.Haste:\\cr\\cs'..white..(Buffs_inform.ja_haste + manual_jahaste).. '\\cr\\cs'..blue..'/256] \\cr'
						or (Buffs_inform.ja_haste + manual_jahaste) > 256 and
							'\n \\cs'..blue..'[J.Haste:\\cr\\cs'..red..(Buffs_inform.ja_haste + manual_jahaste).. '\\cr\\cs'..blue..'/256] \\cr')
		else
			inform.jhaste = ''
		end
		
		------------------------------------------------ Total Haste --------------------------------------------------
		
		Total_haste = get_total_haste()
		
		if settings.player.show_total_haste == true then
			inform.thaste = '\n \\cs'..blue..'[T.Haste:\\cr\\cs'..white..Total_haste.. '\\cr\\cs'..blue..'/1024] \\cr'
		else
			inform.thaste = ('')
		end
		
		----------------------------------------------------------- DW stuff ----------------------------------------------
		
		DW_needed = dual_wield_needed()
		
		if player.equipment.sub.category == 'Weapon' then 
			if player.equipment.sub.damage > 0 then
				DW = true
				inform.dw_needed = ( (DW_needed + manual_dw_needed) >= 0 and
										' \\cs'..blue..'[DW Needed:\\cr\\cs'..white..(DW_needed + manual_dw_needed).. '\\cr\\cs'..blue..'] \n\\cr'
									or (DW_needed + manual_dw_needed) < 0  and
										' \\cs'..blue..'[DW Needed:\\cr\\cs'..red..(DW_needed + manual_dw_needed).. '\\cr\\cs'..blue..'] \n\\cr')
			else
				DW = false
				inform.dw_needed = ('')
			end
		else
			DW = false
			inform.dw_needed = ('')
		end
		
		if settings.player.update_gs == true then
			inform.ugs = '\n \\cs'..blue..'[\\cr\\cs'..white..'Updating GearSwap\\cr\\cs'..blue..'] \\cr'
		else
			inform.ugs = ('')
		end
		
		----------------------------------------------------------------- ACC Stuff ---------------------------------------------------
		
		if settings.player.show_acc_Stuff == true then
			Total_acc = get_player_acc(check_equipped())
			
			inform.T_acc = (Total_acc.sub > 0 and
							'\n \\cs'..blue..'[Acc:\\cr\\cs'..white..Total_acc.main..','..Total_acc.sub ..'\\cr\\cs'..blue..'] \\cr'
							or Total_acc.sub == 0 and
							'\n \\cs'..blue..'[Acc:\\cr\\cs'..white..Total_acc.main..'\\cr\\cs'..blue..'] \\cr' )
							
			inform.T_racc = ( Total_acc.range > 0 and Total_acc.ammo > 0 and (player.equipment.range.skill == 'Marksmanship' or player.equipment.range.skill == 'Archery') and
							'\n \\cs'..blue..'[RAcc:\\cr\\cs'..white..Total_acc.range..'\\cr\\cs'..blue..'] \\cr'
							or Total_acc.range == 0 and Total_acc.ammo > 0 and
							'\n \\cs'..blue..'[RAcc:\\cr\\cs'..white..Total_acc.ammo..'\\cr\\cs'..blue..'] \\cr'	
							or Total_acc.range > 0 and Total_acc.ammo == 0 and
							'\n \\cs'..blue..'[RAcc:\\cr\\cs'..white..Total_acc.range..'\\cr\\cs'..blue..'] \\cr'	
							or Total_acc.range == 0 and Total_acc.ammo == 0 and
							'')
		else
			inform.T_acc = ''
			inform.T_racc = ''
		end
		
		if old_inform ~= inform then
			text_box:update(inform)
			old_inform = inform
		end
		--log(DW_needed)
		if settings.player.update_gs == true then
			local new_dw = DW_needed + manual_dw_needed
			--if new_dw ~= old_DW_needed then  -- old_DW_needed ~= DW_needed and
				update_gs(DW, new_dw, Total_haste)
				old_DW_needed = new_dw
			--end
		end
	end
	--print('updating')
end


loop_count = 0
frame_count = 0
windower.register_event('prerender',function()
    if frame_count%15 == 0 then
        local temp_equip = player.equipment
        local temp_stats = player.stats
        local temp_skill = player.skill
		local temp_pos = player.position
        player = windower.ffxi.get_player()
        player.equipment = temp_equip
        player.stats = temp_stats
        player.skill = temp_skill
		player.position = temp_pos
		player.is_moving = check_player_movement(player)
		calculate_total_haste()
        update()
		loop_count = loop_count + 1
    end
    frame_count = frame_count + 1
end)

function update_gs(DW, Total_DW_needed, haste)
	if DW == true then
		windower.send_command('gs c gearinfo '..Total_DW_needed .. ' ' .. haste ..' '.. tostring(player.is_moving))
	elseif DW == false then
		windower.send_command('gs c gearinfo '.. tostring(DW).. ' ' .. haste ..' '.. tostring(player.is_moving))
	end
end

windower.register_event('unload', function()
	doloop = false
end)