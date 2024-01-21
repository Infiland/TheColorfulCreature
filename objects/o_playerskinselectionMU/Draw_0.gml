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
if global.skin003 = 0 {
	draw_sprite(s_lockedskinicon,0,575+realspritedistance,205) } else {
draw_sprite(s_madskinbutton,0,575+realspritedistance,205) }
if global.skin002 = 0 { draw_sprite(s_lockedskinicon,0,695+realspritedistance,205) } else {
draw_sprite(s_kaizoskinbutton,0,695+realspritedistance,205) }
if global.skin004 = 0 { draw_sprite(s_lockedskinicon,0,815+realspritedistance,205) } else {
draw_sprite(s_blindskinbutton,0,815+realspritedistance,205) }
if global.skin005 = 0 { draw_sprite(s_lockedskinicon,0,935+realspritedistance,205) } else {
draw_sprite(s_sadskinbutton,0,935+realspritedistance,205) }
if global.skin006 = 0 { draw_sprite(s_lockedskinicon,0,1055+realspritedistance,205) } else {
draw_sprite(s_blockskinbutton,0,1055+realspritedistance,205) }
if global.skin007 = 0 { draw_sprite(s_lockedskinicon,0,1175+realspritedistance,205) } else {
draw_sprite(s_hdskinbutton,0,1175+realspritedistance,205) }
if global.skin008 = 0 { draw_sprite(s_lockedskinicon,0,1295+realspritedistance,205) } else {
draw_sprite(s_rewardedskinbutton,0,1295+realspritedistance,205) }
if global.skin009 = 0 { draw_sprite(s_lockedskinicon,0,1415+realspritedistance,205) } else {
draw_sprite(s_angryskinbutton,0,1415+realspritedistance,205) }
if global.skin010 = 0 { draw_sprite(s_lockedskinicon,0,1535+realspritedistance,205) } else {
draw_sprite(s_coolskinbutton,0,1535+realspritedistance,205) }
if global.skin011 = 0 { draw_sprite(s_lockedskinicon,0,1655+realspritedistance,205) } else {
draw_sprite(s_darkknightskinbutton,0,1655+realspritedistance,205) }
if global.skin012 = 0 { draw_sprite(s_lockedskinicon,0,1775+realspritedistance,205) } else {
draw_sprite(s_richskinbutton,0,1775+realspritedistance,205) }
if global.skin013 = 0 { draw_sprite(s_lockedskinicon,0,1895+realspritedistance,205) } else {
draw_sprite(s_goldplayerskinbutton,0,1895+realspritedistance,205) }
if global.skin014 = 0 { draw_sprite(s_lockedskinicon,0,2015+realspritedistance,205) } else {
draw_sprite(s_frozenskinbutton,0,2015+realspritedistance,205) }
if global.skin015 = 0 { draw_sprite(s_lockedskinicon,0,2135+realspritedistance,205) } else {
draw_sprite(s_kindadeadskinbutton,0,2135+realspritedistance,205) }
if global.skin016 = 0 { draw_sprite(s_lockedskinicon,0,2255+realspritedistance,205) } else {
draw_sprite(s_coronaskinbutton,0,2255+realspritedistance,205) }
if global.skin017 = 0 { draw_sprite(s_lockedskinicon,0,2375+realspritedistance,205) } else {
draw_sprite(s_canadianskinbutton,0,2375+realspritedistance,205) }
if global.skin018 = 0 { draw_sprite(s_lockedskinicon,0,2495+realspritedistance,205) } else {
draw_sprite(s_hazardousskinbutton,0,2495+realspritedistance,205) }
if global.skin019 = 0 { draw_sprite(s_lockedskinicon,0,2615+realspritedistance,205) } else {
draw_sprite(s_babyskinbutton,0,2615+realspritedistance,205) }
if global.skin020 = 0 { draw_sprite(s_lockedskinicon,0,2735+realspritedistance,205) } else {
draw_sprite(s_hexagonskinbutton,0,2735+realspritedistance,205) }
if global.skin021 = 0 { draw_sprite(s_lockedskinicon,0,2855+realspritedistance,205) } else {
draw_sprite(s_tuxedoskinbutton,0,2855+realspritedistance,205) }
if global.skin022 = 0 { draw_sprite(s_lockedskinicon,0,2975+realspritedistance,205) } else {
draw_sprite(s_normalskinbutton,0,2975+realspritedistance,205) }
if global.skin023 = 0 { draw_sprite(s_lockedskinicon,0,3095+realspritedistance,205) } else {
draw_sprite(s_waterskinbutton,0,3095+realspritedistance,205) }
if global.skin024 = 0 { draw_sprite(s_lockedskinicon,0,3215+realspritedistance,205) } else {
draw_sprite(s_forsenEskinbutton,0,3215+realspritedistance,205) }
if global.skin025 = 0 { draw_sprite(s_lockedskinicon,0,3335+realspritedistance,205) } else {
draw_sprite(s_redballskinbutton,0,3335+realspritedistance,205) }
if global.skin026 = 0 { draw_sprite(s_lockedskinicon,0,3455+realspritedistance,205) } else {
draw_sprite(s_bomberskinbutton,0,3455+realspritedistance,205) }
if global.skin027 = 0 { draw_sprite(s_lockedskinicon,0,3575+realspritedistance,205) } else {
draw_sprite(s_hitboxskinbutton,0,3575+realspritedistance,205) }
if global.skin028 = 0 { draw_sprite(s_lockedskinicon,0,3695+realspritedistance,205) } else {
draw_sprite(s_metallicskinbutton,0,3695+realspritedistance,205) }
if global.skin029 = 0 { draw_sprite(s_lockedskinicon,0,3815+realspritedistance,205) } else {
draw_sprite(s_monocleskinbutton,0,3815+realspritedistance,205) }
if global.skin030 = 0 { draw_sprite(s_lockedskinicon,0,3935+realspritedistance,205) } else {
draw_sprite(s_japaneseskinbutton,0,3935+realspritedistance,205) }
if global.skin031 = 0 { draw_sprite(s_lockedskinicon,0,4055+realspritedistance,205) } else {
draw_sprite(s_googlyskinbutton,0,4055+realspritedistance,205) }
if global.skin032 = 0 { draw_sprite(s_lockedskinicon,0,4175+realspritedistance,205) } else {
draw_sprite(s_upsidedownskinbutton,0,4175+realspritedistance,205) }
if global.skin033 = 0 { draw_sprite(s_lockedskinicon,0,4295+realspritedistance,205) } else {
draw_sprite(s_spiralskinbutton,0,4295+realspritedistance,205) }
if global.skin034 = 0 { draw_sprite(s_lockedskinicon,0,4415+realspritedistance,205) } else {
draw_sprite(s_heartskinbutton,0,4415+realspritedistance,205) }
if global.skin035 = 0 { draw_sprite(s_lockedskinicon,0,4535+realspritedistance,205) } else {
draw_sprite(s_clockskinbutton,0,4535+realspritedistance,205) }
if global.skin036 = 0 { draw_sprite(s_lockedskinicon,0,4655+realspritedistance,205) } else {
draw_sprite(s_invisibleskinbutton,0,4655+realspritedistance,205) }
if global.skin037 = 0 { draw_sprite(s_lockedskinicon,0,4775+realspritedistance,205) } else {
draw_sprite(s_arrowskinbutton,0,4775+realspritedistance,205) }
if global.skin038 = 0 { draw_sprite(s_lockedskinicon,0,4895+realspritedistance,205) } else {
draw_sprite(s_spikeskinbutton,0,4895+realspritedistance,205) }
if global.skin039 = 0 { draw_sprite(s_lockedskinicon,0,5015+realspritedistance,205) } else {
draw_sprite(s_splitskinbutton,0,5015+realspritedistance,205) }
if global.skin040 = 0 { draw_sprite(s_lockedskinicon,0,5135+realspritedistance,205) } else {
draw_sprite(s_pirateskinbutton,0,5135+realspritedistance,205) }
if global.skin041 = 0 { draw_sprite(s_lockedskinicon,0,5255+realspritedistance,205) } else {
draw_sprite(s_scifiskinbutton,0,5255+realspritedistance,205) }
if global.skin042 = 0 { draw_sprite(s_lockedskinicon,0,5375+realspritedistance,205) } else {
draw_sprite(s_gordonskinbutton,0,5375+realspritedistance,205) }
if global.skin043 = 0 { draw_sprite(s_lockedskinicon,0,5495+realspritedistance,205) } else {
draw_sprite(s_fancyskinbutton,0,5495+realspritedistance,205) }
if global.skin044 = 0 { draw_sprite(s_lockedskinicon,0,5615+realspritedistance,205) } else {
draw_sprite(s_steamskinbutton,0,5615+realspritedistance,205) }
if global.skin045 = 0 { draw_sprite(s_lockedskinicon,0,5735+realspritedistance,205) } else {
draw_sprite(s_breakableskinbutton,0,5735+realspritedistance,205) }
if global.skin046 = 0 { draw_sprite(s_lockedskinicon,0,5855+realspritedistance,205) } else {
draw_sprite(s_smileyskinbutton,0,5855+realspritedistance,205) }
if global.skin047 = 0 { draw_sprite(s_lockedskinicon,0,5975+realspritedistance,205) } else {
draw_sprite(s_maidskinbutton,0,5975+realspritedistance,205) }
draw_rectangle_color(822,205,1024,310,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,205,170,310,c_black,c_black,c_black,c_black,false)
draw_line_width_color(170,205,822,205,4,c_white,c_white)
draw_line_width_color(170,205,170,310,4,c_white,c_white)
draw_line_width_color(822,205,822,310,4,c_white,c_white)
draw_line_width_color(170,310,822,310,4,c_white,c_white)
}