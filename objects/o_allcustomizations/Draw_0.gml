draw_self()

//Draw Mastery Badge
if mastery > 0 {
	var m_col = 225 - 30 * sin(x+current_time/200)
	var mm_col = make_color_rgb(m_col,m_col,m_col)
	draw_sprite_ext(s_skinoutlineMastery,mastery-1,x,y,image_xscale,image_yscale,image_angle,mm_col,1)
}