draw_self()
draw_set_color(c_white)
draw_set_font(global.coolfont)
draw_set_halign(fa_left)
draw_set_alpha(1)
if ischanging = true { draw_set_color(c_yellow) }

switch(controls) {
case(0): var txtr = loc("MOVE_RIGHT") //RIGHT
draw_text(x,y+50,string(txtr))
controlschoose = global.controlsmoveright break;
case(1): var txtl = loc("MOVE_LEFT") //LEFT
draw_text(x,y+50,string(txtl))
controlschoose = global.controlsmoveleft break;
case(2): var txtj = loc("JUMP") //JUMP
draw_text(x,y+50,string(txtj))
controlschoose = global.controlsjump break;
case(3): var txti = loc("INTERACT") //INTERACT
draw_text(x,y+50,string(txti))
controlschoose = global.controlsinteract break;
case(4): var txtsl = loc("SKIP_LEVEL") //SKIP
draw_text(x,y+50,string(txtsl))
controlschoose = global.controlsskiplevel break;
case(5): var txtr = loc("RESTART") //RESTART
draw_text(x,y+50,string(txtr))
controlschoose = global.controlsrestart break;
}

draw_set_font(global.deathfont)
switch(controlschoose) {
default: drawtext = controlschoose break;
case("40"): drawtext = "Down Key" break;
case("39"): drawtext = "Right Key" break;
case("38"): drawtext = "Up Key" break;
case("37"): drawtext = "Left Key" break;
case("32"): drawtext = "Spacebar" break;
case("17"): drawtext = "Control" break;
case("13"): drawtext = "Enter" break;
case("16"): drawtext = "Shift" break;
case("9"): drawtext = "Tab" break;
case("18"): drawtext = "Alt" break;
case("188"): drawtext = "," break;
case("190"): drawtext = "." break;
case("191"): drawtext = "/" break;
case("27"): drawtext = "Um? Why?" break;
case("8"): drawtext = "Backspace" break;
}

draw_set_halign(fa_center)

if (os_type != os_android && gamepad_is_connected(0)) {
	// === Controller connected: show controller binding in place of keyboard ===
	var _gpbtn = gamepad_remap_get(controls);
	var _gptext = gamepad_button_display_name(_gpbtn);
	
	if (ischanging && editcontrols == controls) {
		draw_set_color(c_yellow);
		draw_text(x+60, y+12, "...");
	} else {
		draw_set_color(c_aqua);
		draw_text(x+60, y+12, _gptext);
	}
	draw_set_color(c_white);
} else {
	// === No controller: show keyboard binding ===
	draw_text(x+60,y+12,drawtext)
}

draw_set_halign(fa_left)
