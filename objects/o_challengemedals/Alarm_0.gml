image_alpha = 1
var _def = scr_challenge_get_def(challenge);
if (!is_undefined(_def)) {
	medalcheck(scr_challenge_get_time(_def.id), _def.diamond_time, deaths);
}

if deaths = 0 {
	global.perfectscorecount += 1
	if !achievement_earned("PERFECT_CHALLENGE") { achievement_award("PERFECT_CHALLENGE") }
	if global.perfectscorecount > 4 {
		if !achievement_earned("THE_ANTI_DEATH") { achievement_award("THE_ANTI_DEATH") }
	}}
