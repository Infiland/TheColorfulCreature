if instance_exists(o_settingspausemenu) { exit }
depth = -10000
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_font(global.cool2font);

if room = r_stats {

	}
if room = r_localmultiplayermenu { 
	draw_set_font(global.gamemodefont);
	if global.multiplayerplayers = 1 {
	draw_text(180,100,string_hash_to_newline(string(loc(47))+":"))
	} else { 
		if global.multiplayerplayers >= global.multiplayerplayerconfigchoose {
		draw_text(310,100,string_hash_to_newline(string(loc(51))+" "+ string(global.multiplayerplayerconfigchoose))) } else {
		draw_text(250,100,loc(55))	
		}
	}
	}	
depth = -10000
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_font(global.cool2font);

if room = r_localmultiplayermenu { 
	draw_set_font(global.gamemodefont);
	if global.multiplayerplayers = 1 {
	draw_text(180,100,string_hash_to_newline(string(loc(47))+":"))
	} else { 
		if global.multiplayerplayers >= global.multiplayerplayerconfigchoose {
		draw_text(310,100,string_hash_to_newline(string(loc(51))+" "+ string(global.multiplayerplayerconfigchoose))) } else {
		draw_text(250,100,loc(55))	
		}
	}
	}

if room = r_settings { 
draw_set_font(global.cool2font)
if global.choosesettings = 1 {
	draw_text(830,160,"Graphics Presets")
}
	}

color = c_white

/*switch(room) {
case(r_lvl9): if global.special = 9 {color = c_yellow } break;
case(r_boss1prepare): color = c_yellow break;
case(r_boss2prepare): color = c_yellow break;
case(r_boss3prepare): color = c_yellow break;
case(r_taleroom): color = c_yellow break;
case(r_easteregg1): color = c_yellow break;
case(r_speedlvl5): color = c_red break;
case(r_cslvl5): color = c_yellow break;
case(r_cslvl6): color = c_yellow break;
}*/

if room != r_leveleditor {
if instance_exists(o_player) {
draw_text_scribble(16,0,print)
}}

if room = r_customlevelworkshop {
	draw_text_scribble(16,0,print)
}