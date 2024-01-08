function draw_achievement(sprite,stat,req,secret,title,desc,titlesize,steam){
draw_sprite(s_achievementblankbox,0,x,y)

var thingy
if steam = 0 {
thingy = (stat < req)
} else {
thingy = !steam_get_achievement(stat)
}

//Icon
if thingy {
shader_set(xot_cbs_shGrayscale)
}
if secret = false { draw_sprite_ext(sprite,0,x+10,y+10,0.3,0.3,0,c_white,1) } else {
if thingy {
draw_sprite_ext(s_secretAIcon,0,x+10,y+10,0.3,0.3,0,c_white,1)
} else { draw_sprite_ext(sprite,0,x+10,y+10,0.3,0.3,0,c_white,1) }
}

shader_reset()

//Title And Description
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
if thingy { draw_set_color(c_yellow) } else { draw_set_color(c_lime) }
draw_text_transformed(x+192,y+20,title,titlesize,titlesize,0)
draw_set_color(c_white)
draw_set_valign(fa_top)
draw_set_font(global.cool2font)
if secret = true {
	if thingy {
	draw_text(x+191,y+30,"(Secret Achievement)") } else {
	draw_text_ext(x+191,y+30,desc,16,210)
	}
} else {
draw_text_ext(x+191,y+30,desc,16,210) }

draw_set_halign(fa_right)

//Progress Bar
//var color = c_red
if steam = 0 {
if stat < req {
draw_sprite_ext(s_xpbar,0,x+10,y+100,93*(stat/req),1.5,0,c_red,1)
draw_text(x+290,y+95,string_format(stat,0,0) + " / " + string_format(req,0,0))
} else {
draw_sprite_ext(s_xpbar,0,x+10,y+100,93,1.5,0,c_lime,1)
}} else {
if steam_get_achievement(stat) {
draw_sprite_ext(s_xpbar,0,x+10,y+100,93,1.5,0,c_lime,1)
} else { draw_sprite_ext(s_xpbar,0,x+10,y+100,93,1.5,0,c_red,1) }
}

draw_set_halign(fa_left)
}