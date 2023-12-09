if global.playermove = 0 {playerbullet = 1 } //Center
if global.playermove = 1 {playerbullet = 1 } //Right
if global.playermove = -1 {playerbullet = 2 } //Left
audio_play_sound(snd_smallexplosion,0,0)
hp = 1
inwater = 1
depth = 1

if playerbullet = 1 { direction = 0 }
if playerbullet = 2 { direction = 180 }
if instance_exists(o_player) {
if o_player.zerogrv = 1 {
	direction = o_player.direction
}}