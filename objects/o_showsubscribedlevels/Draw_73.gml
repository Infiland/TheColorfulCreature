draw_set_color(c_white)
draw_set_alpha(0.5)
draw_rectangle_color(0,0,1024,768,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_font(global.deathfont)
numSub = steam_ugc_num_subscribed_items();
draw_text(16,700,"Current Number of\nDownloaded Maps: " + string(numSub))

if mouse_wheel_up() {
global.customlevelsscroll -= 60
}
if mouse_wheel_down() {
global.customlevelsscroll += 60
}

if global.customlevelsscroll < 0 {
global.customlevelsscroll = 0	
}
if global.customlevelsscroll > global.customlevelsscrollmax {
global.customlevelsscroll = global.customlevelsscrollmax	
}

/*
steam_list = ds_list_create();
steam_ugc_get_subscribed_items(steam_list);

var i
for (i=0; i < ds_list_size(steam_list); i++) {
draw_text(500,100,steam_list)
}