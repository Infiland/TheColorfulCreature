if timerjump < 20 {
image_yscale = lerp(image_yscale,0.8,0.2 * (60 / global.maxfps))
} else { 
	image_yscale = lerp(image_yscale,1,0.2 * (60 / global.maxfps))
}
draw_sprite_ext(s_theking,image_index,x,y,image_xscale,image_yscale,0,c_white,1)