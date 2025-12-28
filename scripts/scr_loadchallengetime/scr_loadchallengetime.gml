function scr_loadchallengetime() {
	if global.cheats = 0 {
		if (!variable_global_exists("challenge_defs")) return;
		if (!ds_exists(global.challenge_times, ds_type_map)) global.challenge_times = ds_map_create();
		
		var directory = directory_set("//Save Files/")
		
		if (file_exists(directory + "ChallengeTime.sav")) {
			ini_open(directory + "ChallengeTime.sav");
			var _keys = scr_map_keys(global.challenge_defs);
			for (var i = 0; i < ds_list_size(_keys); i++) {
				var _key = _keys[| i];
				var _def = global.challenge_defs[? _key];
				var _value = ini_read_real("Challenges", _def.save_key, 999999);
				ds_map_replace(global.challenge_times, _key, _value);
				if (_def.time_var != "") {
					variable_global_set(_def.time_var, _value);
				}
			}
			ds_list_destroy(_keys);
			ini_close();
		}
	}
}
