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
	if o_playerMU.multiplayerplayer = 1 {global.shootemupscore[0] += 1}
	if o_playerMU.multiplayerplayer = 2 {global.shootemupscore[1] += 1}
	if o_playerMU.multiplayerplayer = 3 {global.shootemupscore[2] += 1}
	if o_playerMU.multiplayerplayer = 4 {global.shootemupscore[3] += 1}
	break;
	case(2):
	if o_playerMU.multiplayerplayer = 1 {global.racescore[0] += 1}
	if o_playerMU.multiplayerplayer = 2 {global.racescore[1] += 1}
	if o_playerMU.multiplayerplayer = 3 {global.racescore[2] += 1}
	if o_playerMU.multiplayerplayer = 4 {global.racescore[3] += 1}
	break;
	}}}
}
