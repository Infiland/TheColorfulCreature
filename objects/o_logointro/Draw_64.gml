draw_set_font(global.completefont)
draw_set_halign(fa_center)
draw_set_alpha(1)
var textlayer = 0

timerlogo -= 1 * (60 / global.maxfps)
if change = 0 {
if timerlogo < 0 {
audio_play_sound(snd_difficultydownER,0,0)
change = 1	
}}


timer -= 1 * (60 / global.maxfps)
if timer < 0 {
textchange += 1
if textchange > 3 {
textchange = 0
}
timer = 150
}

if change = 1 {
y = lerp(y,(room_height/2)+1,-0.07 * (60 / global.maxfps))
if y < -195 { room_goto(r_loading) }
} else {
y = lerp(y,(room_height/2)-50,0.07 * (60 / global.maxfps))
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
draw_text(room_width / 2 + ((changex*dist) * textlayer),y + ((changey*dist) * textlayer),text)
}
draw_set_halign(fa_left)