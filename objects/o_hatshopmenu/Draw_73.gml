draw_set_alpha(0.5)
draw_rectangle_color(0,0,2000,2000,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)

draw_set_color(c_white)
dis = lerp(dis,selectedhat,0.1 * (144 / global.maxfps))

draw_set_font(fnt_secret1)
var col1 = c_orange
var col2 = c_red
draw_set_halign(fa_center)
draw_text_color(room_width/2,700,"PRICE DIFFERENCE: " + string((global.hatmerchantdiscount)*100) + "%",col1,col2,col1,col2,1)
draw_set_font(global.deathfont)
draw_set_halign(fa_left)
//Exit
draw_sprite(s_nohaticon,0,455+dis*120,500)
//Graduation Hat
drawhatshop(s_graduationhaticon,1+dis,floor(75 * global.hatmerchantdiscount),global.hat001,500)
//Cone Hat
drawhatshop(s_conehaticon,2+dis,floor(75 * global.hatmerchantdiscount),global.hat002,500)
//Party Hat
drawhatshop(s_partyhaticon,3+dis,floor(112 * global.hatmerchantdiscount),global.hat003,500)
//Paper Hat
drawhatshop(s_paperhaticon,4+dis,floor(75 * global.hatmerchantdiscount),global.hat004,500)
//Top Hat
drawhatshop(s_tophaticon,5+dis,floor(300 * global.hatmerchantdiscount),global.hat005,500)
//Yellow Top Hat
drawhatshop(s_yellowtophaticon,6+dis,floor(2250 * global.hatmerchantdiscount),global.hat006,500)
//Reddie Hat
drawhatshop(s_reddiehaticon,7+dis,floor(225 * global.hatmerchantdiscount),global.hat007,500)
//Christmas Hat
drawhatshop(s_christmashaticon,8+dis,floor(112 * global.hatmerchantdiscount),global.hat008,500)
//Witch Hat
drawhatshop(s_witchhaticon,9+dis,floor(112 * global.hatmerchantdiscount),global.hat009,500)
//Pumpkin Hat
drawhatshop(s_pumpkinhaticon,10+dis,floor(112 * global.hatmerchantdiscount),global.hat010,500)
//Brown Cap
drawhatshop(s_brownhaticon,11+dis,floor(75 * global.hatmerchantdiscount),global.hat011,500)
//Gray Cap
drawhatshop(s_grayhaticon,12+dis,floor(75 * global.hatmerchantdiscount),global.hat012,500)
//White Cap
drawhatshop(s_whitehaticon,13+dis,floor(75 * global.hatmerchantdiscount),global.hat013,500)
//Sun Hat
drawhatshop(s_sunhaticon,14+dis,floor(75 * global.hatmerchantdiscount),global.hat014,500)
//Red Block Hat
drawhatshop(s_redblockhaticon,15+dis,floor(75 * global.hatmerchantdiscount),global.hat015,500)
//Yellow Block Hat
drawhatshop(s_yellowblockhaticon,16+dis,floor(75 * global.hatmerchantdiscount),global.hat016,500)
//Green Block Hat
drawhatshop(s_greenblockhaticon,17+dis,floor(75 * global.hatmerchantdiscount),global.hat017,500)
//Blue Block Hat
drawhatshop(s_blueblockhaticon,18+dis,floor(75 * global.hatmerchantdiscount),global.hat018,500)
//White Block Hat
drawhatshop(s_whiteblockhaticon,19+dis,floor(75 * global.hatmerchantdiscount),global.hat019,500)
//Spike Hat
drawhatshop(s_spikehaticon,20+dis,floor(75 * global.hatmerchantdiscount),global.hat020,500)
//Invisible Spike Hat
drawhatshop(s_invisiblespikehaticon,21+dis,floor(112 * global.hatmerchantdiscount),global.hat021,500)
//Vertical Moving Spike Hat
drawhatshop(s_Vspikehaticon,22+dis,floor(112 * global.hatmerchantdiscount),global.hat022,500)
//Horizontal Moving Spike Hat
drawhatshop(s_Hspikehaticon,23+dis,floor(112 * global.hatmerchantdiscount),global.hat023,500)
//Hexagon Hat
drawhatshop(s_hexagonhaticon,24+dis,floor(180 * global.hatmerchantdiscount),global.hat024,500)
//Bread Hat
drawhatshop(s_breadhaticon,25+dis,floor(187 * global.hatmerchantdiscount),global.hat025,500)
//Soldier Hat
drawhatshop(s_soldierhaticon,26+dis,floor(112 * global.hatmerchantdiscount),global.hat026,500)
//Samurai Hat
drawhatshop(s_samuraihaticon,27+dis,floor(75 * global.hatmerchantdiscount),global.hat027,500)
//Red Beanie Hat
drawhatshop(s_redbeaniehaticon,28+dis,floor(112 * global.hatmerchantdiscount),global.hat028,500)
//Yellow Beanie Hat
drawhatshop(s_yellowbeaniehaticon,29+dis,floor(112 * global.hatmerchantdiscount),global.hat029,500)
//Green Beanie Hat
drawhatshop(s_greenbeaniehaticon,30+dis,floor(112 * global.hatmerchantdiscount),global.hat030,500)
//Blue Beanie Hat
drawhatshop(s_bluebeaniehaticon,31+dis,floor(112 * global.hatmerchantdiscount),global.hat031,500)
//White Beanie Hat
drawhatshop(s_whitebeaniehaticon,32+dis,floor(112 * global.hatmerchantdiscount),global.hat032,500)
//Pirate Hat
drawhatshop(s_piratehaticon,33+dis,floor(187 * global.hatmerchantdiscount),global.hat033,500)
//Pink Bowtie Hat Icon
drawhatshop(s_pinkbowtiehaticon,34+dis,floor(75 * global.hatmerchantdiscount),global.hat034,500)
//King Crown
drawhatshop(s_kinghaticon,35+dis,floor(749 * global.hatmerchantdiscount),global.hat035,500)
//Hair
drawhatshop(s_hairhaticon,36+dis,floor(150 * global.hatmerchantdiscount),global.hat036,500)
//Comrade
drawhatshop(s_comradehaticon,37+dis,floor(375 * global.hatmerchantdiscount),global.hat037,500)
//Viking
drawhatshop(s_vikinghaticon,38+dis,floor(112 * global.hatmerchantdiscount),global.hat038,500)
//Red Sus
drawhatshop(s_redsushaticon,39+dis,floor(150 * global.hatmerchantdiscount),global.hat040,500)
//Yellow Sus
drawhatshop(s_yellowsushaticon,40+dis,floor(112 * global.hatmerchantdiscount),global.hat041,500)
//Green Sus
drawhatshop(s_greensushaticon,41+dis,floor(112 * global.hatmerchantdiscount),global.hat042,500)
//Blue Sus
drawhatshop(s_bluesushaticon,42+dis,floor(75 * global.hatmerchantdiscount),global.hat043,500)
//White Sus
drawhatshop(s_whitesushaticon,43+dis,floor(112 * global.hatmerchantdiscount),global.hat044,500)
//Serbian
drawhatshop(s_serbianhaticon,44+dis,floor(75 * global.hatmerchantdiscount),global.hat047,500)
//Rat Hat
drawhatshop(s_rathaticon,45+dis,floor(75 * global.hatmerchantdiscount),global.hat048,500)
//German
drawhatshop(s_germanhaticon,46+dis,floor(75 * global.hatmerchantdiscount),global.hat049,500)
//French
drawhatshop(s_frenchhaticon,47+dis,floor(75 * global.hatmerchantdiscount),global.hat050,500)
//Italian
drawhatshop(s_italianhaticon,48+dis,floor(75 * global.hatmerchantdiscount),global.hat051,500)
//Spanish
drawhatshop(s_spanishhaticon,49+dis,floor(75 * global.hatmerchantdiscount),global.hat052,500)
//Magyar
drawhatshop(s_magyarhaticon,50+dis,floor(75 * global.hatmerchantdiscount),global.hat053,500)
//Bosnian
drawhatshop(s_bosnianhaticon,51+dis,floor(75 * global.hatmerchantdiscount),global.hat054,500)
//Chinese
drawhatshop(s_chinesehaticon,52+dis,floor(75 * global.hatmerchantdiscount),global.hat055,500)
//Ukraine
drawhatshop(s_ukrainianhaticon,53+dis,floor(75 * global.hatmerchantdiscount),global.hat056,500)
//Macedonian
drawhatshop(s_macedonianhaticon,54+dis,floor(75 * global.hatmerchantdiscount),global.hat057,500)
//Chicken
drawhatshop(s_chickenhaticon,55+dis,floor(100 * global.hatmerchantdiscount),global.hat058,500)
//Czech
drawhatshop(s_czechhaticon,56+dis,floor(75 * global.hatmerchantdiscount),global.hat059,500)
//Russian
drawhatshop(s_russianhaticon,57+dis,floor(75 * global.hatmerchantdiscount),global.hat060,500)
//Devil
drawhatshop(s_devilhaticon,58+dis,floor(75 * global.hatmerchantdiscount),global.hat061,500)
//Turkey
drawhatshop(s_turkishhaticon,59+dis,floor(75 * global.hatmerchantdiscount),global.hat062,500)

//Arrow
draw_sprite_ext(s_liquidarrow,0,490,620,1,arrowyscale,0,c_white,1)
if arrowyscale > 1 {
	change = 0
	}
	if arrowyscale < 0.9 {
	change = 1
	}
	if change = 0 { arrowyscale = lerp(arrowyscale,0.89,0.1 * (60 / global.maxfps)) } else { arrowyscale = lerp(arrowyscale,1.01,0.1 * (60 / global.maxfps)) }