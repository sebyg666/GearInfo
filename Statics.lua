

player = windower.ffxi.get_player()
player.equipment = T{}
player.stats = T{}
player.stats = {STR = 0, DEX = 0, VIT = 0, AGI = 0, INT = 0, MND = 0, CHR = 0}
player.skill = player.skills
player.is_moving = false
player.position = T{} 
player.position = {x = 0, y = 0, x = 0} 
buff = 0
full_gear_table_from_file = T{}
Buffs_inform = {magic_haste = 0, ja_haste = 0, STP = 0}
Gear_info = T{}
member_table = T{}
seen_0x063_type9 = false
delay_0x063_v9 = false
debug_mode = false

_ExtraData = {
        player = {buff_details = {}},
        pet = {},
        world = {in_mog_house = false,conquest=false},
    }

old_inform = {}
manual_stp = 0
manual_dw = 0
manual_ghaste = 0
manual_mhaste = 0
manual_jahaste = 0
manual_dw_needed = 0
manual_bard_duration_bonus = 7
manual_hide = false
WSTP = 0
loged_in_bool = false
loged_out_bool = false
update_gs = true
show_total_haste = true
show_tp_Stuff = true
show_acc_Stuff = true
old_DW_needed = 0
DW = false
dancer_main = false






