function deathMU() {
	global.playersleft -= 1
	instance_destroy()
	instance_create(x,y,o_playerdeadLE)
	audio_sound_gain(snd_dead,global.soundvolume,1)
	audio_play_sound(snd_dead,5,0);
	if global.playersleft = 1 {
	if instance_exists(o_playerMU) {
	switch(global.MinigameMU) {
	case(1):
	global.shootemupscore[o_playerMU.multiplayerplayer-1] += 1
	if global.shootemupscore[o_playerMU.multiplayerplayer-1] >= 10 {
	if !steam_get_achievement("BOOTLEG_BR") { steam_set_achievement("BOOTLEG_BR") }
	}
	break;
	case(2):
	global.racescore[o_playerMU.multiplayerplayer-1] += 1
	if !steam_get_achievement("RACES_MULTI") { steam_set_achievement("RACES_MULTI") }
	break;
	}}}
}
