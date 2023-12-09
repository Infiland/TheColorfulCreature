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
if nexttext = 3 {
if global.deaths = 0 {
audio_play_sound(snd_newhighscore,0,0)	
}}
if nexttext = 4 {
if showhighscore = 1 {
audio_play_sound(snd_newhighscore,0,0)	
}}
timer2 = 100	
}

draw_set_halign(fa_center)
if nexttext = 1 { deaths = 0 }
if nexttext > 0 {
x1 = lerp(x1,0,0.05 * (60 / global.maxfps))
text = loc(664) + " " + string(global.time)
scr_drawmedalendscreen()

draw_set_font(global.completefont)

for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((500 - x1) + ((changex*dist) * textlayer),232 + ((changey*dist) * textlayer),text)
}
}
if nexttext > 1 {
x2 = lerp(x2,0,0.05 * (60 / global.maxfps))
deaths = lerp(deaths,global.deaths,0.04 * (60 / global.maxfps))
text = "Deaths: " + string_format(deaths,0,0)
for(textlayer = 0;textlayer < 5;textlayer++) {
var col_red = 100 + (32 * textlayer)
var col_green = (100 + 32 * textlayer) / (1 + (deaths / 6))
var col_blue = (100 + 32 * textlayer) / (1 + (deaths / 6))
draw_set_color(make_color_rgb(col_red,col_green,col_blue))
draw_text((500 + x2) + ((changex*dist) * textlayer),328 + ((changey*dist) * textlayer),text)
}
}
if nexttext > 2 {
x3 = lerp(x3,0,0.05 * (60 / global.maxfps))
for(textlayer = 0;textlayer < 5;textlayer++) {
if global.cheats = 0 {
if global.deaths < 50 { 
	text = loc(313)
	var col_red = 100 + (32 * textlayer)
	var col_green = 100 + (32 * textlayer)
	var col_blue = 0
	} else {
	text = loc(314)
var col_red = 100 + (32 * textlayer)
var col_blue = 0
var col_green = 0
	}
if global.deaths < 20 { text = loc(312)
	var col_red = 0
	var col_green = 100 + (32 * textlayer)
	var col_blue = 0
	}
if global.deaths < 5 { text = loc(311)
	var col_red = 100 + (32 * textlayer)
	var col_green = 0
	var col_blue = 100 + (32 * textlayer)
	}
if global.deaths = 0 { text = loc(310)
	var col_red = 0
	var col_green = 100 + (32 * textlayer)
	var col_blue = 100 + (32 * textlayer)
	}
} else {
text = loc(315)
var col_red = 100 + (32 * textlayer)
var col_blue = 0
var col_green = 0
}
draw_set_color(make_color_rgb(col_red,col_green,col_blue))
draw_text((500 - x3) + ((changex*dist) * textlayer),424 + ((changey*dist) * textlayer),text)
}
}
if nexttext > 3 {
if showhighscore = 1 {
x4 = lerp(x4,0,0.05 * (60 / global.maxfps))
text = loc(316)
if colorchange = 0 {
colorthingy = lerp(colorthingy,100,0.03 * (60 / global.maxfps))	
if colorthingy > 99 { colorchange = 1 }
}
if colorchange = 1{
colorthingy = lerp(colorthingy,20,0.03 * (60 / global.maxfps))	
if colorthingy < 21 { colorchange = 0 }
}
for(textlayer = 0;textlayer < 5;textlayer++) {
var col_red = colorthingy + (32 * textlayer)
var col_green = colorthingy + (32 * textlayer)
var col_blue = 0
draw_set_color(make_color_rgb(col_red,col_green,col_blue))
draw_text((500 + x4) + ((changex*dist) * textlayer),520 + ((changey*dist) * textlayer),text)
}
}
}

draw_set_halign(fa_left)