if (global.currentchallenge != 19) {
    scr_lunarbase_return();
    exit;
}
result_time = global.time;
result_deaths = global.deaths;
result_eligible = scr_challenge_run_eligible(19);
result_skin_was_owned = global.skin[49] >= 1;
result_target = 130;
level_music_release();
scr_challenge_win_setup();
// Reuse the challenge-definition record writer and its eligibility guard.
// Lunar's empty service IDs cause no challenge-specific score/achievement calls.
event_inherited();
result_best_time = scr_challenge_get_time(19);
result_best_deaths = scr_challenge_get_deaths(19);
result_skin_unlocked = result_eligible && !result_skin_was_owned && global.skin[49] >= 1;
result_medal = scr_lunarbase_medal(result_time, result_deaths, result_target);
result_focus = 0;
result_hover = -1;
result_input_delay = 12;
window_set_cursor(cr_default);
