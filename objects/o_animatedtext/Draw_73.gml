draw_set_font(global.completefont)
//draw_set_font(global.langfont)

draw_set_halign(fa_center)
draw_set_alpha(1)
var textlayer = 0

timer -= 1 * (60 / global.maxfps)
if timer < 0 {
textchange += 1
if textchange > 3 {
textchange = 0
}
timer = 150
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

for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((camera_get_view_x(view_camera[0])) + 512 + ((changex*dist) * textlayer),(90 - texty) + ((changey*dist) * textlayer),text)
}
draw_set_halign(fa_left)

if room = r_achievements {
if global.achievementsscroll > 49 {
texty = 255	
} else { texty = 55 }
}