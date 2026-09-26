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
draw_sprite_ext(s_coinhud,0,16+random_range(shake,-shake),653+random_range(shake,-shake),0.38,0.38,0,c_white,1)
draw_text(64+random_range(-shake,shake),661+random_range(-shake,shake),string_hash_to_newline(string(global.special)))
} else {
if instance_exists(o_buttonskipandroid) {
var _bounds = platform_touch_bounds();
var _hudx = clamp(o_buttonskipandroid.gui_x - 64, _bounds[0] + 12, _bounds[2] - 60 - string_width(string(global.special)));
var _hudy = max(_bounds[1] + 12, o_buttonskipandroid.gui_y - 129);
draw_sprite_ext(s_coinhud,0,_hudx+random_range(shake,-shake),_hudy+random_range(shake,-shake),0.38,0.38,0,c_white,1)
draw_text(_hudx+48+random_range(-shake,shake),_hudy+8+random_range(-shake,shake),string_hash_to_newline(string(global.special)))
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
var _bar_x = _button.gui_x - _bar_width / 2;
var _bar_y = _button.gui_y + _button.sprite_height / 2 - 18;
draw_set_color(c_black);
draw_rectangle(_bar_x - 2, _bar_y - 2, _bar_x + _bar_width + 2, _bar_y + 8, false);
draw_set_color(c_white);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_width * platform_skip_progress(timer), _bar_y + 6, false);
}}}}
} else {
	if platform_mobile() {
		if instance_exists(o_buttonskipandroid) {
	var _bounds = platform_touch_bounds();
	var _textx = clamp(o_buttonskipandroid.gui_x - string_width("Can't Skip") / 2, _bounds[0] + 12, _bounds[2] - string_width("Can't Skip") - 12);
	draw_text(_textx,max(_bounds[1] + 60, o_buttonskipandroid.gui_y-94),"Can't Skip")
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
