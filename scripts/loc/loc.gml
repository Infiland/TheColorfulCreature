///@description Loads a language section into a map
function loc_load_lang_file(_path, _section, _out_map) {
	if !file_exists(_path) return false;

	var file = file_text_open_read(_path);
	var current_section = "";
	while !file_text_eof(file) {
		var line = file_text_read_string(file);
		file_text_readln(file);
		var trimmed = string_trim(line);
		if (trimmed == "") continue;
		if (string_char_at(trimmed, 1) == "[" && string_char_at(trimmed, string_length(trimmed)) == "]") {
			current_section = string_copy(trimmed, 2, string_length(trimmed) - 2);
			continue;
		}
		if (current_section != _section) continue;

		var eq = string_pos("=", line);
		if (eq <= 0) continue;
		var key = string_trim(string_copy(line, 1, eq - 1));
		if (key == "") continue;
		var value = string_copy(line, eq + 1, string_length(line) - eq);
		ds_map_replace(_out_map, key, value);
	}
	file_text_close(file);
	return true;
}

///@description Returns the translated key
function loc(_key) {
	if argument_count != 1 return "";

	if !is_string(_key) _key = string(_key);
	if !instance_exists(o_localization) return _key;

	var translated = _key;
	if (ds_exists(o_localization.translator, ds_type_map) && ds_map_exists(o_localization.translator, _key)) {
		translated = o_localization.translator[? _key];
	}

	//Force string because it could be a number and so it could crash in the draw_text()
	return string(translated); 
}
