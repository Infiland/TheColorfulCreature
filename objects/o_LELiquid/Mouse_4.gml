if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 { 

//if instance_exists(o_namelevelLE) { exit }
if global.LEBuild != 3 {
	audio_play_sound(snd_hitboss,0,0)
	global.LES = 0
	}
global.LEBuild = 3
ITEMMENUSPAWNLE()
//if !instance_exists(o_waterleveleditorline) {instance_create(x,y,o_waterleveleditorline)}

}