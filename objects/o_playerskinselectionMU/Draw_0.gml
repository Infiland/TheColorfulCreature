if global.chooseminigameMU = false {
if global.multiplayerplayerconfigchoose = 1 {
spritedistance = -global.multiplayerplayerskin[0] * 120
}
if global.multiplayerplayerconfigchoose = 2 {
spritedistance = -global.multiplayerplayerskin[1] * 120
}
if global.multiplayerplayerconfigchoose = 3 {
spritedistance = -global.multiplayerplayerskin[2] * 120
}
if global.multiplayerplayerconfigchoose = 4 {
spritedistance = -global.multiplayerplayerskin[3] * 120
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
draw_sprite(s_normalskinbutton,0,455+realspritedistance,205)
if global.skin[3] = 0 {
	draw_sprite(s_lockedskinicon,0,575+realspritedistance,205) } else {
draw_sprite(s_madskinbutton,0,575+realspritedistance,205) }
if global.skin[2] = 0 { draw_sprite(s_lockedskinicon,0,695+realspritedistance,205) } else {
draw_sprite(s_kaizoskinbutton,0,695+realspritedistance,205) }
if global.skin[4] = 0 { draw_sprite(s_lockedskinicon,0,815+realspritedistance,205) } else {
draw_sprite(s_blindskinbutton,0,815+realspritedistance,205) }
if global.skin[5] = 0 { draw_sprite(s_lockedskinicon,0,935+realspritedistance,205) } else {
draw_sprite(s_sadskinbutton,0,935+realspritedistance,205) }
if global.skin[6] = 0 { draw_sprite(s_lockedskinicon,0,1055+realspritedistance,205) } else {
draw_sprite(s_blockskinbutton,0,1055+realspritedistance,205) }
if global.skin[7] = 0 { draw_sprite(s_lockedskinicon,0,1175+realspritedistance,205) } else {
draw_sprite(s_hdskinbutton,0,1175+realspritedistance,205) }
if global.skin[8] = 0 { draw_sprite(s_lockedskinicon,0,1295+realspritedistance,205) } else {
draw_sprite(s_rewardedskinbutton,0,1295+realspritedistance,205) }
if global.skin[9] = 0 { draw_sprite(s_lockedskinicon,0,1415+realspritedistance,205) } else {
draw_sprite(s_angryskinbutton,0,1415+realspritedistance,205) }
if global.skin[10] = 0 { draw_sprite(s_lockedskinicon,0,1535+realspritedistance,205) } else {
draw_sprite(s_coolskinbutton,0,1535+realspritedistance,205) }
if global.skin[11] = 0 { draw_sprite(s_lockedskinicon,0,1655+realspritedistance,205) } else {
draw_sprite(s_darkknightskinbutton,0,1655+realspritedistance,205) }
if global.skin[12] = 0 { draw_sprite(s_lockedskinicon,0,1775+realspritedistance,205) } else {
draw_sprite(s_richskinbutton,0,1775+realspritedistance,205) }
if global.skin[13] = 0 { draw_sprite(s_lockedskinicon,0,1895+realspritedistance,205) } else {
draw_sprite(s_goldplayerskinbutton,0,1895+realspritedistance,205) }
if global.skin[14] = 0 { draw_sprite(s_lockedskinicon,0,2015+realspritedistance,205) } else {
draw_sprite(s_frozenskinbutton,0,2015+realspritedistance,205) }
if global.skin[15] = 0 { draw_sprite(s_lockedskinicon,0,2135+realspritedistance,205) } else {
draw_sprite(s_kindadeadskinbutton,0,2135+realspritedistance,205) }
if global.skin[16] = 0 { draw_sprite(s_lockedskinicon,0,2255+realspritedistance,205) } else {
draw_sprite(s_coronaskinbutton,0,2255+realspritedistance,205) }
if global.skin[17] = 0 { draw_sprite(s_lockedskinicon,0,2375+realspritedistance,205) } else {
draw_sprite(s_canadianskinbutton,0,2375+realspritedistance,205) }
if global.skin[18] = 0 { draw_sprite(s_lockedskinicon,0,2495+realspritedistance,205) } else {
draw_sprite(s_hazardousskinbutton,0,2495+realspritedistance,205) }
if global.skin[19] = 0 { draw_sprite(s_lockedskinicon,0,2615+realspritedistance,205) } else {
draw_sprite(s_babyskinbutton,0,2615+realspritedistance,205) }
if global.skin[20] = 0 { draw_sprite(s_lockedskinicon,0,2735+realspritedistance,205) } else {
draw_sprite(s_hexagonskinbutton,0,2735+realspritedistance,205) }
if global.skin[21] = 0 { draw_sprite(s_lockedskinicon,0,2855+realspritedistance,205) } else {
draw_sprite(s_tuxedoskinbutton,0,2855+realspritedistance,205) }
if global.skin[22] = 0 { draw_sprite(s_lockedskinicon,0,2975+realspritedistance,205) } else {
draw_sprite(s_normalskinbutton,0,2975+realspritedistance,205) }
if global.skin[23] = 0 { draw_sprite(s_lockedskinicon,0,3095+realspritedistance,205) } else {
draw_sprite(s_waterskinbutton,0,3095+realspritedistance,205) }
if global.skin[24] = 0 { draw_sprite(s_lockedskinicon,0,3215+realspritedistance,205) } else {
draw_sprite(s_forsenEskinbutton,0,3215+realspritedistance,205) }
if global.skin[25] = 0 { draw_sprite(s_lockedskinicon,0,3335+realspritedistance,205) } else {
draw_sprite(s_redballskinbutton,0,3335+realspritedistance,205) }
if global.skin[26] = 0 { draw_sprite(s_lockedskinicon,0,3455+realspritedistance,205) } else {
draw_sprite(s_bomberskinbutton,0,3455+realspritedistance,205) }
if global.skin[27] = 0 { draw_sprite(s_lockedskinicon,0,3575+realspritedistance,205) } else {
draw_sprite(s_hitboxskinbutton,0,3575+realspritedistance,205) }
if global.skin[28] = 0 { draw_sprite(s_lockedskinicon,0,3695+realspritedistance,205) } else {
draw_sprite(s_metallicskinbutton,0,3695+realspritedistance,205) }
if global.skin[29] = 0 { draw_sprite(s_lockedskinicon,0,3815+realspritedistance,205) } else {
draw_sprite(s_monocleskinbutton,0,3815+realspritedistance,205) }
if global.skin[30] = 0 { draw_sprite(s_lockedskinicon,0,3935+realspritedistance,205) } else {
draw_sprite(s_japaneseskinbutton,0,3935+realspritedistance,205) }
if global.skin[31] = 0 { draw_sprite(s_lockedskinicon,0,4055+realspritedistance,205) } else {
draw_sprite(s_googlyskinbutton,0,4055+realspritedistance,205) }
if global.skin[32] = 0 { draw_sprite(s_lockedskinicon,0,4175+realspritedistance,205) } else {
draw_sprite(s_upsidedownskinbutton,0,4175+realspritedistance,205) }
if global.skin[33] = 0 { draw_sprite(s_lockedskinicon,0,4295+realspritedistance,205) } else {
draw_sprite(s_spiralskinbutton,0,4295+realspritedistance,205) }
if global.skin[34] = 0 { draw_sprite(s_lockedskinicon,0,4415+realspritedistance,205) } else {
draw_sprite(s_heartskinbutton,0,4415+realspritedistance,205) }
if global.skin[35] = 0 { draw_sprite(s_lockedskinicon,0,4535+realspritedistance,205) } else {
draw_sprite(s_clockskinbutton,0,4535+realspritedistance,205) }
if global.skin[36] = 0 { draw_sprite(s_lockedskinicon,0,4655+realspritedistance,205) } else {
draw_sprite(s_invisibleskinbutton,0,4655+realspritedistance,205) }
if global.skin[37] = 0 { draw_sprite(s_lockedskinicon,0,4775+realspritedistance,205) } else {
draw_sprite(s_arrowskinbutton,0,4775+realspritedistance,205) }
if global.skin[38] = 0 { draw_sprite(s_lockedskinicon,0,4895+realspritedistance,205) } else {
draw_sprite(s_spikeskinbutton,0,4895+realspritedistance,205) }
if global.skin[39] = 0 { draw_sprite(s_lockedskinicon,0,5015+realspritedistance,205) } else {
draw_sprite(s_splitskinbutton,0,5015+realspritedistance,205) }
if global.skin[40] = 0 { draw_sprite(s_lockedskinicon,0,5135+realspritedistance,205) } else {
draw_sprite(s_pirateskinbutton,0,5135+realspritedistance,205) }
if global.skin[41] = 0 { draw_sprite(s_lockedskinicon,0,5255+realspritedistance,205) } else {
draw_sprite(s_scifiskinbutton,0,5255+realspritedistance,205) }
if global.skin[42] = 0 { draw_sprite(s_lockedskinicon,0,5375+realspritedistance,205) } else {
draw_sprite(s_gordonskinbutton,0,5375+realspritedistance,205) }
if global.skin[43] = 0 { draw_sprite(s_lockedskinicon,0,5495+realspritedistance,205) } else {
draw_sprite(s_fancyskinbutton,0,5495+realspritedistance,205) }
if global.skin[44] = 0 { draw_sprite(s_lockedskinicon,0,5615+realspritedistance,205) } else {
draw_sprite(s_steamskinbutton,0,5615+realspritedistance,205) }
if global.skin[45] = 0 { draw_sprite(s_lockedskinicon,0,5735+realspritedistance,205) } else {
draw_sprite(s_breakableskinbutton,0,5735+realspritedistance,205) }
if global.skin[46] = 0 { draw_sprite(s_lockedskinicon,0,5855+realspritedistance,205) } else {
draw_sprite(s_smileyskinbutton,0,5855+realspritedistance,205) }
if global.skin[47] = 0 { draw_sprite(s_lockedskinicon,0,5975+realspritedistance,205) } else {
draw_sprite(s_maidskinbutton,0,5975+realspritedistance,205) }
draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}