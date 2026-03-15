var _def = undefined
if (variable_global_exists("currentchallenge")) _def = scr_challenge_get_def(global.currentchallenge)
if (!is_undefined(_def)) {
	text = scr_challenge_get_title(_def)
} else {
	text = loc("BLIND_CHALLENGE")
}
