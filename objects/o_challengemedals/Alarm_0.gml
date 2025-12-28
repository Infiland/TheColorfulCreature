image_alpha = 1
var _def = scr_challenge_get_def(challenge);
if (!is_undefined(_def)) {
	medalcheck(scr_challenge_get_time(_def.id), _def.diamond_time, deaths);
}

if deaths = 0 {
	global.perfectscorecount += 1
	if !steam_get_achievement("PERFECT_CHALLENGE") { steam_set_achievement("PERFECT_CHALLENGE") }
	if global.perfectscorecount > 4 {
		if !steam_get_achievement("THE_ANTI_DEATH") { steam_set_achievement("THE_ANTI_DEATH") }
	}}
