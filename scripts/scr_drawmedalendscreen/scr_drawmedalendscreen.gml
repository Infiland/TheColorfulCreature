function scr_drawmedalendscreen(){
	
if global.workshop = 1 {
global.DiamondMedalTimeChallenge = global.LEDiamondMedalTime
}
var dmedal = global.DiamondMedalTimeChallenge
	
var gmedal = dmedal * 1.1
var smedal = gmedal * 1.2
var bmedal = smedal * 1.3
var spr_num = 3

if global.time < bmedal { spr_num = 0 }
if global.time < smedal { spr_num = 1 }
if global.time < gmedal { spr_num = 2 }
if global.time < dmedal { spr_num = 3 }

	if global.time < bmedal { 
	draw_sprite_ext(s_medals,spr_num,(510 - x1) - (10 - string_width(text)),247,0.1,0.1,0,c_white,1)
 }
 draw_set_font(global.coolfont)
 var timedifference = dmedal - global.time
 var timestr = "+"
 if timedifference < 0 {
	draw_set_color(c_red)
 } else { 
	 draw_set_color(c_lime)
	 timestr = "-" }
	 draw_set_halign(fa_center)
	 var actualdifference = abs(timedifference)
	 
 draw_text((660 - x1)- (10 - string_width(text)),307,string(timestr) + string(actualdifference))
 
}