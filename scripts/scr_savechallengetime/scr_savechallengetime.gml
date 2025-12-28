function scr_savechallengetime() {
	if global.cheats = 0 {
		if (!variable_global_exists("challenge_defs")) return;
		if (!ds_exists(global.challenge_times, ds_type_map)) global.challenge_times = ds_map_create();
		
		var directory = directory_set("//Save Files/")
		
		if (file_exists(directory + "ChallengeTime.sav")) file_delete(directory + "ChallengeTime.sav");
		ini_open(directory + "ChallengeTime.sav");
		var _keys = scr_map_keys(global.challenge_defs);
		for (var i = 0; i < ds_list_size(_keys); i++) {
			var _key = _keys[| i];
			var _def = global.challenge_defs[? _key];
			var _value = scr_challenge_get_time(_def.id);
			ini_write_real("Challenges", _def.save_key, _value);
		}
		ds_list_destroy(_keys);
		ini_close();
	}
}
