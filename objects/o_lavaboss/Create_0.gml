var_sprite_width = sprite_get_width(s_lava);
var_sprite_height = sprite_get_height(s_lava);
depth = -4000

speedup = 0
hp = 0;
maxhp = 3;

if global.berserk = 1 {
global.boss4 = 1
}

if global.boss4 = 1 { 
	instance_destroy()
}

healthbar = instance_create_depth(0, 0, -1000, o_healthbar);
healthbar.target = id;
healthbar.bar_segments = 3;
healthbar.bar_x = 30;
healthbar.bar_y = 30;

healthbar.custom_colors = true;
healthbar.color_high = make_color_rgb(255, 100, 0);
healthbar.color_med = make_color_rgb(255, 50, 0);
healthbar.color_low = make_color_rgb(200, 0, 0);