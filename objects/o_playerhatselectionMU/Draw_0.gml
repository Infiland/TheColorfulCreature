if global.chooseminigameMU = false {
if global.multiplayerplayerconfigchoose = 1 {
spritedistance = -global.multiplayerplayerhat[0] * 120
}
if global.multiplayerplayerconfigchoose = 2 {
spritedistance = -global.multiplayerplayerhat[1] * 120
}
if global.multiplayerplayerconfigchoose = 3 {
spritedistance = -global.multiplayerplayerhat[2] * 120
}
if global.multiplayerplayerconfigchoose = 4 {
spritedistance = -global.multiplayerplayerhat[3] * 120
}
realspritedistance = lerp(realspritedistance,spritedistance,0.2 * (60 / global.maxfps))
	draw_sprite_ext(s_liquidarrow,0,490,320,1,arrowyscale,0,c_white,1)
	draw_rectangle_color(0,205,1024,320,c_black,c_black,c_black,c_black,false)
	if arrowyscale > 1 {
	change = 0
	}
	if arrowyscale < 0.9 {
	change = 1
	}
	if change = 0 { arrowyscale = lerp(arrowyscale,0.89,0.1 * (60 / global.maxfps)) } else { arrowyscale = lerp(arrowyscale,1.01,0.1 * (60 / global.maxfps)) }
draw_sprite(s_nohaticon,0,455+realspritedistance,205)
if global.hat[1] < 1 { draw_sprite(s_lockedhaticon,0,575+realspritedistance,205) } else {
draw_sprite(s_graduationhaticon,0,575+realspritedistance,205) }
if global.hat[2] < 1 { draw_sprite(s_lockedhaticon,0,695+realspritedistance,205) } else {
draw_sprite(s_conehaticon,0,695+realspritedistance,205) }
if global.hat[3] < 1 { draw_sprite(s_lockedhaticon,0,815+realspritedistance,205) } else {
draw_sprite(s_partyhaticon,0,815+realspritedistance,205) }
if global.hat[4] < 1 { draw_sprite(s_lockedhaticon,0,935+realspritedistance,205) } else {
draw_sprite(s_paperhaticon,0,935+realspritedistance,205) }
if global.hat[5] < 1 { draw_sprite(s_lockedhaticon,0,1055+realspritedistance,205) } else {
draw_sprite(s_tophaticon,0,1055+realspritedistance,205) }
if global.hat[6] < 1 { draw_sprite(s_lockedhaticon,0,1175+realspritedistance,205) } else {
draw_sprite(s_yellowtophaticon,0,1175+realspritedistance,205) }
if global.hat[7] < 1 { draw_sprite(s_lockedhaticon,0,1295+realspritedistance,205) } else {
draw_sprite(s_reddiehaticon,0,1295+realspritedistance,205) }
if global.hat[8] < 1 { draw_sprite(s_lockedhaticon,0,1415+realspritedistance,205) } else {
draw_sprite(s_christmashaticon,0,1415+realspritedistance,205) }
if global.hat[9] < 1 { draw_sprite(s_lockedhaticon,0,1535+realspritedistance,205) } else {
draw_sprite(s_witchhaticon,0,1535+realspritedistance,205) }
if global.hat[10] < 1 { draw_sprite(s_lockedhaticon,0,1655+realspritedistance,205) } else {
draw_sprite(s_pumpkinhaticon,0,1655+realspritedistance,205) }
if global.hat[11] < 1 { draw_sprite(s_lockedhaticon,0,1775+realspritedistance,205) } else {
draw_sprite(s_brownhaticon,0,1775+realspritedistance,205) }
if global.hat[12] < 1 { draw_sprite(s_lockedhaticon,0,1895+realspritedistance,205) } else {
draw_sprite(s_grayhaticon,0,1895+realspritedistance,205) }
if global.hat[13] < 1 { draw_sprite(s_lockedhaticon,0,2015+realspritedistance,205) } else {
draw_sprite(s_whitehaticon,0,2015+realspritedistance,205) }
if global.hat[14] < 1 { draw_sprite(s_lockedhaticon,0,2135+realspritedistance,205) } else {
draw_sprite(s_sunhaticon,0,2135+realspritedistance,205) }
if global.hat[15] < 1 { draw_sprite(s_lockedhaticon,0,2255+realspritedistance,205) } else {
draw_sprite(s_redblockhaticon,0,2255+realspritedistance,205) }
if global.hat[16] < 1 { draw_sprite(s_lockedhaticon,0,2375+realspritedistance,205) } else {
draw_sprite(s_yellowblockhaticon,0,2375+realspritedistance,205) }
if global.hat[17] < 1 { draw_sprite(s_lockedhaticon,0,2495+realspritedistance,205) } else {
draw_sprite(s_greenblockhaticon,0,2495+realspritedistance,205) }
if global.hat[18] < 1 { draw_sprite(s_lockedhaticon,0,2615+realspritedistance,205) } else {
draw_sprite(s_blueblockhaticon,0,2615+realspritedistance,205) }
if global.hat[19] < 1 { draw_sprite(s_lockedhaticon,0,2735+realspritedistance,205) } else {
draw_sprite(s_whiteblockhaticon,0,2735+realspritedistance,205) }
if global.hat[20] < 1 { draw_sprite(s_lockedhaticon,0,2855+realspritedistance,205) } else {
draw_sprite(s_spikehaticon,0,2855+realspritedistance,205) }
if global.hat[21] < 1 { draw_sprite(s_lockedhaticon,0,2975+realspritedistance,205) } else {
draw_sprite(s_invisiblespikehaticon,0,2975+realspritedistance,205) }
if global.hat[22] < 1 { draw_sprite(s_lockedhaticon,0,3095+realspritedistance,205) } else {
draw_sprite(s_Vspikehaticon,0,3095+realspritedistance,205) }
if global.hat[23] < 1 { draw_sprite(s_lockedhaticon,0,3215+realspritedistance,205) } else {
draw_sprite(s_Hspikehaticon,0,3215+realspritedistance,205) }
if global.hat[24] < 1 { draw_sprite(s_lockedhaticon,0,3335+realspritedistance,205) } else {
draw_sprite(s_hexagonhaticon,0,3335+realspritedistance,205) }
if global.hat[25] < 1 { draw_sprite(s_lockedhaticon,0,3455+realspritedistance,205) } else {
draw_sprite(s_breadhaticon,0,3455+realspritedistance,205) }
if global.hat[26] < 1 { draw_sprite(s_lockedhaticon,0,3575+realspritedistance,205) } else {
draw_sprite(s_soldierhaticon,0,3575+realspritedistance,205) }
if global.hat[27] < 1 { draw_sprite(s_lockedhaticon,0,3695+realspritedistance,205) } else {
draw_sprite(s_samuraihaticon,0,3695+realspritedistance,205) }
if global.hat[28] < 1 { draw_sprite(s_lockedhaticon,0,3815+realspritedistance,205) } else {
draw_sprite(s_redbeaniehaticon,0,3815+realspritedistance,205) }
if global.hat[29] < 1 { draw_sprite(s_lockedhaticon,0,3935+realspritedistance,205) } else {
draw_sprite(s_yellowbeaniehaticon,0,3935+realspritedistance,205) }
if global.hat[30] < 1 { draw_sprite(s_lockedhaticon,0,4055+realspritedistance,205) } else {
draw_sprite(s_greenbeaniehaticon,0,4055+realspritedistance,205) }
if global.hat[31] < 1 { draw_sprite(s_lockedhaticon,0,4175+realspritedistance,205) } else {
draw_sprite(s_bluebeaniehaticon,0,4175+realspritedistance,205) }
if global.hat[32] < 1 { draw_sprite(s_lockedhaticon,0,4295+realspritedistance,205) } else {
draw_sprite(s_whitebeaniehaticon,0,4295+realspritedistance,205) }
if global.hat[33] < 1 { draw_sprite(s_lockedhaticon,0,4415+realspritedistance,205) } else {
draw_sprite(s_piratehaticon,0,4415+realspritedistance,205) }
if global.hat[34] < 1 { draw_sprite(s_lockedhaticon,0,4535+realspritedistance,205) } else {
draw_sprite(s_pinkbowtiehaticon,0,4535+realspritedistance,205) }
if global.hat[35] < 1 { draw_sprite(s_lockedhaticon,0,4655+realspritedistance,205) } else {
draw_sprite(s_kinghaticon,0,4655+realspritedistance,205) }
if global.hat[36] < 1 { draw_sprite(s_lockedhaticon,0,4775+realspritedistance,205) } else {
draw_sprite(s_hairhaticon,0,4775+realspritedistance,205) }
if global.hat[37] < 1 { draw_sprite(s_lockedhaticon,0,4895+realspritedistance,205) } else {
draw_sprite(s_comradehaticon,0,4895+realspritedistance,205) }
if global.hat[38] < 1 { draw_sprite(s_lockedhaticon,0,5015+realspritedistance,205) } else {
draw_sprite(s_vikinghaticon,0,5015+realspritedistance,205) }
if global.hat[39] < 1 { draw_sprite(s_lockedhaticon,0,5135+realspritedistance,205) } else {
draw_sprite(s_cowboyhaticon,0,5135+realspritedistance,205) }
if global.hat[40] < 1 { draw_sprite(s_lockedhaticon,0,5255+realspritedistance,205) } else {
draw_sprite(s_cowboyhaticon,0,5255+realspritedistance,205) }
if global.hat[41] < 1 { draw_sprite(s_lockedhaticon,0,5375+realspritedistance,205) } else {
draw_sprite(s_redsushaticon,0,5375+realspritedistance,205) }
if global.hat[42] < 1 { draw_sprite(s_lockedhaticon,0,5495+realspritedistance,205) } else {
draw_sprite(s_yellowsushaticon,0,5495+realspritedistance,205) }
if global.hat[43] < 1 { draw_sprite(s_lockedhaticon,0,5615+realspritedistance,205) } else {
draw_sprite(s_greensushaticon,0,5615+realspritedistance,205) }
if global.hat[44] < 1 { draw_sprite(s_lockedhaticon,0,5735+realspritedistance,205) } else {
draw_sprite(s_bluesushaticon,0,5735+realspritedistance,205) }
if global.hat[45] < 1 { draw_sprite(s_lockedhaticon,0,5855+realspritedistance,205) } else {
draw_sprite(s_whitesushaticon,0,5855+realspritedistance,205) }
if global.hat[46] < 1 { draw_sprite(s_lockedhaticon,0,5975+realspritedistance,205) } else {
draw_sprite(s_flowerhaticon,0,5975+realspritedistance,205) }

draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}