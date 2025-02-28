///@description Returns the translated key
function loc(_key) {
	if argument_count != 1 return;

	var translated  = _key;

	//if is string return as is
	if is_string(_key) return _key; 

	var not_defined = is_undefined(o_localization.translator[| _key]);
	if !(not_defined) translated = o_localization.translator[| _key];

	if (translated == 0 || not_defined) translated = _key; 

	//Force string because it could be a number and so it could crash in the draw_text()
	return string(translated); 
}