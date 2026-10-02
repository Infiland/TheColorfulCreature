// Called once per simulation tick; Draw only presents the resulting state.
function scr_custombutton_step() {
    if (!visible || !timing_is_tick()) return;
    if (variable_instance_exists(id, "timing_button_tick") && timing_button_tick == timing_tick_id()) return;
    timing_button_tick = timing_tick_id();
timer -= 1 * (60 / TCC_SIM_HZ)
if timer < 0 {
textchange += 1
if textchange > 3 {
textchange = 0
}
timer = 60
}

switch(textchange) {
case(0):
changex = lerp(changex,1,textspeed)
changey = lerp(changey,-1,textspeed)
break;
case(1):
changex = lerp(changex,-1,textspeed)
changey = lerp(changey,-1,textspeed)
break;
case(2):
changex = lerp(changex,-1,textspeed)
changey = lerp(changey,1,textspeed)
break;
case(3):
changex = lerp(changex,1,textspeed)
changey = lerp(changey,1,textspeed)
break;
}
if locked = 0 {
if mouseon = false { col = lerp(col,0,0.2 * (60 / TCC_SIM_HZ))
	dist = lerp(dist,0,0.2 * (60 / TCC_SIM_HZ))
	} else {
col = lerp(col,50,0.2 * (60 / TCC_SIM_HZ))
dist = lerp(dist,1,0.2 * (60 / TCC_SIM_HZ))}
}

    if (locked == 0 && mouseon && gamepad_ui_pressed(gp_face1)) event_perform(ev_mouse, ev_left_press);
}

function timing_buttons_end_step() {
    if (!variable_global_exists("timing_buttons")) return;
    var _live = [];
    var _buttons = global.timing_buttons;
    for (var _i = 0; _i < array_length(_buttons); ++_i) {
        if (!instance_exists(_buttons[_i])) continue;
        array_push(_live, _buttons[_i]);
        with (_buttons[_i]) scr_custombutton_step();
    }
    global.timing_buttons = _live;
}

function scr_custombutton(){
var xx = (x+5*image_xscale)
var yy = (y+5*image_yscale)
var xtxt = (x + xx) / 2
var ytxt = (y + yy) / 2
draw_set_font(font)
var textlayer = 0
draw_set_alpha(1)
var a = 1 / image_alpha
var et = 0
//Color This Red V
if text = "Eternal\nSuffering" {
et = 1
}
if locked = 1 {
	text = lockedtext
	xscale = lockedxscale * xMULTI
	yscale = lockedyscale * xMULTI
	a = 2
	}



backcolor = make_color_rgb((col/5)/a,(col/5)/a,(col/5)/a)
draw_set_color(backcolor)
draw_rectangle(x, y, (x+5*image_xscale), (y+5*image_yscale), false);

draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_center)
if locked = 0 and dist > 0.03 { //Render Text
for(textlayer = 0;textlayer < 5;textlayer++) {
if et = 0 {
draw_set_color(make_color_rgb((100 + 32 * textlayer)/a,(100 + 32 * textlayer)/a,(100 + 32 * textlayer)/a))
} else { draw_set_color(make_color_rgb((100 + 32 * textlayer)/a,0,0)) }
draw_text_ext_transformed((xtxt + ((changex*dist) * textlayer))+ox ,(ytxt+2 + ((changey*dist) * textlayer))-3.8+oy, text,50,(5*image_xscale) * (2 - xscale), xscale * xMULTI, yscale * yMULTI, 0);
}} else {draw_set_color(make_color_rgb(255/a,255/a,255/a))
	draw_text_ext_transformed((xtxt + ((changex*dist) * textlayer))+ox ,(ytxt+2 + ((changey*dist) * textlayer))-3.8+oy, text,50,(5*image_xscale) * (2 - xscale), xscale * xMULTI, yscale * yMULTI, 0);
}

if locked = 1 {
	if locksprite = 1 {
	draw_sprite(s_lock,0,xtxt,ytxt)
	}}

linecolor = make_color_rgb((dlineC_R/a),(dlineC_G/a),(dlineC_B - (5.1 * col))/a)
draw_set_color(linecolor)
draw_line_width(x, y, xx, y, width); //Top
draw_line_width(x, y, x, yy, width); //Left
draw_line_width(xx, y, xx, yy, width); //Right
draw_line_width(x, yy, xx, yy, width); //Bottom

draw_set_halign(fa_left)
draw_set_valign(fa_left)
draw_set_color(c_white)


}
