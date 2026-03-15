draw_set_alpha(0.7)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_font(global.gamemodefont)
draw_set_halign(fa_center)
draw_set_color(c_white)

switch(result) {
case(0.1): draw_text(512,250,"Preparing upload...") break;
case(0.5): draw_text(512,250,"Uploading workshop challenge...") break;
case(1):
	draw_text(512,250,"Challenge published!")
	draw_set_font(global.deathfont)
	draw_text(512,320,"Publish ID: " + string(published_file_id))
	break;
case(2):
	draw_text(512,250,"Legal agreement required.\nPlease accept it in Steam.")
	break;
case(3):
	draw_text(512,250,"You need to be logged on Steam to upload.")
	break;
case(4):
	draw_text(512,250,"Upload failed.")
	break;
default:
	draw_text(512,250,"Uploading...")
	break;
}

draw_set_halign(fa_left)

