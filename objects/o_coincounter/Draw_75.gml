if instance_exists(o_settingspausemenu) { exit }

image_alpha = 1
if instance_exists(o_player) {
if o_player.x < camera_get_view_x(view_camera[0])+64 + string_width(string(global.special)) {
if o_player.y > camera_get_view_y(view_camera[0])+640 {
image_alpha = 0.2
}}}
draw_set_alpha(image_alpha)

depth = -10000
if room != r_tale {
shake = 0
draw_set_color(c_white)
}

if !instance_exists(o_specialcoin) {
if global.pause = 0{
	shake = 1.5
draw_set_color(c_yellow)
}}

draw_set_font(global.deathfont)
if room != r_tale {
if !platform_mobile() {
draw_sprite_ext(s_coinhud,0,16+timing_visual_random_range(shake,-shake),653+timing_visual_random_range(shake,-shake),0.38,0.38,0,c_white,1)
draw_text(64+timing_visual_random_range(-shake,shake),661+timing_visual_random_range(-shake,shake),string_hash_to_newline(string(global.special)))
} else {
if instance_exists(o_buttonskipandroid) {
var _hud = platform_touch_coin_hud(o_buttonskipandroid, string_width(string(global.special)));
var _hud_scale = _hud[2];
draw_sprite_ext(s_coinhud,0,_hud[0]+timing_visual_random_range(shake,-shake)*_hud_scale,_hud[1]+timing_visual_random_range(shake,-shake)*_hud_scale,0.38*_hud_scale,0.38*_hud_scale,0,c_white,1)
draw_text_transformed(_hud[0]+(48+timing_visual_random_range(-shake,shake))*_hud_scale,_hud[1]+(8+timing_visual_random_range(-shake,shake))*_hud_scale,string_hash_to_newline(string(global.special)),_hud_scale,_hud_scale,0)
}}}

if key_skip {
if global.special >= reqcoin {
if skip != "It's no use.\nCoins are meaningless." {
if skip != "You can't skip\nthis level" {
draw_set_color(c_white)
if !platform_mobile() {
draw_rectangle(100,688,100+(timer*100),693,false)
} else {
	if instance_exists(o_buttonskipandroid) {
var _button = o_buttonskipandroid;
var _bar_width = _button.sprite_width - 24;
var _bar = platform_touch_to_gui(_button.gui_x - _bar_width / 2, _button.gui_y + _button.sprite_height / 2 - 18);
var _bar_x = _bar[0], _bar_y = _bar[1], _bar_scale = _bar[2];
_bar_width *= _bar_scale;
draw_set_color(c_black);
draw_rectangle(_bar_x - 2*_bar_scale, _bar_y - 2*_bar_scale, _bar_x + _bar_width + 2*_bar_scale, _bar_y + 8*_bar_scale, false);
draw_set_color(c_white);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width * platform_skip_progress(timer), _bar_y + 6*_bar_scale, false);
}}}}
} else {
	if platform_mobile() {
		if instance_exists(o_buttonskipandroid) {
	var _bounds = platform_touch_bounds();
	var _text_width = string_width("Can't Skip");
	var _text_fit = min(1, TCC_TOUCH_HUD_WIDTH / max(1, _text_width));
	_text_width *= _text_fit;
	var _textx = clamp(o_buttonskipandroid.gui_x - _text_width / 2, _bounds[0] + 12, _bounds[2] - _text_width - 12);
	var _feedback = platform_touch_to_gui(_textx, max(_bounds[1] + 60, o_buttonskipandroid.gui_y - o_buttonskipandroid.sprite_height / 2 - 46));
	var _feedback_scale = _feedback[2] * _text_fit;
	draw_text_transformed(_feedback[0],_feedback[1],"Can't Skip",_feedback_scale,_feedback_scale,0)
		}
	}}}

if global.special >= reqcoin {
draw_set_font(fnt_skip)
color = c_white
if skip = "You can't skip\nthis level" { color = c_red}
if room != r_tale {
if !platform_mobile() {
draw_text_outline(100,658,skip,color,c_black)
}}}
draw_set_color(c_white)


draw_set_alpha(1)
