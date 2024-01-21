function scr_hats(){
//Hats
var hat=global.hatselected
if instance_exists(o_playerMU) {
	hat=multiplayerplayerhat
}
color=c_white

var col=global.color
if instance_exists(o_playerMU) {
	col=color
	customhat = 0
}
var xx=16,yy=8,hatspr=s_graduationhat,anim=0,colorhat=c_white,al=1,sx=1;
if os_type = os_android { customhat = 0 }
if customhat = 0 {
if hat = 0 { hatspr = s_graduationhat al = 0 }
switch(hat) {
case(1): hatspr=s_graduationhat anim=0 xx=15 yy=6   break;
case(2): hatspr=s_conehat anim=0 xx=16 yy=6  break;
case(3): hatspr=s_partyhat anim=0 xx=16 yy=6  break;
case(4): hatspr=s_paperhat anim=0 xx=16 yy=6  break;
case(5): hatspr=s_tophat  break;
case(6): hatspr=s_yellowtophat  break;
case(7):
switch(col) {
case(0): colorhat=c_red break;
case(1): colorhat=c_yellow break;
case(2): colorhat=c_lime break;
case(3): colorhat=c_aqua break;
case(4): colorhat=c_white break;
}
hatspr=s_reddiehat  break;
break;
case(8): hatspr=s_santahat  break;
case(9): hatspr=s_witchhat  break;
case(10): hatspr=s_pumpkinhat  break;
case(11): hatspr=s_brownhat  break;
case(12): hatspr=s_grayhat  break;
case(13): hatspr=s_whitehat  break;
case(14): hatspr=s_sunhat  break;
case(15): hatspr=s_redblockhat  break;
case(16): hatspr=s_yellowblockhat  break;
case(17): hatspr=s_greenblockhat  break;
case(18): hatspr=s_blueblockhat  break;
case(19): hatspr=s_whiteblockhat  break;
case(20): hatspr=s_spikehat  break;
case(21): hatspr=s_spikehat al=0.5 break;
case(22): hatspr=s_spikehat  colorhat=c_lime break;
case(23): hatspr=s_spikehat  colorhat=c_yellow break;
case(24): hatspr=s_hexagonhat  break;
case(25): hatspr=s_breadhat  break;
case(26): hatspr=s_soldierhat  sx=1.2 break;
case(27): hatspr=s_samuraihat  break;
case(28): hatspr=s_redbeaniehat  break;
case(29): hatspr=s_yellowbeaniehat  break;
case(30): hatspr=s_greenbeaniehat  break;
case(31): hatspr=s_bluebeaniehat  break;
case(32): hatspr=s_whitebeaniehat  break;
case(33): hatspr=s_piratehat  break;
case(34): hatspr=s_pinkbowtiehat  break;
case(35): hatspr=s_kingshat  break;
case(36): hatspr=s_hairhat  break;
case(37): hatspr=s_comradehat  break;
case(38): hatspr=s_vikinghat  break;
case(39): hatspr=s_cowboyhat  break;
case(40): hatspr=s_redsushat  break;
case(41): hatspr=s_yellowsushat  break;
case(42): hatspr=s_greensushat  break;
case(43): hatspr=s_bluesushat  break;
case(44): hatspr=s_whitesushat  break;
case(45): hatspr=s_flowerhat  break;
case(46): hatspr=s_propellerhat
if zerogrv = 0 {
draw_sprite_ext(s_propellerhattop,current_time/30,x+xx,y+yy-18,sx,1,image_angle,colorhat,al)
} else {
	xx = lengthdir_x(30,image_angle+90)
	yy = lengthdir_y(30,image_angle+90)
	draw_sprite_ext(s_propellerhattop,current_time/30,x+xx,y+yy,sx,1,image_angle,colorhat,al) 
	}
break;
case(47): hatspr=s_serbianhat break;
case(48): hatspr=s_rathat break;
case(49): hatspr=s_germanhat break;
case(50): hatspr=s_frenchhat break;
case(51): hatspr=s_italianhat break;
case(52): hatspr=s_spanishhat break;
case(53): hatspr=s_magyarhat break;
case(54): hatspr=s_bosnianhat break;
case(55): hatspr=s_chinesehat break;
case(56): hatspr=s_ukrainianhat break;
case(57): hatspr=s_macedonianhat break;
case(58): hatspr=s_chickenhat break;
case(59): hatspr=s_czechhat break;
case(60): hatspr=s_russianhat break;
case(61): hatspr=s_devilhat break;
case(62): hatspr=s_turkishhat break;
case(63): hatspr=s_palestinianhat break;
}

curhat = hatspr
if zerogrv = 0 {
if hat != 0 {
draw_sprite_ext(curhat,anim,x+xx,y+yy,sx,1,image_angle,colorhat,al)
}
} else {
	if hat != 0 {
xx = lengthdir_x(12,image_angle+90)
yy = lengthdir_y(12,image_angle+90)
	draw_sprite_ext(curhat,anim,x+xx,y+yy,sx,1,image_angle,colorhat,al) }
}
} else {
	draw_sprite_ext(curhat,anim,x+xx,y+yy,hatxscale,hatyscale,image_angle,colorhat,al)
}

}