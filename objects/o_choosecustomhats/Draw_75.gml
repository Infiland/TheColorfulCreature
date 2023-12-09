draw_set_font(global.deathfont)
draw_set_alpha(0.8)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_halign(fa_center)

if page != maxpage {
if keyboard_check_pressed(vk_right) {
page += 1	
}}
if page != 1 {
if keyboard_check_pressed(vk_left) {
page -= 1	
}}

var xcam = camera_get_view_x(view_camera[0])+512

if len = 0 {
draw_text(xcam,350,"Oops! Looks like you don't have custom hats!\nHead over to %appdata%, then Custom/Player Hats to add hats!")
}

if mouse_x > 850 && mouse_x < 1000 && mouse_y > 30 && mouse_y < 80 {
	col2 = c_yellow
	if mouse_check_button(mb_left) {
		global.CUSTOMhat = ""
		scr_savehats()
	}
} else { col2 = c_white }
if global.CUSTOMhat = "" { col2 = c_lime }
draw_rectangle_color(850,30,1000,80,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(850,30,1000,80,col2,col2,col2,col2,true)
draw_text(920,40,"Deselect Hat")

if mouse_x > 850 && mouse_x < 1000 && mouse_y > 100 && mouse_y < 150 {
	col3 = c_yellow
		if mouse_check_button(mb_left) {
		if global.customhatautoscale = 0 { global.customhatautoscale = 1 } else{
			global.customhatautoscale = 0 }
	}
} else { if global.customhatautoscale = 0 { col3 = c_white } else { col3 = c_lime } }
draw_rectangle_color(850,100,1000,150,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(850,100,1000,150,col3,col3,col3,col3,true)
draw_text(920,110,"Autoscale Hat")

if page != maxpage {

for(var i=(page-1)*15;i<page*15;i++) {
	
if mouse_x > xcam-300 && mouse_x < xcam+300 && mouse_y > 85-(floor(i/15)*600)+i*40 && mouse_y < 115-(floor(i/15)*600)+i*40 {
	col = c_yellow
} else { col = c_white }
if files[i] = global.CUSTOMhat { col = c_lime }
	
draw_rectangle_color(xcam+300,85-((page-1)*600)+i*40,xcam-300,115-((page-1)*600)+i*40,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(xcam+300,85-((page-1)*600)+i*40,xcam-300,115-((page-1)*600)+i*40,col,col,col,col,true)
draw_text(xcam,87-((page-1)*600)+i*40,files[i])

selecthatCUSTOM(i,files[i])

}

} else {

for(var i=(maxpage-1)*15;i<((maxpage-1)*15) + lastlevels;i++) {
	
if mouse_x > xcam-300 && mouse_x < xcam+300 && mouse_y > 85-(floor(i/15)*600)+i*40 && mouse_y < 115-(floor(i/15)*600)+i*40 {
	col = c_yellow
} else { col = c_white }
if files[i] = global.CUSTOMhat { col = c_lime }
	
draw_rectangle_color(xcam+300,85-((page-1)*600)+i*40,xcam-300,115-((page-1)*600)+i*40,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(xcam+300,85-((page-1)*600)+i*40,xcam-300,115-((page-1)*600)+i*40,col,col,col,col,true)
draw_text(xcam,87-((page-1)*600)+i*40,files[i])

selecthatCUSTOM(i,files[i])

}
}

draw_text(xcam,700,"Use arrow keys to change between pages. ESC to leave")
draw_text(xcam,720,"Page: " + string(page) + "/" + string(maxpage))
draw_set_halign(fa_left)

if keyboard_check_pressed(vk_escape) {
instance_destroy()	
}