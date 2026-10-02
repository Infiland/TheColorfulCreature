function declarecustombutton(){
if (!variable_global_exists("timing_buttons")) global.timing_buttons = [];
if (!variable_instance_exists(id, "timing_button_registered")) {
    timing_button_registered = true;
    array_push(global.timing_buttons, id);
}
width = 5
text = ""
xscale = 1
yscale = 1

xMULTI = 1
yMULTI = 1

changex = 0
changey = 0
ox = 0
oy = 0
textchange = irandom_range(0,3)
textspeed = 0.03 * (60 / TCC_SIM_HZ)
timer = 0
dist = 0
font = fnt_mainmenu
col = 0
wide = 300
mouseon = 0
backcolor = make_color_rgb(0,0,0)
linecolor = make_color_rgb(255,255,255)
locked = 0
notavailable = 0
locksprite = 1
lockedtext = "???????"
lockedxscale = 1
lockedyscale = 1
//Default Line Color
dlineC_R = 255
dlineC_G = 255
dlineC_B = 255
timing_ui_register_declared_button();
}
