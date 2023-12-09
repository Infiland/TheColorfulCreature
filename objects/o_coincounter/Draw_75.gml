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
if os_type != os_android {
draw_sprite_ext(s_coinhud,0,16+random_range(shake,-shake),653+random_range(shake,-shake),0.38,0.38,0,c_white,1)	
draw_text(64+random_range(-shake,shake),661+random_range(-shake,shake),string_hash_to_newline(string(global.special)))
} else {
if instance_exists(o_buttonskipandroid) {
draw_sprite_ext(s_coinhud,0,o_buttonskipandroid.x+random_range(shake,-shake)-64,o_buttonskipandroid.y-129+random_range(shake,-shake),0.38,0.38,0,c_white,1)	
draw_text(o_buttonskipandroid.x-16+random_range(-shake,shake),o_buttonskipandroid.y-121+random_range(-shake,shake),string_hash_to_newline(string(global.special)))
}}}

if key_skip {
if global.special >= reqcoin {
if skip != "It's no use.\nCoins are meaningless." {
if skip != "You can't skip\nthis level" {
draw_set_color(c_white)
if os_type != os_android {
draw_rectangle(100,688,100+(timer*100),693,false)
} else {
	if instance_exists(o_buttonskipandroid) {
draw_rectangle(o_buttonskipandroid.x,o_buttonskipandroid.y-10,o_buttonskipandroid.x+(timer*256),o_buttonskipandroid.y-5,false)	
}}}}
} else { 
	if os_type = os_android {
		if instance_exists(o_buttonskipandroid) {
	draw_text(o_buttonskipandroid.x-64,o_buttonskipandroid.y-94,"Can't Skip")
		}
	}}}

if global.special >= reqcoin {
draw_set_font(fnt_skip)
color = c_white
if skip = "You can't skip\nthis level" { color = c_red}
if room != r_tale {
if os_type != os_android {
draw_text_outline(100,658,skip,color,c_black)
}}}
draw_set_color(c_white)


draw_set_alpha(1)