function restartchallenge(){
if global.challenges = 1 {
	var _def = scr_challenge_get_def(global.currentchallenge);
		if (!is_undefined(_def)) {
			if (array_length(_def.level_dirs) > 0) {
				var _idx = 0;
				if (variable_global_exists("challenge_level_index")) _idx = global.challenge_level_index;
				if (_idx < 0 || _idx >= array_length(_def.level_dirs)) _idx = 0;
				scr_challenge_prepare_custom_level(_def, _def.level_dirs[_idx]);
				room_goto(r_challengelevel);
			} else if (array_length(_def.rooms) > 0) {
				var _idx = 0;
				if (variable_global_exists("challenge_room_index")) _idx = global.challenge_room_index;
				if (_idx < 0 || _idx >= array_length(_def.rooms)) _idx = 0;
				var _room_name = _def.rooms[_idx];
				if (_room_name == "") {
					for (var i = 0; i < array_length(_def.rooms); i++) {
						if (_def.rooms[i] != "") {
							_room_name = _def.rooms[i];
							global.challenge_room_index = i;
							break;
						}
					}
				}
				if (_room_name != "") {
					room_goto(asset_get_index(_room_name));
				}
			} else if (_def.room != "") {
				room_goto(asset_get_index(_def.room));
			}
			resetgeneral()
			audio_group_set_gain(Music,global.musicvolume,1000)
		}
}}
