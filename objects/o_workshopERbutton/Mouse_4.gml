if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if !global.steam_api { exit }

if room = r_endlessrunmenu {
global.endlessrunmode = 4
global.endless = 1
global.workshop = 1
audio_stop_all()
instance_create(x,y,o_levelcounter)
loadhud()
global.hardmodelives = 10
global.time = 0
global.deaths = 0
global.endlesslevel = 0
global.endlessmusicchange = 0
global.endless1upchange = 10
workshopER_start()
}
window_set_cursor(cr_default)
