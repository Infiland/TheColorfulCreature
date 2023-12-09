draw_set_font(global.completefont)
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

if timer2 > 0 {
timer2 -= 1	* (60 / global.maxfps)
} else {
nexttext += 1
timer2 = 100	
}

draw_set_halign(fa_left)
if nexttext = 1 { deaths = 0 }
if nexttext > 0 {
x1 = lerp(x1,0,0.05 * (60 / global.maxfps))
text = loc(664) + " " + string(global.time)
for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((500 - x1) + ((changex*dist) * textlayer),90 + ((changey*dist) * textlayer),text)
}
}