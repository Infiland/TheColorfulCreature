if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if page != global.LEbuttonpage { exit }
if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 {

if instance_exists(o_namelevelLE) { exit }
audio_play_sound(snd_hitboss,0,0)
if !instance_exists(o_fog) { 
	instance_create(x,y,o_fog)
} else {
instance_destroy(o_fog)}

}