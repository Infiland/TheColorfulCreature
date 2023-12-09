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
if global.hat001 < 1 { draw_sprite(s_lockedhaticon,0,575+realspritedistance,205) } else {
draw_sprite(s_graduationhaticon,0,575+realspritedistance,205) }
if global.hat002 < 1 { draw_sprite(s_lockedhaticon,0,695+realspritedistance,205) } else {
draw_sprite(s_conehaticon,0,695+realspritedistance,205) }
if global.hat003 < 1 { draw_sprite(s_lockedhaticon,0,815+realspritedistance,205) } else {
draw_sprite(s_partyhaticon,0,815+realspritedistance,205) }
if global.hat004 < 1 { draw_sprite(s_lockedhaticon,0,935+realspritedistance,205) } else {
draw_sprite(s_paperhaticon,0,935+realspritedistance,205) }
if global.hat005 < 1 { draw_sprite(s_lockedhaticon,0,1055+realspritedistance,205) } else {
draw_sprite(s_tophaticon,0,1055+realspritedistance,205) }
if global.hat006 < 1 { draw_sprite(s_lockedhaticon,0,1175+realspritedistance,205) } else {
draw_sprite(s_yellowtophaticon,0,1175+realspritedistance,205) }
if global.hat007 < 1 { draw_sprite(s_lockedhaticon,0,1295+realspritedistance,205) } else {
draw_sprite(s_reddiehaticon,0,1295+realspritedistance,205) }
if global.hat008 < 1 { draw_sprite(s_lockedhaticon,0,1415+realspritedistance,205) } else {
draw_sprite(s_christmashaticon,0,1415+realspritedistance,205) }
if global.hat009 < 1 { draw_sprite(s_lockedhaticon,0,1535+realspritedistance,205) } else {
draw_sprite(s_witchhaticon,0,1535+realspritedistance,205) }
if global.hat010 < 1 { draw_sprite(s_lockedhaticon,0,1655+realspritedistance,205) } else {
draw_sprite(s_pumpkinhaticon,0,1655+realspritedistance,205) }
if global.hat011 < 1 { draw_sprite(s_lockedhaticon,0,1775+realspritedistance,205) } else {
draw_sprite(s_brownhaticon,0,1775+realspritedistance,205) }
if global.hat012 < 1 { draw_sprite(s_lockedhaticon,0,1895+realspritedistance,205) } else {
draw_sprite(s_grayhaticon,0,1895+realspritedistance,205) }
if global.hat013 < 1 { draw_sprite(s_lockedhaticon,0,2015+realspritedistance,205) } else {
draw_sprite(s_whitehaticon,0,2015+realspritedistance,205) }
if global.hat014 < 1 { draw_sprite(s_lockedhaticon,0,2135+realspritedistance,205) } else {
draw_sprite(s_sunhaticon,0,2135+realspritedistance,205) }
if global.hat015 < 1 { draw_sprite(s_lockedhaticon,0,2255+realspritedistance,205) } else {
draw_sprite(s_redblockhaticon,0,2255+realspritedistance,205) }
if global.hat016 < 1 { draw_sprite(s_lockedhaticon,0,2375+realspritedistance,205) } else {
draw_sprite(s_yellowblockhaticon,0,2375+realspritedistance,205) }
if global.hat017 < 1 { draw_sprite(s_lockedhaticon,0,2495+realspritedistance,205) } else {
draw_sprite(s_greenblockhaticon,0,2495+realspritedistance,205) }
if global.hat018 < 1 { draw_sprite(s_lockedhaticon,0,2615+realspritedistance,205) } else {
draw_sprite(s_blueblockhaticon,0,2615+realspritedistance,205) }
if global.hat019 < 1 { draw_sprite(s_lockedhaticon,0,2735+realspritedistance,205) } else {
draw_sprite(s_whiteblockhaticon,0,2735+realspritedistance,205) }
if global.hat020 < 1 { draw_sprite(s_lockedhaticon,0,2855+realspritedistance,205) } else {
draw_sprite(s_spikehaticon,0,2855+realspritedistance,205) }
if global.hat021 < 1 { draw_sprite(s_lockedhaticon,0,2975+realspritedistance,205) } else {
draw_sprite(s_invisiblespikehaticon,0,2975+realspritedistance,205) }
if global.hat022 < 1 { draw_sprite(s_lockedhaticon,0,3095+realspritedistance,205) } else {
draw_sprite(s_Vspikehaticon,0,3095+realspritedistance,205) }
if global.hat023 < 1 { draw_sprite(s_lockedhaticon,0,3215+realspritedistance,205) } else {
draw_sprite(s_Hspikehaticon,0,3215+realspritedistance,205) }
if global.hat024 < 1 { draw_sprite(s_lockedhaticon,0,3335+realspritedistance,205) } else {
draw_sprite(s_hexagonhaticon,0,3335+realspritedistance,205) }
if global.hat025 < 1 { draw_sprite(s_lockedhaticon,0,3455+realspritedistance,205) } else {
draw_sprite(s_breadhaticon,0,3455+realspritedistance,205) }
if global.hat026 < 1 { draw_sprite(s_lockedhaticon,0,3575+realspritedistance,205) } else {
draw_sprite(s_soldierhaticon,0,3575+realspritedistance,205) }
if global.hat027 < 1 { draw_sprite(s_lockedhaticon,0,3695+realspritedistance,205) } else {
draw_sprite(s_samuraihaticon,0,3695+realspritedistance,205) }
if global.hat028 < 1 { draw_sprite(s_lockedhaticon,0,3815+realspritedistance,205) } else {
draw_sprite(s_redbeaniehaticon,0,3815+realspritedistance,205) }
if global.hat029 < 1 { draw_sprite(s_lockedhaticon,0,3935+realspritedistance,205) } else {
draw_sprite(s_yellowbeaniehaticon,0,3935+realspritedistance,205) }
if global.hat030 < 1 { draw_sprite(s_lockedhaticon,0,4055+realspritedistance,205) } else {
draw_sprite(s_greenbeaniehaticon,0,4055+realspritedistance,205) }
if global.hat031 < 1 { draw_sprite(s_lockedhaticon,0,4175+realspritedistance,205) } else {
draw_sprite(s_bluebeaniehaticon,0,4175+realspritedistance,205) }
if global.hat032 < 1 { draw_sprite(s_lockedhaticon,0,4295+realspritedistance,205) } else {
draw_sprite(s_whitebeaniehaticon,0,4295+realspritedistance,205) }
if global.hat033 < 1 { draw_sprite(s_lockedhaticon,0,4415+realspritedistance,205) } else {
draw_sprite(s_piratehaticon,0,4415+realspritedistance,205) }
if global.hat034 < 1 { draw_sprite(s_lockedhaticon,0,4535+realspritedistance,205) } else {
draw_sprite(s_pinkbowtiehaticon,0,4535+realspritedistance,205) }
if global.hat035 < 1 { draw_sprite(s_lockedhaticon,0,4655+realspritedistance,205) } else {
draw_sprite(s_kinghaticon,0,4655+realspritedistance,205) }
if global.hat036 < 1 { draw_sprite(s_lockedhaticon,0,4775+realspritedistance,205) } else {
draw_sprite(s_hairhaticon,0,4775+realspritedistance,205) }
if global.hat037 < 1 { draw_sprite(s_lockedhaticon,0,4895+realspritedistance,205) } else {
draw_sprite(s_comradehaticon,0,4895+realspritedistance,205) }
if global.hat038 < 1 { draw_sprite(s_lockedhaticon,0,5015+realspritedistance,205) } else {
draw_sprite(s_vikinghaticon,0,5015+realspritedistance,205) }
if global.hat039 < 1 { draw_sprite(s_lockedhaticon,0,5135+realspritedistance,205) } else {
draw_sprite(s_cowboyhaticon,0,5135+realspritedistance,205) }
if global.hat040 < 1 { draw_sprite(s_lockedhaticon,0,5255+realspritedistance,205) } else {
draw_sprite(s_cowboyhaticon,0,5255+realspritedistance,205) }
if global.hat041 < 1 { draw_sprite(s_lockedhaticon,0,5375+realspritedistance,205) } else {
draw_sprite(s_redsushaticon,0,5375+realspritedistance,205) }
if global.hat042 < 1 { draw_sprite(s_lockedhaticon,0,5495+realspritedistance,205) } else {
draw_sprite(s_yellowsushaticon,0,5495+realspritedistance,205) }
if global.hat043 < 1 { draw_sprite(s_lockedhaticon,0,5615+realspritedistance,205) } else {
draw_sprite(s_greensushaticon,0,5615+realspritedistance,205) }
if global.hat044 < 1 { draw_sprite(s_lockedhaticon,0,5735+realspritedistance,205) } else {
draw_sprite(s_bluesushaticon,0,5735+realspritedistance,205) }
if global.hat045 < 1 { draw_sprite(s_lockedhaticon,0,5855+realspritedistance,205) } else {
draw_sprite(s_whitesushaticon,0,5855+realspritedistance,205) }
if global.hat046 < 1 { draw_sprite(s_lockedhaticon,0,5975+realspritedistance,205) } else {
draw_sprite(s_flowerhaticon,0,5975+realspritedistance,205) }

draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}