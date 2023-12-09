if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 { 

//if instance_exists(o_namelevelLE) { exit }
if global.LEBuild != 1 {
	audio_play_sound(snd_hitboss,0,0)
	global.LES = 0
	}
global.LEBuild = 1
ITEMMENUSPAWNLE()
}