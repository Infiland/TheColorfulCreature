function drawhatshop(sprite,pos,cost,hat,ypos) {
var Rpos = pos*120
var costcol = c_white
if cost > global.creditscurrency { costcol = c_red }

var Opos = pos + 9
if pos > Opos { exit }
if pos < -Opos { exit }

if hat != -1 { draw_sprite(sprite,0,455+Rpos,ypos) }
switch(hat) {
case(-1):
draw_sprite(s_lockedhaticon,0,455+Rpos,ypos)
break;
case(0):
draw_sprite(s_creditscurrency,0,460+Rpos,ypos+80)
draw_text_outline(495+Rpos,ypos+75,string(cost),costcol,c_black);
break;
case(1):
draw_sprite_ext(s_levelhud,0,458+Rpos,ypos+65,0.4,0.4,0,c_white,1)
break;
}
}