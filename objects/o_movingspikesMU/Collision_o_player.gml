instance_destroy()
if instance_exists(o_playerMU) {
if multiplayerplayer = 1 {
	global.gunammopMU[0] += 16
	if !instance_exists(o_gunequippedMU) {
audio_sound_gain(snd_gunvoice,global.soundvolume,1)
audio_play_sound(snd_gunvoice,10,0)
player1 = instance_create(x,y,o_gunequippedMU)
with player1 { followplayer = 1}
	}}
if multiplayerplayer = 2 { global.gunammoMU[1] += 16
	if !instance_exists(o_gunequippedMU) {
audio_sound_gain(snd_gunvoice,global.soundvolume,1)
audio_play_sound(snd_gunvoice,10,0)
player2 = instance_create(x,y,o_gunequippedMU)
with player2 { followplayer = 2}
	}}
audio_play_sound(snd_reload,0,0)
}