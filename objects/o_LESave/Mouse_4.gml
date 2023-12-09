if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if page != global.LEbuttonpage { exit }

if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 {
if instance_exists(o_namelevelLE) { exit }
if global.levelname != "" {
scr_saveleveleditor()
global.writingmode = 0
audio_play_sound(snd_hitboss,0,0)
instance_destroy(o_savedandloaded)
box = instance_create(x,y,o_savedandloaded)
with box { image_index = 0 }
if !steam_get_achievement("MAKE_LEVEL") { //Make Level
steam_set_achievement("MAKE_LEVEL") }
if !steam_get_achievement("SUPER_DETAILED_LEVEL") { //Super Detailed
if (instance_number(o_hazard) + instance_number(o_allliquids) + instance_number(o_anyblock) - instance_number(o_lava)) > 333 {
steam_set_achievement("SUPER_DETAILED_LEVEL") }}
} else {
instance_destroy(o_savedandloaded)
box = instance_create(x,y,o_savedandloaded)
with box { image_index = 3 }	
}
}