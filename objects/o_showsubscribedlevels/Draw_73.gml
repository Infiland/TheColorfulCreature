draw_set_color(c_white)
draw_set_alpha(0.5)
draw_rectangle_color(0,0,1024,768,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_font(global.deathfont)
var _num_sub = variable_instance_exists(id, "numSub") ? numSub : 0;
draw_text(16,700,"Current Number of\nDownloaded Maps: " + string(_num_sub))

/*
steam_list = ds_list_create();
tcc_steam_ugc_get_subscribed_items(steam_list);

var i
for (i=0; i < ds_list_size(steam_list); i++) {
draw_text(500,100,steam_list)
}
