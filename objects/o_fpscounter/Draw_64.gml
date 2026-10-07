depth = -10000;
// Count generated GUI frames over real elapsed time, including skipped frames.
var _now = get_timer();
fps_count_frames += 1;
var _elapsed = _now - fps_count_started_at;
if (_elapsed >= 250000) {
    fpsvariable = fps_count_frames * 1000000 / _elapsed;
    fps_count_frames = 0;
    fps_count_started_at = _now;
}
// Mobile menus reserve this corner for Return; keep the optional counter in play.
if (platform_mobile() && (global.pause != 0 || instance_exists(o_settingspausemenu)
    || (!instance_exists(o_player) && !instance_exists(o_playerMU)))) exit;
if (global.fpssettings == 2) { y2 = lerp(y2,140,timing_ui_draw_lerp_weight(0.5)); } else { y2 = lerp(y2,120,timing_ui_draw_lerp_weight(0.5)); }
if (room != r_tale) {
    draw_set_font(global.coolfont);
    var _label = "FPS: " + string(round(fpsvariable));
    var _cap = "(" + string(global.renderfps) + " cap)";
    var _right = 896 + string_width(_label) + 4;
    if (global.fpssettings == 2) _right = max(_right, 920 + string_width(_cap) + 4);
    x2 = lerp(x2, _right, timing_ui_draw_lerp_weight(0.3));
    if (fpsvariable < 2400) draw_set_color(c_blue);
    if (fpsvariable < 960) draw_set_color(c_green);
    if (fpsvariable < 144) draw_set_color(c_yellow);
    if (fpsvariable < 60) draw_set_color(c_red);
    if (fpsvariable > 2399) draw_set_color(c_purple);
    draw_set_alpha(0.6);
    draw_rectangle_color(893,96,x2,y2,c_black,c_black,c_black,c_black,false);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_text(896,96,string_hash_to_newline(_label));
    if (global.fpssettings == 2) draw_text(920,118,_cap);
    draw_set_color(c_white);
}
if (debug_mode == true) show_debug_overlay(true);
