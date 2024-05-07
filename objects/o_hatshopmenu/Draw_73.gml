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
drawhatshop(s_graduationhaticon,1+dis,floor(75 * global.hatmerchantdiscount),global.hat[1],500)
//Cone Hat
drawhatshop(s_conehaticon,2+dis,floor(75 * global.hatmerchantdiscount),global.hat[2],500)
//Party Hat
drawhatshop(s_partyhaticon,3+dis,floor(112 * global.hatmerchantdiscount),global.hat[3],500)
//Paper Hat
drawhatshop(s_paperhaticon,4+dis,floor(75 * global.hatmerchantdiscount),global.hat[4],500)
//Top Hat
drawhatshop(s_tophaticon,5+dis,floor(300 * global.hatmerchantdiscount),global.hat[5],500)
//Yellow Top Hat
drawhatshop(s_yellowtophaticon,6+dis,floor(2250 * global.hatmerchantdiscount),global.hat[6],500)
//Reddie Hat
drawhatshop(s_reddiehaticon,7+dis,floor(225 * global.hatmerchantdiscount),global.hat[7],500)
//Christmas Hat
drawhatshop(s_christmashaticon,8+dis,floor(112 * global.hatmerchantdiscount),global.hat[8],500)
//Witch Hat
drawhatshop(s_witchhaticon,9+dis,floor(112 * global.hatmerchantdiscount),global.hat[9],500)
//Pumpkin Hat
drawhatshop(s_pumpkinhaticon,10+dis,floor(112 * global.hatmerchantdiscount),global.hat[10],500)
//Brown Cap
drawhatshop(s_brownhaticon,11+dis,floor(75 * global.hatmerchantdiscount),global.hat[11],500)
//Gray Cap
drawhatshop(s_grayhaticon,12+dis,floor(75 * global.hatmerchantdiscount),global.hat[12],500)
//White Cap
drawhatshop(s_whitehaticon,13+dis,floor(75 * global.hatmerchantdiscount),global.hat[13],500)
//Sun Hat
drawhatshop(s_sunhaticon,14+dis,floor(75 * global.hatmerchantdiscount),global.hat[14],500)
//Red Block Hat
drawhatshop(s_redblockhaticon,15+dis,floor(75 * global.hatmerchantdiscount),global.hat[15],500)
//Yellow Block Hat
drawhatshop(s_yellowblockhaticon,16+dis,floor(75 * global.hatmerchantdiscount),global.hat[16],500)
//Green Block Hat
drawhatshop(s_greenblockhaticon,17+dis,floor(75 * global.hatmerchantdiscount),global.hat[17],500)
//Blue Block Hat
drawhatshop(s_blueblockhaticon,18+dis,floor(75 * global.hatmerchantdiscount),global.hat[18],500)
//White Block Hat
drawhatshop(s_whiteblockhaticon,19+dis,floor(75 * global.hatmerchantdiscount),global.hat[19],500)
//Spike Hat
drawhatshop(s_spikehaticon,20+dis,floor(75 * global.hatmerchantdiscount),global.hat[20],500)
//Invisible Spike Hat
drawhatshop(s_invisiblespikehaticon,21+dis,floor(112 * global.hatmerchantdiscount),global.hat[21],500)
//Vertical Moving Spike Hat
drawhatshop(s_Vspikehaticon,22+dis,floor(112 * global.hatmerchantdiscount),global.hat[22],500)
//Horizontal Moving Spike Hat
drawhatshop(s_Hspikehaticon,23+dis,floor(112 * global.hatmerchantdiscount),global.hat[23],500)
//Hexagon Hat
drawhatshop(s_hexagonhaticon,24+dis,floor(180 * global.hatmerchantdiscount),global.hat[24],500)
//Bread Hat
drawhatshop(s_breadhaticon,25+dis,floor(187 * global.hatmerchantdiscount),global.hat[25],500)
//Soldier Hat
drawhatshop(s_soldierhaticon,26+dis,floor(112 * global.hatmerchantdiscount),global.hat[26],500)
//Samurai Hat
drawhatshop(s_samuraihaticon,27+dis,floor(75 * global.hatmerchantdiscount),global.hat[27],500)
//Red Beanie Hat
drawhatshop(s_redbeaniehaticon,28+dis,floor(112 * global.hatmerchantdiscount),global.hat[28],500)
//Yellow Beanie Hat
drawhatshop(s_yellowbeaniehaticon,29+dis,floor(112 * global.hatmerchantdiscount),global.hat[29],500)
//Green Beanie Hat
drawhatshop(s_greenbeaniehaticon,30+dis,floor(112 * global.hatmerchantdiscount),global.hat[30],500)
//Blue Beanie Hat
drawhatshop(s_bluebeaniehaticon,31+dis,floor(112 * global.hatmerchantdiscount),global.hat[31],500)
//White Beanie Hat
drawhatshop(s_whitebeaniehaticon,32+dis,floor(112 * global.hatmerchantdiscount),global.hat[32],500)
//Pirate Hat
drawhatshop(s_piratehaticon,33+dis,floor(187 * global.hatmerchantdiscount),global.hat[33],500)
//Pink Bowtie Hat Icon
drawhatshop(s_pinkbowtiehaticon,34+dis,floor(75 * global.hatmerchantdiscount),global.hat[34],500)
//King Crown
drawhatshop(s_kinghaticon,35+dis,floor(749 * global.hatmerchantdiscount),global.hat[35],500)
//Hair
drawhatshop(s_hairhaticon,36+dis,floor(150 * global.hatmerchantdiscount),global.hat[36],500)
//Comrade
drawhatshop(s_comradehaticon,37+dis,floor(375 * global.hatmerchantdiscount),global.hat[37],500)
//Viking
drawhatshop(s_vikinghaticon,38+dis,floor(112 * global.hatmerchantdiscount),global.hat[38],500)
//Red Sus
drawhatshop(s_redsushaticon,39+dis,floor(150 * global.hatmerchantdiscount),global.hat[40],500)
//Yellow Sus
drawhatshop(s_yellowsushaticon,40+dis,floor(112 * global.hatmerchantdiscount),global.hat[41],500)
//Green Sus
drawhatshop(s_greensushaticon,41+dis,floor(112 * global.hatmerchantdiscount),global.hat[42],500)
//Blue Sus
drawhatshop(s_bluesushaticon,42+dis,floor(75 * global.hatmerchantdiscount),global.hat[43],500)
//White Sus
drawhatshop(s_whitesushaticon,43+dis,floor(112 * global.hatmerchantdiscount),global.hat[44],500)
//Serbian
drawhatshop(s_serbianhaticon,44+dis,floor(50 * global.hatmerchantdiscount),global.hat[47],500)
//Rat Hat
drawhatshop(s_rathaticon,45+dis,floor(75 * global.hatmerchantdiscount),global.hat[48],500)
//German
drawhatshop(s_germanhaticon,46+dis,floor(50 * global.hatmerchantdiscount),global.hat[49],500)
//French
drawhatshop(s_frenchhaticon,47+dis,floor(50 * global.hatmerchantdiscount),global.hat[50],500)
//Italian
drawhatshop(s_italianhaticon,48+dis,floor(50 * global.hatmerchantdiscount),global.hat[51],500)
//Spanish
drawhatshop(s_spanishhaticon,49+dis,floor(50 * global.hatmerchantdiscount),global.hat[52],500)
//Magyar
drawhatshop(s_magyarhaticon,50+dis,floor(50 * global.hatmerchantdiscount),global.hat[53],500)
//Bosnian
drawhatshop(s_bosnianhaticon,51+dis,floor(50 * global.hatmerchantdiscount),global.hat[54],500)
//Chinese
drawhatshop(s_chinesehaticon,52+dis,floor(50 * global.hatmerchantdiscount),global.hat[55],500)
//Ukraine
drawhatshop(s_ukrainianhaticon,53+dis,floor(50 * global.hatmerchantdiscount),global.hat[56],500)
//Macedonian
drawhatshop(s_macedonianhaticon,54+dis,floor(50 * global.hatmerchantdiscount),global.hat[57],500)
//Chicken
drawhatshop(s_chickenhaticon,55+dis,floor(100 * global.hatmerchantdiscount),global.hat[58],500)
//Czech
drawhatshop(s_czechhaticon,56+dis,floor(50 * global.hatmerchantdiscount),global.hat[59],500)
//Russian
drawhatshop(s_russianhaticon,57+dis,floor(50 * global.hatmerchantdiscount),global.hat[60],500)
//Devil
drawhatshop(s_devilhaticon,58+dis,floor(75 * global.hatmerchantdiscount),global.hat[61],500)
//Turkey
drawhatshop(s_turkishhaticon,59+dis,floor(50 * global.hatmerchantdiscount),global.hat[62],500)
//Palestinian
drawhatshop(s_palestinianhaticon,60+dis,floor(50 * global.hatmerchantdiscount),global.hat[63],500)
//Slovenian
drawhatshop(s_slovenianhaticon,61+dis,floor(50 * global.hatmerchantdiscount),global.hat[64],500)
//Japanese
drawhatshop(s_japanesehaticon,62+dis,floor(50 * global.hatmerchantdiscount),global.hat[65],500)
//Romanian
drawhatshop(s_romanianhaticon,63+dis,floor(50 * global.hatmerchantdiscount),global.hat[66],500)
//Portuguese
drawhatshop(s_portuguesehaticon,64+dis,floor(50 * global.hatmerchantdiscount),global.hat[67],500)

//Arrow
draw_sprite_ext(s_liquidarrow,0,490,620,1,arrowyscale,0,c_white,1)
if arrowyscale > 1 {
	change = 0
	}
	if arrowyscale < 0.9 {
	change = 1
	}
	if change = 0 { arrowyscale = lerp(arrowyscale,0.89,0.1 * (60 / global.maxfps)) } else { arrowyscale = lerp(arrowyscale,1.01,0.1 * (60 / global.maxfps)) }