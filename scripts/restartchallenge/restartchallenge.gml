function restartchallenge(){
if global.challenges = 1 {
	var _def = scr_challenge_get_def(global.currentchallenge);
	if (!is_undefined(_def)) {
		if (_def.level_dir != "") {
			scr_challenge_prepare_custom_level(_def);
			room_goto(r_challengelevel);
		} else if (_def.room != "") {
			room_goto(asset_get_index(_def.room));
		}
		resetgeneral()
		audio_group_set_gain(Music,global.musicvolume,1000)
	}
}}
