var centerx = camera_get_view_x(view_camera[0]) + 512
var propery = camera_get_view_y(view_camera[0])

draw_set_alpha(0.5)

draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_center)

draw_text(centerx,propery+100,"Resize your level!")
draw_set_font(global.deathfont)
draw_text(centerx,propery+160,"Resize your level so you can make them big!")

if previouswidth > sizewidth || previousheight > sizeheight {
draw_set_color(c_red)
draw_text_ext(centerx,propery+190,loc(141),20,700)
}

draw_set_color(c_white)
draw_text(centerx,propery+260,"Level Size: \n" + string(sizewidth) + "x" + string(sizeheight) + " Blocks")

draw_sprite_ext(s_leveleditorresizeblock,0,centerx-(previouswidth/2),propery+470-(previousheight/2),previouswidth,previousheight,0,c_gray,1)
draw_sprite_ext(s_leveleditorresizeblock,0,centerx-(sizewidth/2),propery+470-(sizeheight/2),sizewidth,sizeheight,0,c_red,1)


draw_text(centerx,propery+630,"You can press ENTER to change\nPress ESC to leave!")

if global.levelname = "" {
	draw_set_color(c_yellow)
	draw_text_transformed(centerx,propery+690,"You need to give your level a name before proceeding!",1+pressedenter,1+pressedenter,0)
}

draw_set_color(c_white)
draw_set_halign(fa_left)