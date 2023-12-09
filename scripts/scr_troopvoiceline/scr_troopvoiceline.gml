function scr_troopvoiceline() {
	if global.troopvoicelinesettings = 1 {
	rng = 0
	randomize();
	if !instance_exists(o_player) { exit; }
	if !audio_is_playing(snd_troopidle1) or !audio_is_playing(snd_troopidle2) or !audio_is_playing(snd_troopattack3) or !audio_is_playing(snd_troopattack2) or !audio_is_playing(snd_troopattack1) {
	if state = 0 or state = 2{
	rng = irandom_range(0,6)
	audio_sound_gain(snd_troopidle1,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopidle2,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopidle3,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopidle4,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopidle5,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopidle6,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopidle7,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack1,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack2,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack3,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack4,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack5,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack6,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack7,global.soundvolume - distance_to_object(o_player) / 300,1)
	audio_sound_gain(snd_troopattack8,global.soundvolume - distance_to_object(o_player) / 300,1)
	if rng = 0 {audio_play_sound_at(snd_troopidle1,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 1 {audio_play_sound_at(snd_troopidle2,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 2 {audio_play_sound_at(snd_troopidle3,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 3 {audio_play_sound_at(snd_troopidle4,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 4 {audio_play_sound_at(snd_troopidle5,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 5 {audio_play_sound_at(snd_troopidle6,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 6 {audio_play_sound_at(snd_troopidle7,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	}
	if state = 1 {
	rng = irandom_range(0,7)
	if rng = 0 {audio_play_sound_at(snd_troopattack1,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 1 {audio_play_sound_at(snd_troopattack2,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 2 {audio_play_sound_at(snd_troopattack3,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 3 {audio_play_sound_at(snd_troopattack4,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 4 {audio_play_sound_at(snd_troopattack5,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 5 {audio_play_sound_at(snd_troopattack6,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 6 {audio_play_sound_at(snd_troopattack7,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	if rng = 7 {audio_play_sound_at(snd_troopattack8,o_player.x-x,o_player.y-y,0,100,100,100,0,0) }
	}
	}
	troopsound = irandom_range(200* (60 / global.maxfps),500* (60 / global.maxfps))
	}


}
