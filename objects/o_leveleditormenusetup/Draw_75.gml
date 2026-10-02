var maus_y = mouse_y - camera_get_view_y(view_camera[0])

draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_font(fnt_mainmenu)
draw_set_halign(fa_center)
draw_text(512,100,title)
draw_set_font(global.deathfont)


switch(page) {
case(1):
if maus_y > 180 &&  maus_y < 230 { draw_set_color(c_yellow) }
draw_text(512,200,"New Level") draw_set_color(c_white)
if maus_y > 230 &&  maus_y < 280 { draw_set_color(c_yellow) }
draw_text(512,250,"Load a Level") draw_set_color(c_white)
if maus_y > 280 &&  maus_y < 330 { draw_set_color(c_yellow) }
draw_text(512,300,"How to use Level Editor") draw_set_color(c_white)
if maus_y > 330 &&  maus_y < 380 { draw_set_color(c_yellow) }
draw_text(512,350,"Steam Workshop") draw_set_color(c_white)
if maus_y > 380 &&  maus_y < 430 { draw_set_color(c_yellow) }
draw_text(512,400,"Advanced Narrator Colors") draw_set_color(c_white)
if maus_y > 480 &&  maus_y < 530 { draw_set_color(c_yellow) }
draw_text(512,500,"Exit Level Editor") draw_set_color(c_white)
break;
case(2):
draw_set_halign(fa_left)
if maus_y > 180 &&  maus_y < 220 {
	draw_sprite_ext(s_LEName,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)

}

	if select = 1 {
	draw_text_scribble(xx,700,"[c_dkgray](Left Click 'Level Name' again to confirm name change)")
	if string_length(keyboard_string) < 40 {
	draw_text(xx,200,"Level Name: " + string(keyboard_string))
	}
	} else {
		draw_text(xx,200,"Level Name: " + string(global.levelname))
	}
 draw_set_color(c_white)
if maus_y > 220 &&  maus_y < 260 {
	draw_sprite_ext(s_LEText,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)
	}

	if select = 2 {
	draw_text_scribble(xx,700,"[c_dkgray](Left Click 'Level Narrator' again to confirm narrator change)")
	draw_text(xx,240,"Level Narrator: " + string(keyboard_string))
	} else {
		draw_text_scribble(xx,240,"Level Narrator: " + string(global.leveleditorstring))
	}

draw_set_color(c_white)
if maus_y > 260 &&  maus_y < 300 {
	draw_sprite_ext(s_LEMusic,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)
	}
draw_text(xx,280,"Level Music: " + string(global.leveleditormusic)) draw_set_color(c_white)
if maus_y > 300 &&  maus_y < 340 { draw_set_color(c_yellow) }
draw_text(xx,320,"Level Width: " + string(global.LELevelWidthBlocks) + " Blocks") draw_set_color(c_white)
if maus_y > 340 &&  maus_y < 380 { draw_set_color(c_yellow) }
draw_text(xx,360,"Level Height: " + string(global.LELevelHeightBlocks)+ " Blocks") draw_set_color(c_white)
if maus_y > 380 &&  maus_y < 420 {
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
	}
draw_text(xx,440,"Level Background: " + string(global.LEBackground)) draw_set_color(c_white)
if maus_y > 460 &&  maus_y < 500 {
	draw_sprite_ext(s_LEStarBackground,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)
	}
draw_text(xx,480,"Level Star Direction: " + string(global.LEStarRotation) +"d" + "  CTRL to change style " + string(global.LEStarStyle)) draw_set_color(c_white)
if maus_y > 500 &&  maus_y < 540 {
	draw_sprite_ext(s_LEDiamondMedalTime,0,630,300,3,3,0,c_white,1)
	draw_set_color(c_yellow)
	}
draw_text(xx,520,"Level Diamond Time: " + string(global.LEDiamondMedalTime) + "s") draw_set_color(c_white)
if maus_y > 540 &&  maus_y < 580 {
	draw_set_color(c_yellow)
}
draw_text(xx,560,"Block Style: " + string(global.LEBlockStyle)) draw_set_color(c_white)

if maus_y > 580 &&  maus_y < 620 {
	draw_set_color(c_yellow)
}
draw_text(xx,600,"Fog: " + string(global.LEFog)) draw_set_color(c_white)


if maus_y > 660 && maus_y < 700 { draw_set_color(c_yellow) }

if (global.LEsetup_error != "") {
    draw_set_color(c_red);
    draw_text_ext(xx, 628, global.LEsetup_error, 18, 860);
    draw_set_color(c_white);
}
if global.levelname == "" {
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
draw_text(512,200,loc("WHAT_LEVEL_DO_YOU_WANT_TO_LOAD"))
var directory = working_directory + "/LevelEditor Files/" + "/" + keyboard_string + "/"
if directory_exists(directory) {
draw_set_color(c_lime)
} else { draw_set_color(c_red) }
draw_text(512,300,keyboard_string)

if !directory_exists(directory) {
draw_set_color(c_white)
draw_set_font(global.deathfont)
if keyboard_string != "" {
draw_text(512,370,loc("WARNING_THIS_LEVEL_DOESN_T_EXIST")) }}

draw_set_color(c_white)
draw_set_font(global.gamemodefont)
draw_set_color(c_white)
draw_text(512,400,loc("PRESS_ENTER_WHEN_YOU_ARE_DONE")+".\n"+loc("PRESS_ESC_TO_CANCEL"))
draw_set_halign(fa_left)
draw_set_font(global.deathfont)
draw_text(100,600,"In order to find your level name, go to %appdata%, then The_Colorful_Creature\nfolder, LevelEditor Files, and the folder names are the level names.")

if timing_keyboard_pressed(vk_enter) {
instance_destroy()
instance_destroy(o_allbackgrounds)
global.levelname = keyboard_string
//Load
if global.levelname != "" {

instance_create(x,y,o_levelreloadagain)
if !achievement_earned("LOAD_LEVEL") { //Load Level
achievement_award("LOAD_LEVEL") }
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
draw_text_transformed(512,196,"[/] - Reset all effects\n[[ - Add a bracket\n[<name of font>] - Change font (available: fnt_cool1, fnt_cool2 (default), fnt_gamemode, fnt_death, fnt_skip, fnt_secret1, fnt_multiplayerfont, fnt_complete, fnt_mainmenu)\n[<name of colour>] - Change color of the text ([c_red])\n[#<hex code>] - Change color by using hex code.\n[d#<decimal>] - Change color by using BRG hex code. (Gamemaker uses BRG!!! NOT RGB!)\n[<name of sprite>,<image>,<speed>] - Draw a sprite, putting custom frame and speed is not required",0.55,0.55,0)
draw_text(512,310,"Alignment")
draw_text_transformed(512,340,"[fa_left] - Align text to the left\n[fa_center] - Align text to the center\n[fa_right] - Align text to the right\n[fa_top] - Align text to the top\n[fa_middle] - Align text to the middle",0.55,0.55,0)
draw_text(512,420,"Transformation")
draw_text_transformed(512,450,"[scale,<factor>] - Scale up text/sprites\n[slant] - Set text to look 'Italic'",0.55,0.55,0)
draw_text(512,490,"Effects")
draw_text_transformed(512,520,"[wave] - Adds a wave effect\n[shake] - Adds a shake effect\n[wobble] - Adds a wobble effect (rotates back and forth)\n[pulse] - Adds a pulsing effect (heart beat effect in a way)\n[wheel] - Text circles by its origin\n[jitter] - Adds a jitter effect (text scales erratically)\n[blink] - Adds a blinking effect (Text flashes on/off)\n[rainbow] - Adds a rainbow effect\n[cycle,<hue1>,<hue2>,<hue3>,<hue4>] - Similar to rainbow effect, except you can choose your own colors to cycle through. Limited up to 4 colors!",0.55,0.55,0)
break;
}

draw_set_halign(fa_left)
