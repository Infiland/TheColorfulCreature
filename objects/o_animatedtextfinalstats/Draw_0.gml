var textlayer = 0

draw_set_halign(fa_center)
if nexttext > 0 {
text = loc("TIME") + " " + string(global.time)
scr_drawmedalendscreen()

draw_set_font(global.completefont)

for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((500 - x1) + ((changex*dist) * textlayer),232 + ((changey*dist) * textlayer),text)
}
}
if nexttext > 1 {
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
for(textlayer = 0;textlayer < 5;textlayer++) {
if global.cheats = 0 {
if global.deaths < 50 { 
	text = loc("MEDIOCRE")
	var col_red = 100 + (32 * textlayer)
	var col_green = 100 + (32 * textlayer)
	var col_blue = 0
	} else {
	text = loc("TERRIBLE")
var col_red = 100 + (32 * textlayer)
var col_blue = 0
var col_green = 0
	}
if global.deaths < 20 { text = loc("GOOD_JOB")
	var col_red = 0
	var col_green = 100 + (32 * textlayer)
	var col_blue = 0
	}
if global.deaths < 5 { text = loc("EPIC")
	var col_red = 100 + (32 * textlayer)
	var col_green = 0
	var col_blue = 100 + (32 * textlayer)
	}
if global.deaths = 0 { text = loc("PERFECT")
	var col_red = 0
	var col_green = 100 + (32 * textlayer)
	var col_blue = 100 + (32 * textlayer)
	}
} else {
text = loc("CHEATS_WERE_ON")
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
text = loc("NEW_HIGHSCORE")

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