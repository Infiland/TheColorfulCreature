/// @description Click to start
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit;
}

if locked = 0 {
window_set_cursor(cr_default)
global.levelselect = 1
global.special = 0
global.hatmerchantdiscount = 1.3333333333333
global.pickup = 0

if (is_challenge && challenge_id >= 0) {
	// Set up challenge globals so the game knows we're in a challenge
	global.challenges = 1
	global.currentchallenge = challenge_id
	var _def = scr_challenge_get_def(challenge_id);
	if (!is_undefined(_def)) {
		global.DiamondMedalTimeChallenge = _def.diamond_time
	}
	global.workshop = 0
	global.challenge_custom = false
	global.challenge_level_dir = ""
	global.challenge_level_index = 0
	global.challenge_room_index = 0
} else {
	// Reset challenge state when playing a non-challenge level
	global.challenges = 0
	global.workshop = 0
}

room_goto(roomselect)
loadhud()
if (levelmusic != -1 && !audio_is_playing(levelmusic)) {
	audio_play_sound(levelmusic, 0, 1)
}
}