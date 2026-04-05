function scr_troopvoiceline() {
	if global.troopvoicelinesettings != 1 { exit; }
	if !instance_exists(o_player) { exit; }

	var _idle_sounds = [snd_troopidle1, snd_troopidle2, snd_troopidle3, snd_troopidle4,
	                    snd_troopidle5, snd_troopidle6, snd_troopidle7];
	var _attack_sounds = [snd_troopattack1, snd_troopattack2, snd_troopattack3, snd_troopattack4,
	                      snd_troopattack5, snd_troopattack6, snd_troopattack7, snd_troopattack8];

	var _gain = global.soundvolume - distance_to_object(o_player) / 300;

	// Set gain on all troop sounds
	for (var i = 0; i < array_length(_idle_sounds); i++) {
		audio_sound_gain(_idle_sounds[i], _gain, 1);
	}
	for (var i = 0; i < array_length(_attack_sounds); i++) {
		audio_sound_gain(_attack_sounds[i], _gain, 1);
	}

	// Pick and play random sound based on state
	var _sounds = (state == 1) ? _attack_sounds : _idle_sounds;
	randomize();
	var _snd = _sounds[irandom(array_length(_sounds) - 1)];
	audio_play_sound_at(_snd, o_player.x - x, o_player.y - y, 0, 100, 100, 100, 0, 0);

	troopsound = irandom_range(200 * (60 / global.maxfps), 500 * (60 / global.maxfps));
}
