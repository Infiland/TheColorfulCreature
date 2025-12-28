draw_set_halign(fa_center)
draw_text_ext(820,550,loc(666),20,400)
draw_set_halign(fa_left)

draw_set_font(fnt_deathcyrillic)
draw_text_scribble(60,120-scroll,"[rainbow]" + string(lbname) +"[/]")
for(var i = 0; i < 100; i++;)
        {
if steam_score[i] = 0 and steam_rank[i] = 0 {
if i = 0 { draw_text(60,160,loc(665)) }
} else {
var row_y = 160+(i*20)-scroll
var avatar_x = 15
var avatar_drawn = false
if ds_map_exists(avatar_sprites, string(steam_userid[i])) {
	var spr = ds_map_find_value(avatar_sprites, string(steam_userid[i]))
	if sprite_exists(spr) {
		var spr_w = sprite_get_width(spr)
		var spr_h = sprite_get_height(spr)
		var scale_x = avatar_draw_size / spr_w
		var scale_y = avatar_draw_size / spr_h
		draw_sprite_ext(spr, 0, avatar_x, row_y, scale_x, scale_y, 0, c_white, 1)
		avatar_drawn = true
	}
}
if (!avatar_drawn) {
	draw_set_color($3a3a3a)
	draw_rectangle(avatar_x, row_y, avatar_x + avatar_draw_size, row_y + avatar_draw_size, false)
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_text(avatar_x + (avatar_draw_size * 0.5), row_y - 1, "?")
	draw_set_halign(fa_left)
}
draw_set_color(c_white)
if steam_rank[i] <= 10 { draw_set_color($a5d6ff) }
if steam_rank[i] = 1 { draw_set_color($00ccff) }
if steam_rank[i] = 2 { draw_set_color($e0e0e0) }
if steam_rank[i] = 3 { draw_set_color($1f82d3) }
if global.leaderboardselect >= 0 {
draw_text(60,row_y,string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i] / 1000) + "s")
} else {
draw_text(60,row_y,string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i]))
}
}
}
