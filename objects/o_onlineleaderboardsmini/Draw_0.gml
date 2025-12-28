if global.hardmode = 1 { instance_destroy() 
exit;	
}

draw_set_font(global.deathfont)
draw_set_halign(fa_right)
draw_set_color(c_white)
var max_width = 0
for(var i = 0; i < 50; i++;) {
	if steam_score[i] = 0 and steam_rank[i] = 0 { continue }
	var row_text = ""
	if numerical = 0 {
		row_text = string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i] / 1000) + "s"
	} else { row_text = string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i]) }
	var row_width = string_width(row_text)
	if row_width > max_width { max_width = row_width }
}
var avatar_x = 990 - max_width - avatar_padding - avatar_draw_size
for(var i = 0; i < 50; i++;) {
if steam_score[i] = 0 and steam_rank[i] = 0 {
if i = 0 { draw_text(990,200 + (diff*240),loc(665)) }
} else {
if i = 0 { draw_text_scribble(990,180 + (diff*240),"[rainbow]" + string(lbname)) }
var row_y = 200+(i*20) + (diff*240)
var row_text = ""
if numerical = 0 {
	row_text = string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i] / 1000) + "s"
} else { row_text = string(steam_rank[i]) + ".   " + string(steam_name[i]) + "   " + string(steam_score[i]) }
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
	draw_set_halign(fa_right)
}
if steam_rank[i] <= 10 { draw_set_color($a5d6ff) } else { draw_set_color(c_white) }
if steam_rank[i] = 1 { draw_set_color($00ccff) }
if steam_rank[i] = 2 { draw_set_color($e0e0e0) }
if steam_rank[i] = 3 { draw_set_color($1f82d3) }

draw_text(990,row_y,row_text)

}}
draw_set_halign(fa_left)
