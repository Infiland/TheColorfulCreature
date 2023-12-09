draw_self()
draw_set_color(c_white)
draw_set_font(fnt_cool2)
draw_set_halign(fa_left)
draw_set_alpha(1)
if ischanging = true { draw_set_color(c_yellow) }

switch(controls) {
case(0):
switch(global.language) {
default: draw_text(x,y+50,"Move Right") break;
case(1): draw_text(x,y+50,"Rechts Bewegen") break;
case(2): draw_text(x,y+50,"Bouger à Droite") break;
case(3): draw_text(x,y+50,"Vai a Destra") break;
case(4): draw_text(x,y+50,"Ve a la Derecha") break;
case(5): draw_text(x,y+50,"Mozgás jobbra") break;
}
controlschoose = global.controlsmoveright break;
case(1):
switch(global.language) {
default: draw_text(x,y+50,"Move Left") break;
case(1): draw_text(x,y+50,"Links bewegen") break;
case(2): draw_text(x,y+50,"Bouger à gauche") break;
case(3): draw_text(x,y+50,"Vai a sinistra") break;
case(4): draw_text(x,y+50,"Ve a la izquierda") break;
case(5): draw_text(x,y+50,"Mozgás balra") break;
}
controlschoose = global.controlsmoveleft break;
case(2):
switch(global.language) {
default: draw_text(x,y+50,"Jump") break;
case(1): draw_text(x,y+50,"Springen") break;
case(2): draw_text(x,y+50,"Sauter") break;
case(3): draw_text(x,y+50,"Salta") break;
case(4): draw_text(x,y+50,"Saltar") break;
case(5): draw_text(x,y+50,"Ugrás") break;
}
controlschoose = global.controlsjump break;
case(3): 
switch(global.language) {
default: draw_text(x,y+50,"Interact") break;
case(1): draw_text(x,y+50,"Interagieren") break;
case(2): draw_text(x,y+50,"Interagir") break;
case(3): draw_text(x,y+50,"Interagisci") break;
case(4): draw_text(x,y+50,"Interactuar") break;
case(5): draw_text(x,y+50,"Interakció") break;
}
controlschoose = global.controlsinteract break;
case(4): 
switch(global.language) {
default: draw_text(x,y+50,"Skip Level") break;
case(1): draw_text(x,y+50,"Level überspringen") break;
case(2): draw_text(x,y+50,"Sauter le niveau") break;
case(3): draw_text(x,y+50,"Salta livello") break;
case(4): draw_text(x,y+50,"Saltarte nivel") break;
case(5): draw_text(x,y+50,"Pálya átugrása") break;
}
controlschoose = global.controlsskiplevel break;
case(5):
switch(global.language) {
default: draw_text(x,y+50,"Restart") break;
case(1): draw_text(x,y+50,"Neustart") break;
case(2): draw_text(x,y+50,"Recommencer") break;
case(3): draw_text(x,y+50,"Ricomincia") break;
case(4): draw_text(x,y+50,"Renaudar") break;
case(5): draw_text(x,y+50,"Újrakezdés") break;
}
controlschoose = global.controlsrestart break;
}

draw_set_font(fnt_death)
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
draw_set_font(fnt_cool2)
draw_text(mouse_x,mouse_y,"Right: " + string(global.controlsmoveright));
draw_text(mouse_x,mouse_y+15,"Left: " + string(global.controlsmoveleft));
draw_text(mouse_x,mouse_y+30,"Jump: " + string(global.controlsjump));
draw_text(mouse_x,mouse_y+45,"Interact: " + string(global.controlsinteract));
draw_text(mouse_x,mouse_y+60,"Skip: " + string(global.controlsskiplevel));
draw_text(mouse_x,mouse_y+75,"KYS: " + string(global.controlsrestart));
draw_text(mouse_x,mouse_y+90,"EDIT: " + string(editcontrols));
}*/