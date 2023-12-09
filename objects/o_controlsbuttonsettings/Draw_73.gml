draw_self()
draw_set_color(c_white)
draw_set_font(global.coolfont)
draw_set_halign(fa_left)
draw_set_alpha(1)
if ischanging = true { draw_set_color(c_yellow) }

switch(controls) {
case(0): var txtr = loc(18) //RIGHT
draw_text(x,y+50,string(txtr))
controlschoose = global.controlsmoveright break;
case(1): var txtl = loc(19) //LEFT
draw_text(x,y+50,string(txtl))
controlschoose = global.controlsmoveleft break;
case(2): var txtj = loc(20) //JUMP
draw_text(x,y+50,string(txtj))
controlschoose = global.controlsjump break;
case(3): var txti = loc(21) //INTERACT
draw_text(x,y+50,string(txti))
controlschoose = global.controlsinteract break;
case(4): var txtsl = loc(22) //INTERACT
draw_text(x,y+50,string(txtsl))
controlschoose = global.controlsskiplevel break;
case(5): var txtr = loc(23) //INTERACT
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
draw_text(x+60,y+12,drawtext)
draw_set_halign(fa_left)

/*
if controls = 0 {
draw_set_font(global.coolfont)
draw_text(mouse_x,mouse_y,"Right: " + string(global.controlsmoveright));
draw_text(mouse_x,mouse_y+15,"Left: " + string(global.controlsmoveleft));
draw_text(mouse_x,mouse_y+30,"Jump: " + string(global.controlsjump));
draw_text(mouse_x,mouse_y+45,"Interact: " + string(global.controlsinteract));
draw_text(mouse_x,mouse_y+60,"Skip: " + string(global.controlsskiplevel));
draw_text(mouse_x,mouse_y+75,"KYS: " + string(global.controlsrestart));
draw_text(mouse_x,mouse_y+90,"EDIT: " + string(editcontrols));
}*/