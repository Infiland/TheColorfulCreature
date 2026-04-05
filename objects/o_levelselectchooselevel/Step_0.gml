// Lock state check
if (is_challenge) {
	var _def = scr_challenge_get_def(challenge_id);
	if (!is_undefined(_def)) {
		locked = (!scr_challenge_is_unlocked(_def)) ? 1 : 0;
	}
} else {
	if (global.worldProgression >= level) {
		locked = 0;
	} else {
		locked = 1;
	}
}