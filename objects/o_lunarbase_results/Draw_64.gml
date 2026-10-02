draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_clear(make_colour_rgb(12, 15, 24));

// Lunar horizon: existing game textures and simple geometry, with no external
// artwork or dependency on an online leaderboard widget.
draw_set_colour(make_colour_rgb(32, 39, 51));
draw_circle(867, 98, 72, false);
draw_set_colour(make_colour_rgb(23, 29, 41));
draw_circle(842, 81, 14, false);
draw_circle(892, 114, 22, false);
draw_circle(869, 56, 9, false);
for (var _tile = 0; _tile < 32; ++_tile) {
    draw_sprite_ext(s_whiteblockbackground, 0, _tile * 32, 736, 1, 1, 0, c_white, 0.7);
}

draw_set_font(global.completefont);
draw_set_colour(c_white);
draw_text(112, 70, loc("LUNAR_BASE_TITLE"));
draw_set_font(global.cool2font);
draw_set_colour(make_colour_rgb(166, 180, 199));
draw_text(114, 131, result_eligible ? loc("LUNAR_BASE_COMPLETE") : loc("LUNAR_BASE_PRACTICE_COMPLETE"));

draw_set_colour(make_colour_rgb(24, 30, 42));
draw_roundrect(112, 180, 912, 576, false);
draw_set_colour(make_colour_rgb(53, 63, 79));
draw_roundrect(112, 180, 912, 576, true);
draw_line(592, 212, 592, 458);
draw_line(144, 470, 880, 470);

draw_set_font(global.cool2font);
draw_set_colour(make_colour_rgb(166, 180, 199));
draw_text(150, 222, loc("TIME"));
draw_text(150, 286, loc("DEATHS"));
draw_text(150, 362, loc("DIAMOND_MEDAL"));
draw_set_colour(c_white);
draw_set_font(global.completefont);
draw_text(330, 211, scr_lunarbase_time(result_time));
draw_text(330, 277, string(result_deaths));
draw_set_font(global.cool2font);
draw_set_colour(c_aqua);
draw_text(330, 362, scr_lunarbase_time(result_target));

draw_set_halign(fa_center);
if (result_medal >= 0) draw_sprite_ext(s_medals, result_medal, 520, 421, 0.12, 0.12, 0, c_white, 1);
draw_sprite_ext(s_toilettoiletoutfit, 0, 742, 280, 3, 3, 0, c_white, 1);
draw_sprite_ext(s_toiletplayerskin, 0, 742, 280, 3, 3, 0, c_red, 1);
draw_set_colour(result_skin_unlocked ? c_lime : c_white);
draw_text_ext(742, 353, result_skin_unlocked ? loc("LUNAR_BASE_SKIN_UNLOCKED") : loc("LUNAR_BASE_REWARD"), 24, 280);
draw_set_colour(make_colour_rgb(166, 180, 199));
draw_text_ext(742, 405, result_eligible ? loc("LUNAR_BASE_REWARD_READY") : loc("LUNAR_BASE_PRACTICE_NOTE"), 20, 270);

draw_set_halign(fa_left);
draw_set_colour(make_colour_rgb(166, 180, 199));
draw_text(150, 490, loc("BEST_TIME"));
draw_text(545, 490, loc("LEAST_DEATHS"));
draw_set_colour(c_white);
draw_text(330, 490, scr_lunarbase_time(result_best_time));
draw_text(766, 490, result_best_deaths >= 999999 ? "--" : string(result_best_deaths));
draw_set_colour(make_colour_rgb(130, 144, 163));
draw_text(150, 535, loc("LUNAR_BASE_LOCAL_RECORDS"));

var _lefts = [192, 542];
var _labels = [loc("RESTART_CHALLENGE"), loc("CHALLENGES")];
for (var _i = 0; _i < 2; ++_i) {
    var _selected = result_focus == _i || result_hover == _i;
    draw_set_colour(_selected ? make_colour_rgb(69, 81, 103) : make_colour_rgb(27, 35, 48));
    draw_roundrect(_lefts[_i], 622, _lefts[_i] + 290, 690, false);
    draw_set_colour(_selected ? c_white : make_colour_rgb(84, 98, 120));
    draw_roundrect(_lefts[_i], 622, _lefts[_i] + 290, 690, true);
    draw_set_colour(c_white);
    draw_set_halign(fa_center);
    draw_text(_lefts[_i] + 145, 646, _labels[_i]);
}
draw_set_halign(fa_left);
draw_set_colour(c_white);
draw_set_alpha(1);
