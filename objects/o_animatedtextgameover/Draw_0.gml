draw_set_font(global.completefont)
var textlayer = 0

draw_set_halign(fa_center)
if nexttext > 0 {
text = loc("TIME") + " " + string(global.time)
if global.workshop = 1 {
scr_drawmedalendscreen()
}
for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((500 - x1) + ((changex*dist) * textlayer),232 + ((changey*dist) * textlayer),text)
}
}
if nexttext > 1 {
text = loc("LIVES_LOST") + ": " + string_format(deaths,0,0)
for(textlayer = 0;textlayer < 5;textlayer++) {
var col_red = 100 + (32 * textlayer)
var col_green = (100 + 32 * textlayer) / (1 + (deaths / 6))
var col_blue = (100 + 32 * textlayer) / (1 + (deaths / 6))
draw_set_color(make_color_rgb(col_red,col_green,col_blue))
draw_text((500 + x2) + ((changex*dist) * textlayer),328 + ((changey*dist) * textlayer),text)
}
}
if nexttext > 2 {
if global.hardmode = 0 {
for(textlayer = 0;textlayer < 5;textlayer++) {
if global.cheats = 0 {
if global.endless = 1 {
var col_red = 0
var col_blue = 100 + (32 * textlayer)
var col_green = 10 + (32 * textlayer)
text = loc("LEVELS_BEATEN") + " " + string_format(levels,0,0)
}

} else {
text = "Cheats were on..."
var col_red = 100 + (32 * textlayer)
var col_blue = 0
var col_green = 0
}
draw_set_color(make_color_rgb(col_red,col_green,col_blue))
draw_text((500 - x3) + ((changex*dist) * textlayer),424 + ((changey*dist) * textlayer),text)
}
}
}

if nexttext > 3 {
if global.endless = 1 {
text = ""
switch(global.endlessrunmode) {
case(1):
if global.newendlesslevelhighscore < global.endlesslevel {
text = loc("NEW_HIGHSCORE")
}
break;
case(2):
if global.endlesslevelhighscore < global.endlesslevel {
text = loc("NEW_HIGHSCORE")
}
break;
}}

if global.hardmode = 1 {
switch(randomtext) {
case(0): text = "Wow you suck!" break;
case(1): text = "Don't give up just yet!" break;
case(2): text = "Pwned!" break;
case(3): text = "You got this!" break;
case(4): text = "Welp, here we go again.." break;
case(5): text = "Why are we still here" break;
case(6): text = "Game over yeaaaaaahh!" break;
case(7): text = "Totally not copying a\ncertain gameover screen" break;
case(8): text = "Lol, you died" break;
case(9): text = "Try again!" break;
case(10): text = "Never give up!" break;
case(11): text = "Unfortunate..." break;
case(12): text = "The end is never The End" break;
case(13): text = "I wonder how many times\nyou saw this gameover screen" break;
case(14): text = "You wi- Just Kidding!" break;
case(15): text = "You seem frustraited" break;
case(16): text = "Take a break" break;
case(17): text = "You'll get it eventually" break;
case(18): text = "Practice requires time" break;
case(19): text = "Keep going!" break;
case(20): text = "Haha stinky!" break;
case(21): text = "Oopsie daisy!" break;
case(22): text = "GOD DAMN IT!" break;
case(23): text = "SO CLOSE!" break;
case(24): text = "RIP!" break;
}}


for(textlayer = 0;textlayer < 5;textlayer++) {
var col_red = colorthingy + (32 * textlayer)
var col_green = colorthingy + (32 * textlayer)
var col_blue = 0
draw_set_color(make_color_rgb(col_red,col_green,col_blue))
draw_text((500 + x4) + ((changex*dist) * textlayer),520 + ((changey*dist) * textlayer),text)
}
}

draw_set_halign(fa_left)