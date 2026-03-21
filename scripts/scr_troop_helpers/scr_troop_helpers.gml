/// scr_troop_on_ground() — is the troop standing on a solid block?
function scr_troop_on_ground() {
	return place_meeting(x, y+1, o_anyblock);
}

/// scr_troop_head_clear() — is there space above the troop to jump?
function scr_troop_head_clear() {
	return !place_meeting(x, y-32, o_anyblock);
}

/// scr_troop_wall_ahead(dx) — is there a solid wall at horizontal offset dx?
function scr_troop_wall_ahead(dx) {
	return place_meeting(x + dx, y, o_anyblock);
}

/// scr_troop_ledge_ahead(dx) — is there a block to climb over at offset dx?
function scr_troop_ledge_ahead(dx) {
	return place_meeting(x + dx, y - 1, o_anyblock);
}

/// scr_troop_jump() — enemy jump with sound handling
function scr_troop_jump() {
	if !place_meeting(x, y-32, o_anyblock) {
		vsp = -10.5
		onground = 0
		audio_sound_pitch(snd_enemyjump, random_range(0.6, 0.8))
		if instance_exists(o_player) {
			if distance_to_object(o_player) > 250 {
				audio_sound_gain(snd_enemyjump, 0, 1)
			} else {
				audio_sound_gain(snd_enemyjump, global.soundvolume, 1)
			}
			if distance_to_object(o_player) < 250 {
				if !audio_is_playing(snd_enemyjump) {
					audio_play_sound(snd_enemyjump, 5, 0)
				}
			}
		}
	}
}
