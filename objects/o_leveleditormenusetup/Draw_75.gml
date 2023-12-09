var maus_y = mouse_y - camera_get_view_y(view_camera[0])

//maus_y = window_mouse_get_y();

if keyboard_check_pressed(vk_escape) {
	if page = 1 {
	if !instance_exists(o_LESettings) {
	audio_stop_all() room_goto(r_mainmenu) instance_destroy()
	} else { instance_destroy() }
	} else { 
		if !instance_exists(o_placeblock) {
		page = 1 title = "Please choose an option:" instance_destroy(o_namelevelwhenloadingLE)
		} else { instance_destroy() }
		}
	}
	
	

draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_font(fnt_mainmenu)
draw_set_halign(fa_center)
draw_text(512,100,title)
draw_set_font(global.deathfont)

xx = lerp(xx,xxx,0.2)

switch(page) {
case(1):
if maus_y > 180 &&  maus_y < 230 { draw_set_color(c_yellow) 
	if mouse_check_button_released(mb_left) { page = 2 title = "Basic Level Info:" xx = -500 } }
draw_text(512,200,"New Level") draw_set_color(c_white)
if maus_y > 230 &&  maus_y < 280 { draw_set_color(c_yellow) 
	if mouse_check_button_released(mb_left) { page = 3 keyboard_string = "" title = "" instance_create_depth(x,y,-10,o_chooseleveleditorlevel)} }
draw_text(512,250,"Load a Level") draw_set_color(c_white)
if maus_y > 280 &&  maus_y < 330 { draw_set_color(c_yellow)
	if mouse_check_button_released(mb_left) { page = 4 title = "Level Editor Tutorial:" } }
draw_text(512,300,"How to use Level Editor") draw_set_color(c_white)
if maus_y > 330 &&  maus_y < 380 { draw_set_color(c_yellow)
	if mouse_check_button_released(mb_left) { steam_activate_overlay_browser("https://steamcommunity.com/app/1651680/workshop/") }}
draw_text(512,350,"Steam Workshop") draw_set_color(c_white)
if maus_y > 380 &&  maus_y < 430 { draw_set_color(c_yellow)
	if mouse_check_button_released(mb_left) { page = 5 title = "Advanced Narrator Colors: " }}
draw_text(512,400,"Advanced Narrator Colors") draw_set_color(c_white)
if maus_y > 480 &&  maus_y < 530 { draw_set_color(c_yellow)
	if mouse_check_button_released(mb_left) { audio_stop_all() room_goto(r_mainmenu) instance_destroy() }
	}
draw_text(512,500,"Exit Level Editor") draw_set_color(c_white)
break;
case(2):
draw_set_halign(fa_left)
if maus_y > 180 &&  maus_y < 220 { 
	draw_sprite_ext(s_LEName,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow) 
	
	if mouse_check_button_pressed(mb_left) { 
		if select = 0 {
		select = 1 keyboard_string = global.levelname 
		} else {
		select = 0	
		global.levelname = keyboard_string
		keyboard_string = ""
		}
		}}
		
	if select = 1 {
	draw_text_scribble(xx,700,"[c_dkgray](Left Click 'Level Name' again to confirm name change)")
	if string_length(keyboard_string) < 40 {
	draw_text(xx,200,"Level Name: " + string(keyboard_string))
	badwords()
	} else {
	string_delete(keyboard_string,string_length(keyboard_string)-1,1)
	}
	} else {
		draw_text(xx,200,"Level Name: " + string(global.levelname))
	}
 draw_set_color(c_white)
if maus_y > 220 &&  maus_y < 260 { 
	draw_sprite_ext(s_LEText,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow) 
		if mouse_check_button_pressed(mb_left) { 
		if select = 0 {
		select = 2 keyboard_string = global.leveleditorstring
		} else {
		select = 0	
		global.leveleditorstring = keyboard_string
		keyboard_string = ""
		}
		}}
	
	if select = 2 {
	draw_text_scribble(xx,700,"[c_dkgray](Left Click 'Level Narrator' again to confirm narrator change)")
	draw_text(xx,240,"Level Narrator: " + string(keyboard_string))
	badwords()
	} else {
		draw_text_scribble(xx,240,"Level Narrator: " + string(global.leveleditorstring))
	}

draw_set_color(c_white)
if maus_y > 260 &&  maus_y < 300 { 
	draw_sprite_ext(s_LEMusic,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)
	if mouse_check_button_pressed(mb_left) {
		global.leveleditormusic += string_digits(real(1))
		scr_leveleditormusic()
		}
	if mouse_check_button_pressed(mb_right) {
		global.leveleditormusic -= string_digits(real(1))
		scr_leveleditormusic()
		}
	}
draw_text(xx,280,"Level Music: " + string(global.leveleditormusic)) draw_set_color(c_white)
if maus_y > 300 &&  maus_y < 340 { draw_set_color(c_yellow)
	if global.LELevelWidthBlocks < 100 {
	if mouse_check_button(mb_left) {global.LELevelWidthBlocks += 1}
	}
	if global.LELevelWidthBlocks > 32 {
	if mouse_check_button(mb_right) {global.LELevelWidthBlocks -= 1}
}}
draw_text(xx,320,"Level Width: " + string(global.LELevelWidthBlocks) + " Blocks") draw_set_color(c_white)
if maus_y > 340 &&  maus_y < 380 { draw_set_color(c_yellow)
	if global.LELevelHeightBlocks < 100 {
	if mouse_check_button(mb_left) {global.LELevelHeightBlocks += 1}
}
	if global.LELevelHeightBlocks > 22 {
	if mouse_check_button(mb_right) {global.LELevelHeightBlocks -= 1}
	}}
draw_text(xx,360,"Level Height: " + string(global.LELevelHeightBlocks)+ " Blocks") draw_set_color(c_white)
if maus_y > 380 &&  maus_y < 420 { 
	if global.defaultcolorLE < 4 {
	if mouse_check_button_pressed(mb_left) {global.defaultcolorLE += 1 }
	}
	if global.defaultcolorLE > 0 {
	if mouse_check_button_pressed(mb_right) {global.defaultcolorLE -= 1 }
	}
	switch(global.defaultcolorLE) {
	default: draw_sprite_ext(s_playerred,0,630,300,5,5,0,c_white,1)	break;
	case(1): draw_sprite_ext(s_playeryellow,0,630,300,5,5,0,c_white,1) break;
	case(2): draw_sprite_ext(s_playergreen,0,630,300,5,5,0,c_white,1) break;
	case(3): draw_sprite_ext(s_playerblue,0,630,300,5,5,0,c_white,1) break;
	case(4): draw_sprite_ext(s_playerwhite,0,630,300,5,5,0,c_white,1) break;
	}
	draw_set_color(c_yellow) }
draw_text(xx,400,"Default Player Color: "+ string(global.defaultcolorLE)) draw_set_color(c_white)
if maus_y > 420 &&  maus_y < 460 { 
	draw_sprite_ext(s_LEBackgrounds,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow) 
	if mouse_check_button_pressed(mb_left) { global.LEBackground += 1 }
	if mouse_check_button_pressed(mb_right) { global.LEBackground -= 1 }
	if global.LEBackground < 0 { global.LEBackground = 2 }
	if global.LEBackground > 2 { global.LEBackground = 0 }
	}
draw_text(xx,440,"Level Background: " + string(global.LEBackground)) draw_set_color(c_white)
if maus_y > 460 &&  maus_y < 500 { 
	draw_sprite_ext(s_LEStarBackground,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow) 
	
	if keyboard_check_pressed(vk_control) { global.LEStarStyle += 1 if global.LEStarStyle > 2 { global.LEStarStyle = 0 } }
	if mouse_check_button(mb_left) { global.LEStarRotation += 1 }
	if mouse_check_button(mb_right) { global.LEStarRotation -= 1 }
	
	if global.LEStarRotation < 0 {global.LEStarRotation = 360}
	if global.LEStarRotation > 360 { global.LEStarRotation = 0 }
	
	}
draw_text(xx,480,"Level Star Direction: " + string(global.LEStarRotation) +"d" + "  CTRL to change style " + string(global.LEStarStyle)) draw_set_color(c_white)
if maus_y > 500 &&  maus_y < 540 { 
	draw_sprite_ext(s_LEDiamondMedalTime,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)
	var mulDIA = 10
	if keyboard_check(vk_control) {mulDIA = 1}
	if keyboard_check(vk_shift) {mulDIA = 100}
	if global.LEDiamondMedalTime < 1000 {
	if mouse_check_button(mb_left) {global.LEDiamondMedalTime += 0.01*mulDIA }
	} else { global.LEDiamondMedalTime = 1000 }
	if global.LEDiamondMedalTime > 0 {
	if mouse_check_button(mb_right) {global.LEDiamondMedalTime -= 0.01*mulDIA }
	} else { global.LEDiamondMedalTime = 0 }
	
	}
draw_text(xx,520,"Level Diamond Time: " + string(global.LEDiamondMedalTime) + "s") draw_set_color(c_white)
if maus_y > 540 &&  maus_y < 580 { 
	draw_set_color(c_yellow)
	if mouse_check_button_pressed(mb_left) { global.LEBlockStyle += 1}
	if mouse_check_button_pressed(mb_right) { global.LEBlockStyle -= 1}
	
	if global.LEBlockStyle < 0 { global.LEBlockStyle = 1 }
	if global.LEBlockStyle > 1 { global.LEBlockStyle = 0 }
}
draw_text(xx,560,"Block Style: " + string(global.LEBlockStyle)) draw_set_color(c_white)

if maus_y > 580 &&  maus_y < 620 { 
	draw_set_color(c_yellow)
	if mouse_check_button_pressed(mb_left) { global.LEFog += 1}
	if mouse_check_button_pressed(mb_right) { global.LEFog -= 1}
	
	if global.LEFog < 0 { global.LEFog = 1 }
	if global.LEFog > 1 { global.LEFog = 0 }
}
draw_text(xx,600,"Fog: " + string(global.LEFog)) draw_set_color(c_white)


if maus_y > 660 &&  maus_y < 700 { draw_set_color(c_yellow) 
	if global.levelname != "" {
	if mouse_check_button_pressed(mb_left) { LEVELEDITORSETUP(1) }
	}
	}

if global.levelname = "" {
draw_text_scribble(xx,680,"Finish[c_red] (You have to give your level a name)") 
} else { draw_text(xx,680,"Finish") }
draw_set_color(c_white)
if maus_y > 300 &&  maus_y < 380 {
draw_sprite_ext(s_leveleditorresizeblock,0,675,375,global.LELevelWidthBlocks,global.LELevelHeightBlocks,0,c_red,1)
}
break;
case(3): 

//LOAD
/*
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_halign(fa_center)
draw_text(512,200,loc(67))
var directory = working_directory + "/LevelEditor Files/" + "/" + keyboard_string + "/"
if directory_exists(directory) {
draw_set_color(c_lime)
} else { draw_set_color(c_red) }
draw_text(512,300,keyboard_string)

if !directory_exists(directory) {
draw_set_color(c_white)
draw_set_font(global.deathfont)
if keyboard_string != "" {
draw_text(512,370,loc(142)) }}

draw_set_color(c_white)
draw_set_font(global.gamemodefont)
draw_set_color(c_white)
draw_text(512,400,loc(65)+".\n"+loc(66))
draw_set_halign(fa_left)
draw_set_font(global.deathfont)
draw_text(100,600,"In order to find your level name, go to %appdata%, then The_Colorful_Creature\nfolder, LevelEditor Files, and the folder names are the level names.")

if keyboard_check_pressed(vk_enter) {
instance_destroy()
instance_destroy(o_allbackgrounds)
global.levelname = keyboard_string
//Load
if global.levelname != "" {

instance_create(x,y,o_levelreloadagain)
if !steam_get_achievement("LOAD_LEVEL") { //Load Level
steam_set_achievement("LOAD_LEVEL") }
} else {
	instance_destroy(o_savedandloaded)
	box = instance_create(x,y,o_savedandloaded)
	with(box) {
	image_index = 3	
	}

}}*/

break;
case(4):
draw_text(512,240,"Place Block : Left Click\nDelete Block : Right Click\nSelect Hovered Block : Middle CLick\nS : Save\nL : Load\nNumbers 0-9 : Quick Item Select\nItem Menu : I\nGrid : G\nCTRL + 1-3 : Category Select\nESC - Close")
break;
case(5):
draw_text(512,165,"Common")
draw_text_transformed(512,196,"[/] - Reset all effects\n[[ - Add a bracket\n[<name of font>] - Change font (available: fnt_classic, fnt_cool1, fnt_cool2 (default), fnt_gamemode, fnt_death, fnt_skip, fnt_secret1, fnt_multiplayerfont, fnt_complete, fnt_mainmenu)\n[<name of colour>] - Change color of the text ([c_red])\n[#<hex code>] - Change color by using hex code.\n[d#<decimal>] - Change color by using BRG hex code. (Gamemaker uses BRG!!! NOT RGB!)\n[<name of sprite>,<image>,<speed>] - Draw a sprite, putting custom frame and speed is not required",0.55,0.55,0)
draw_text(512,310,"Alignment")
draw_text_transformed(512,340,"[fa_left] - Align text to the left\n[fa_center] - Align text to the center\n[fa_right] - Align text to the right\n[fa_top] - Align text to the top\n[fa_middle] - Align text to the middle",0.55,0.55,0)
draw_text(512,420,"Transformation")
draw_text_transformed(512,450,"[scale,<factor>] - Scale up text/sprites\n[slant] - Set text to look 'Italic'",0.55,0.55,0)
draw_text(512,490,"Effects")
draw_text_transformed(512,520,"[wave] - Adds a wave effect\n[shake] - Adds a shake effect\n[wobble] - Adds a wobble effect (rotates back and forth)\n[pulse] - Adds a pulsing effect (heart beat effect in a way)\n[wheel] - Text circles by its origin\n[jitter] - Adds a jitter effect (text scales erratically)\n[blink] - Adds a blinking effect (Text flashes on/off)\n[rainbow] - Adds a rainbow effect\n[cycle,<hue1>,<hue2>,<hue3>,<hue4>] - Similar to rainbow effect, except you can choose your own colors to cycle through. Limited up to 4 colors!",0.55,0.55,0)
break;
}

draw_set_halign(fa_left)