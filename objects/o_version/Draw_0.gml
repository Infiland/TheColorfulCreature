draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_text_scribble(588,128,"[wave]" + string(version))

if os_is_network_connected() {
if keyboard_check(vk_control) {
if (global.playercount + global.playercountdemo) = 0 { 
	draw_set_color(c_yellow)
	draw_text(32,712,loc(633) + ": 0 :(") } else {
draw_text(32,712,loc(633)+": " + string(global.playercount + global.playercountdemo)) }
} else { draw_text_scribble(32,712,"[c_white][scale,0.8]Copyright " + string(global.calendarcurrentyear) + " - Infiland") }
if (global.playercount + global.playercountdemo) > 1 {
draw_text_scribble(32,732,"[rainbow][wave]CREDITS MULTIPLIER: " + string(global.creditsmultiplier) + "X")
}} else {
draw_set_color(c_red)
draw_text(32,732,loc(635))	
}

draw_set_color(c_white)
if os_type != os_android {
var userid = steam_get_user_steam_id();
var a = 0
var name = steam_get_persona_name() //steam_get_user_persona_name(test)
draw_set_halign(fa_right)
draw_text(1000,416,string(name))

//draw_text(mouse_x,mouse_y,actualmoni)

draw_set_font(global.coolfont)

/*moni = 0
actualmoni = 0
if steam_user_owns_dlc(2411810) {
	moni = 1
	actualmoni += 2
}
if steam_user_owns_dlc(2411811) {
	moni = 1
	actualmoni += 3
}
if steam_user_owns_dlc(2411812) {
	moni = 1
	actualmoni += 5
}*/
var b=0,s=0,g=0,bl=0

if mouse_x > 930 { //Profile Picture
if mouse_x < 994 {
if mouse_y > 352 {
if mouse_y < 416 {
drawinfoboxbadge(loc(636),c_lime,c_orange)
}}}}
//THE COLORFUL CREATURE
draw_sprite(s_badgesmenu,7,970-a*32,446)
if game1 > 1 { draw_text(1000-a*32,460,game1) }
if mouse_x > (970-a*32) { 
if mouse_x < (1002-a*32) {
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(637),c_lime,c_green)
}}}}
//COMMENTARY
if dlc1 = 1 {
draw_sprite(s_badgesmenu,5,970-a*32-(game1*32),446)
if mouse_x > (970-a*32-(game1*32)) {
if mouse_x < (1002-a*32-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(638),c_yellow,c_orange)
}}}}}
//OST
if dlc2 > 0 {
draw_sprite(s_badgesmenu,6,970-a*32-(dlc1*32)-(game1*32),446)
if mouse_x > (970-a*32-(dlc1*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(639),c_blue,c_aqua)
}}}}}
//ASTEROIDS++
if dlc3 > 0 {
draw_sprite(s_badgesmenu,4,970-a*32-(dlc1*32)-(dlc2*32)-(game1*32),446)
if mouse_x > (970-a*32-(dlc1*32)-(dlc2*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(dlc2*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(667),c_gray,c_lime)
}}}}}
//Money
if moni > 0 {
var spr = 0
switch(actualmoni) {
default: moni = 0 break;
case(2): spr = 8 break;
case(3): spr = 9 break;
case(5): spr = 10 break;
case(7): spr = 11 break;
case(8): spr = 12 break;
case(10): spr = 13 break;
}

draw_sprite(s_badgesmenu,spr,970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(game1*32),446)
if mouse_x > (970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
	if actualmoni != 10 {
drawinfoboxbadge(loc(668),c_green,c_lime)
	} else {
	drawinfoboxbadge(loc(670),c_yellow,c_orange)	
	}
}}}}}
//1ST PLACE
if e1 > 0 { g=1
draw_sprite(s_badgesmenu,0,970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e1 > 1 { draw_text(1000-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e1) }
if mouse_x > (970-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(640),c_olive,c_yellow)
}}}}}
//2ND PLACE
if e2 > 0 { s=1
draw_sprite(s_badgesmenu,1,970-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e2 > 1 { draw_text(1000-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e2) }
if mouse_x > (970-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(641),c_gray,c_ltgray)
}}}}}
//3RD PLACE
if e3 > 0 { b=1
draw_sprite(s_badgesmenu,2,970-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e3 > 1 { draw_text(1000-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e3) }
if mouse_x > (970-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(s*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(642),#804f1c,#b0691c)
}}}}}
//4TH PLACE
if e4 > 0 { bl=1
draw_sprite(s_badgesmenu,3,970-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if e4 > 1 { draw_text(1000-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e4) }
if mouse_x > (970-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(s*32)-(b*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge(loc(643),c_gray,c_dkgrey)
}}}}}
//COMMUNITY HAT
if hats > 0 { bl=1
draw_sprite(s_badgesmenu,14,970-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),446)
if hats > 1 { draw_text(1000-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32),460,e4) }
if mouse_x > (970-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {
if mouse_x < (1002-a*32-(g*32)-(s*32)-(b*32)-(bl*32)-(dlc1*32)-(dlc2*32)-(dlc3*32)-(moni*32)-(game1*32)) {	
if mouse_y > 446 {
if mouse_y < 462 {
drawinfoboxbadge("Made a community hat!",c_green,c_purple)
}}}}}

/*draw_text(mouse_x,mouse_y,g)
draw_text(mouse_x,mouse_y+20,s)
draw_text(mouse_x,mouse_y+40,b)
draw_text(mouse_x,mouse_y+60,bl)*/
global.asteroidskeypoints = 0
global.asteroidskeypoints += game1
global.asteroidskeypoints += e4
global.asteroidskeypoints += e3*2
global.asteroidskeypoints += e2*3
global.asteroidskeypoints += e1*5
global.asteroidskeypoints += dlc1*10
global.asteroidskeypoints += dlc2*5
global.asteroidskeypoints += actualmoni*5
}
 
//steam_get_user_avatar(userid,steam_user_avatar_size_medium);

draw_set_halign(fa_left)
draw_set_font(global.deathfont)
draw_set_color(c_white)

if global.customsplashessettings = 1 {
draw_text_scribble(5,5,chosentext)
} else {
switch(splash) {
case(1): draw_text(5,5,"Epic!") break;
case(2): draw_text(5,5,"Thanks Moldovan for the art.") break;
case(3): draw_text(5,5,"Quite Amazed.") break;
case(4): draw_text(5,5,"Gamer Moment") break;
case(5): draw_text(5,5,"This is a random splash screen!") break;
case(6): draw_text(5,5,"Test 123, 123...") break;
case(7): draw_text(5,5,"Red, Yellow, Green, Blue, White!") break;
case(8): draw_text(5,5,"Colorful!") break;
case(9): draw_text(5,5,"Beware, Reddie is here!") break;
case(10): draw_text(5,5,"Level Editor!") break;
case(11): draw_text(5,5,"By Infiland!") break;
case(12): draw_text(5,5,"New Challenges!") break;
case(13): draw_text(5,5,"Press Start!") break;
case(14): draw_text(5,5,"Skins!") break;
case(15): draw_text(5,5,"Exclusive Edition!") break;
case(16): draw_text(5,5,"Touch Fuzzy, get Dizzy!") break;
case(17): draw_text(5,5,"Something is lurking around.") break;
case(18): draw_text(5,5,"Lots of stuff to do, lots of stuff to learn.") break;
case(19): draw_text(5,5,"MAke your own levels in Level Editor!") break;
case(20): draw_text(5,5,"You can go to settings and change the colorblind option to Grayscale if you don't like colors.") break;
case(21): draw_text(5,5,"Thank you TheDarkBomber for making some amazing levels!") break;
case(22): draw_text(5,5,"HenryEditz!") break;
case(23): draw_text(5,5,"Poof!") break;
case(24): draw_text(5,5,"Dank memes.") break;
case(25): draw_text(5,5,"The year is " + string(current_year)) break;
case(26):
switch(current_month) {
case(1): draw_text(5,5,"The current month is January.") break;
case(2): draw_text(5,5,"The current month is February.") break;
case(3): draw_text(5,5,"The current month is March.") break;
case(4): draw_text(5,5,"The current month is April.") break;
case(5): draw_text(5,5,"The current month is May.") break;
case(6): draw_text(5,5,"The current month is June.") break;
case(7): draw_text(5,5,"The current month is July.") break;
case(8): draw_text(5,5,"The current month is August.") break;
case(9): draw_text(5,5,"The current month is September.") break;
case(10): draw_text(5,5,"The current month is October.") break;
case(11): draw_text(5,5,"The current month is November.") break;
case(12): draw_text(5,5,"The current month is December.") break;
} break;
case(27): draw_text(5,5,"The current day of the month is day " + string(current_day)) break;
case(28):
switch(current_weekday) {
case(1): draw_text(5,5,"Today is Monday.") break;
case(2): draw_text(5,5,"Today is Tuesday.") break;
case(3): draw_text(5,5,"Today is Wednesday my dudes.") break;
case(4): draw_text(5,5,"Today is Thursday.") break;
case(5): draw_text(5,5,"Today is Friday.") break;
case(6): draw_text(5,5,"Today is Saturday.") break;
case(7): draw_text(5,5,"Today is Sunday.") break;
} break;
case(29): draw_text(5,5,"Good day today? Eh?") break;
case(30): draw_text(5,5,"Easy to play, hard to master.") break;
case(31): draw_text(5,5,"You are breathtaking!") break;
case(32): draw_text(5,5,"FUN FACT: The Campaign has 100 levels, beat them all to get an ending!") break;
case(33): draw_text(5,5,"Over 350 levels included.") break;
case(34): draw_text(5,5,"Thank you Wonderwaffle for the support!") break;
case(35): draw_text(5,5,"A simple dot game.") break;
case(36): draw_text(5,5,"No, this cannot be happening.") break;
case(37): draw_text(5,5,"Failing kaizo levels since 2019!") break;
case(38): draw_text(5,5,"This game is hard!") break;
case(39): draw_text(5,5,"This game isn't easy!") break;
case(40): draw_text(5,5,"Don't like the current look? Try unlocking skins in the Fun Mode Menu!") break;
case(41): draw_text(5,5,"Feel like you've mastered The Colorful Creature? Try the Kaizo Challenge!") break;
case(42): draw_text(5,5,"Want more levels? Try challenges in Fun Mode!") break;
case(43): draw_text(5,5,"[INSERT SPLASH TEXT HERE | OUT OF IDEAS]") break;
case(44): draw_text(5,5,"No, I don't think he will.") break;
case(45): draw_text(5,5,"'Oh that Infiland guy made that red ball thing'") break;
case(46): draw_text(5,5,"You shall not pass.") break;
case(47): draw_text(5,5,"Is the music loud? Lower the volume by going to the settings!") break;
case(48): draw_text(5,5,"Hate those god damn sounds? Lower the volume by going to the settings!") break;
case(49): draw_text(5,5,"What's popping?") break;
case(50): draw_text(5,5,"In the code, this is the official 50th splash text.") break;
case(51): draw_text(5,5,"FUN FACT: Beating Hardmode rewards you handsomely. Perhaps a... better ending?") break;
case(52): draw_text(5,5,"Only on PC and Mobile!") break;
case(53): draw_text(5,5,"All of the colors are MINE!") break;
case(54): draw_text(5,5,"I've made a severe and continuous lapse of my judgement...") break;
case(55): draw_text(5,5,"Available on Windows, Linux and Android!") break;
case(56): draw_text(5,5,"Today is: " + string_hash_to_newline(string(current_day)) + "." + string_hash_to_newline(string(current_month)) + "." + string_hash_to_newline(string(current_year))) break;
case(57): draw_text(5,5,"PING! PONG!") break;
case(58): draw_text(5,5,"Hapi Hapi Haaaaapiiii!") break;
case(59): draw_text(5,5,"Red Color + Yellow Reddie = DEAD!") break;
case(60): draw_text(5,5,"Development since September 3rd 2018.") break;
case(61): draw_text(5,5,"Red Color + Red Reddie = NOT dead!") break;
case(62): draw_text(5,5,"Reddie!") break;
case(63): draw_text(5,5,"Is it really that time again?") break;
case(64): draw_text(5,5,"The cake is a lie.") break;
case(65): draw_text(5,5,"Made with love and tears.") break;
case(66): draw_text(5,5,"Support the DEVELOPER!") break;
case(67): draw_text(5,5,"Be careful around other colors!") break;
case(68): draw_text(5,5,"Try beating the game without collecting any coins.") break;
case(69): draw_text(5,5,"Try beating the game in hardmode, see how long you last.") break;
case(70): draw_text(5,5,"PRO TIP: Use coins to skip levels, but only if they are hard for you.") break;
case(71): draw_text(5,5,"Brofist.") break;
case(72): draw_text(5,5,"Where do you want to go today?") break;
case(73): draw_text(5,5,"Thank you shibusu.") break;
case(74): draw_text(5,5,"SUIIIIIIIII") break;
case(75): draw_text(5,5,"The Colorful Creature!") break;
case(76): draw_text(5,5,"RED: The color of Danger and Courage.") break;
case(77): draw_text(5,5,"YELLOW: The color of Happiness, Glory, Harmony and Wisdom.") break;
case(78): draw_text(5,5,"GREEN: The color of Safety and Permission.") break;
case(79): draw_text(5,5,"BLUE: The color of Intelligence, Knowledge, Calm and Concentration.") break;
case(80): draw_text(5,5,"WHITE: The color of Perfection, The Good, Honesty, Cleanliness, The Beginning, The New,\nNeutrality") break;
case(81): draw_text(5,5,"Colorblind option is here!") break;
case(82): draw_text(5,5,"Inspired from the game 'Color Master'") break;
case(83): draw_text(5,5,"Welcome to City 17. It's safer here...") break;
case(84): draw_text(5,5,"Report bugs in the Support Menu!") break;
case(85): draw_text(5,5,"Ok, this is epic.") break;
case(86): draw_text(5,5,"Rest in peace Technoblade") break;
case(87): draw_text(5,5,"Meme Review") break;
case(88): draw_text(5,5,"That's an great price.") break;
case(89): draw_text(5,5,"Try Destruction Darius.") break;
case(90): draw_text(5,5,"Thanks 3kilksphilip for the permission to use your songs!") break;
case(91): draw_text(5,5,"Play 'Jimmy's Unlikely Resurrection' on Newgrounds, and you might be suprised.") break;
case(92): draw_text(5,5,"Up to date!") break;
case(93): draw_text(5,5,"Where's the 6th color?!!?!?!") break;
case(94): draw_text(5,5,"Lmao") break;
case(95): draw_text(5,5,"^_^") break;
case(96): draw_text(5,5,"PRO TIP: Look the level closely before you play.") break;
case(97): draw_text(5,5,"Performance? Go to settings to make it better!") break;
case(98): draw_text(5,5,"For Starters, play on Normal Mode.") break;
case(99): draw_text(5,5,"Actually, the game just runs too well.") break;
case(100): draw_text(5,5,"In the code, this is the official 100th splash text.") break;
case(101): draw_text(5,5,"12345 is a bad password.") break;
case(102): draw_text(5,5,"Cool music.") break;
case(103): draw_text(5,5,"CRT Monitor Gang where yall at?") break;
case(104): draw_text(5,5,"I love the 90s") break;
case(105): draw_text(5,5,"Welcome to your doom!") break;
case(106): draw_text(5,5,loc(299)) break;
case(107): draw_text(5,5,"https://discord.gg/NU5ZeE5") break;
case(108): draw_text(5,5,"Speedrunners are awesome!") break;
case(109): draw_text(5,5,"Roses are red, violets are blue...") break;
case(110): draw_text(5,5,"Clouds are sometimes cool.") break;
case(111): draw_text(5,5,"Made for speedrunners in mind!") break;
case(112): draw_text(5,5,"Try Out Hard Mode!") break;
case(113): draw_text(5,5,"Don't clip through the walls!") break;
case(114): draw_text(5,5,"Backrooms are scary!") break;
case(115): draw_text(5,5,"What's Up!") break;
case(116): draw_text(5,5,"This is a randomly chosen splash text...") break;
case(117): draw_text(5,5,"sv_cheats 1") break;
case(118): draw_text(5,5,"Thank you.") break;
case(119): draw_text(5,5,"Damnnn") break;
case(120): draw_text(5,5,"Big Brain") break;
case(121): draw_text(5,5,"smoool brain") break;
case(122): draw_text(5,5,"What?!") break;
case(123): draw_text(5,5,"Remember when the game used to be free? Yeah...") break;
case(124): draw_text(5,5,"Awesome Edition.") break;
case(125): draw_text(5,5,"High refresh rate options are a mistake") break;
case(126): draw_text(5,5,"FINALLY SLOPES! WOWWWIEEE1!!") break;
case(127): draw_text(5,5,"Slope around!") break;
case(128): draw_text(5,5,"Spin the wheel baby!") break;
case(129): draw_text(5,5,"Hat Merchant can be accessed in the menu if you meet him in-game.") break;
case(130): draw_text(5,5,"Grind for hats!") break;
case(131): draw_set_font(fnt_secret1)
	draw_text(5,5,"Pixel Font!") break;
case(132): draw_set_color(c_red)
draw_text(5,5,"This text is red.") break;
case(133): draw_set_color(c_yellow)
draw_text(5,5,"This text is yellow.") break;
case(134): draw_set_color(c_green)
draw_text(5,5,"This text is green.") break;
case(135): draw_set_color(c_blue)
draw_text(5,5,"This text is blue.") break;
case(136): draw_set_color(c_purple)
draw_text(5,5,"This text is purple.") break;
case(137): draw_set_color(c_lime)
draw_text(5,5,"This text is lime.") break;
case(138): draw_set_color(c_silver)
draw_text(5,5,"This text is silver.") break;
case(139): draw_set_color(c_orange)
draw_text(5,5,"This text is orange.") break;
case(140): draw_set_color(c_dkgray)
draw_text(5,5,"This text is dark gray.") break;
case(141): draw_text(5,5,"You are special.") break;
case(142): draw_text(5,5,"I love you.") break;
case(143): draw_text(5,5,"There is so much level editor possibilities!") break;
case(144): draw_text(5,5,"Needs more features!") break;
case(145): draw_text(5,5,"Big Brother is watching you.") break;
case(146): draw_text(5,5,"Performance issues? FPS Drops? Go mess around in the settings!") break;
case(147): draw_text(5,5,"'This game is pretty optimized' - People") break;
case(148): draw_text(5,5,"Thank you Scotrian.") break;
case(149): draw_text(5,5,"Thank you TheDuckLord.") break;
case(150): draw_text(5,5,"Cruel World") break;
case(151): draw_text(5,5,"Thank you Nightmareyoc.") break;
case(152): draw_text(5,5,"Thank you caoullion.") break;
case(153): draw_text(5,5,"Oh boy cannot wait!") break;
case(154): draw_text(5,5,"QWERTY!") break;
case(155): draw_text(5,5,"Soundtrack mostly by Infiland!") break;
case(156): draw_text(5,5,"Skin Tip: Unlock the mad skin by beating the hotdog!") break;
case(157): draw_set_color(make_color_rgb(red,green,blue))
draw_text(5,5,"This piece of text has a color of RAINBOW.") break;
case(158): draw_text(5,5,"With the help of Sundalanian.") break;
case(159): draw_text(5,5,"I hate bugs in my game.") break;
case(160): draw_text(5,5,"R A N D O M I Z E D   U S E L E S S   T E X T . . .") break;
case(161): draw_text(5,5,"World Wide Web.") break;
case(162): draw_text(5,5,"Your text could be HERE!") break;
case(163): draw_set_color(make_color_rgb(red,green,blue))
draw_text(5,5,"Bajan Serbian!") break;
case(164): draw_text(5,5,"Some hats are expensive, but you can get a discount if you buy hats in hardmode!") break;
case(165): draw_text(5,5,"Epic gamer moment!") break;
case(166): draw_text(5,5,"Like the soundtrack? Buy it on Steam!") break;
case(167): draw_text(5,5,"Alo") break;
case(168): draw_text(5,5,"Every skin you unlock here in this game is free!") break;
case(169): draw_text(5,5,"No artist can match Reddie's craft.") break;
case(170): draw_text(5,5,"Good luck mate!") break;
case(171): draw_text(5,5,"gg") break;
case(172): draw_text(5,5,"Good Game") break;
case(173): draw_text(5,5,"How much text is there?") break;
case(174): draw_text(5,5,"....seems infinite...") break;
case(175): draw_text(5,5,"In the game you used to spend 5 coins instead of 4 to skip a level. What a discount!") break;
case(176): draw_text(5,5,"Damn son.") break;
case(177): draw_text(5,5,"ARGGGHHH") break;
case(178): draw_text(5,5,"Ahoy player, 'tis time fer an adventure!") break;
case(179): draw_text(5,5,"As a dev, I hate networking.") break;
case(180): draw_text(5,5,"NOW WITH LOCAL MULTIPLAYER.") break;
case(181): draw_text(5,5,"who's joe") break;
case(182): draw_text(5,5,"You bought TCC, or maybe you didn't. Whatever, thanks for trying it out.") break;
case(183): draw_text(5,5,"PRO TIP: EACH spike has 0.01% chance of becoming weird.") break;
case(184): draw_text(5,5,"Can't touch this.") break;
case(185): draw_text(5,5,"PRO TIP: EACH spike has 0.1% chance of becoming golden.") break;
case(186): draw_text(5,5,"New Main Menu Music!") break;
case(187): draw_text(5,5,"Save Magenta.") break;
case(188): draw_text(5,5,"Endless fun.") break;
case(189): draw_text(5,5,"Endless rage.") break;
case(190): draw_text(5,5,"Join our discord in the support section!") break;
case(191): draw_text(5,5,"3D Blocks included!") break;
case(192): draw_text(5,5,"Subscribe to me on youtube!") break;
case(193): draw_text(5,5,"PS1 graphics included!") break;
case(194): draw_text(5,5,"You're looking good with that skin.") break;
case(195): draw_text(5,5,"Each world has 20 levels in the main campaign!") break;
case(196): draw_text(5,5,"VGhpcyB0ZXh0IGlzIGVuY29kZWQgdG8gQmFzZTY0") break;
case(197): draw_text(5,5,"- .... .. ... / - . -..- - / .. ... / . -. -.-. --- -.. . -.. / - --- / -- --- .-. ... . / -.-. --- -.. .") break;
case(198): draw_text(5,5,"Are you even reading this?") break;
case(199): draw_text(5,5,"Finally the game's done.") break;
case(200): draw_text(5,5,"Asteroids ++ is free, you know?") break;
case(201): draw_text(5,5,"New challenges await!") break;
case(202): draw_text(5,5,"You can finally use a controller!") break;
case(203): draw_text(5,5,"Click on achievements to amaze yourself!") break;
case(204): draw_text(5,5,"In the game, the player used to have 3 frames per color, now it has NINE!") break;
case(205): draw_text(5,5,"Some skins include 45 frames of animations! Damn isn't that frustraiting...") break;
case(206): draw_text(5,5,"I sometimes forget what I write here in splash texts.") break;
case(207): draw_text(5,5,"Made with Gamemaker Studio 2, with the Desktop Licence on Steam.") break;
case(208): draw_text(5,5,"Customize your look in the Skins Menu which is in Fun Mode.") break;
case(209): draw_text(5,5,"Wanna look different? Go to the skins menu in fun mode.") break;
case(210): draw_text(5,5,"G U N") break;
case(211): draw_text(5,5,"Pew Pew Peeeeew.") break;
case(212): draw_text(5,5,"Achievements included.") break;
case(213): draw_text(5,5,"Would you like a cup of tea?") break;
case(214): draw_text(5,5,"Can run on almost every single computer.") break;
case(215): draw_text(5,5,"OPTIMIZATION ON.") break;
case(216): draw_text(5,5,"How many texts are there?") break;
case(217): draw_text(5,5,"Collect ammo in the game when you get a weapon.") break;
case(218): draw_text(5,5,"PRO TIP: You can destroy homing rockets and enemy bullets with your own bullets.") break;
case(219): draw_text(5,5,"Press [" + global.controlsinteract + "] to interact with the gun and interactable collectables.") break;
case(220): 	randomize()
	rng = irandom_range(10000,99999)
	draw_text(5,5,"I like random numbers [" + string(rng) + "]")  break;
case(221): draw_text(5,5,"Crazy Stuff I must say...") break;
case(222): draw_text(5,5,"Slaying the bugs.") break;
case(223): draw_text(5,5,"E") break;
case(224): draw_text(5,5,"Current version is " + string(version)) break;
case(225): draw_text(5,5,"This game is now available on Steam.") break;
case(226): draw_text(5,5,"I can happily say that TCC is available on Android.") break;
case(227): 	draw_text(5,5,"v i b e    c h e c k") 
	draw_sprite(s_gun,-1,180,5) break;
case(228): draw_text(5,5,"Runs even on 1 GHZ Computers.") break;
case(229): draw_text(5,5,"Wow!") break;
case(230): draw_text(5,5,"My Kyboard dosn't work, my E ky is malfunctioning. Plas hlp m...") break;
case(231): draw_text(5,5,"Protip: If you are stuck in story mode, try reseting progress to gain coins again, don't worry you")
draw_text(5,25,"will get better in your second run.") break;
case(232): draw_text(5,5,"About 1GB of RAM Required.") break;
case(233): draw_text(5,5,"Rest in Peace Windows 7") break;
case(234): draw_text(5,5,"Rest in Peace Windows XP") break;
case(235): draw_text(5,5,"You can press ["+ global.controlsinteract + "] to interact with some stuff in the game.") break;
case(236): draw_text(5,5,"Level Editor has over a million possible combinations.") break;
case(237): draw_text(5,5,"Legendary Skins are harder to get in the game. Find a way to unlock them.") break;
case(238): draw_text(5,5,"Your current FPS is: " + string_hash_to_newline(string_format(fps_real,1,0)) + "! Sadly locked on " + string(fps) + "FPS.") break;
case(239): draw_text(5,5,"How do you do fellow player?") break;
case(240): draw_text(5,5,"Report bugs by clicking the 'Support' button in the title menu.") break;
case(241): draw_text(5,5,"Rest in Peace Windows 8... Actually I take that back.") break;
case(242): draw_text(5,5,"You can now make large levels!") break;
case(243): draw_text(5,5,"If you want a precise timer while playing, go to settings and disable 'Time Decimals'.") break;
case(244): draw_text(5,5,"Horray.") break;
case(245): draw_text(5,5,"!sdrawkcab si txet sihT") break;
case(246): draw_text(5,5,"Thank you for downloading the game!") break;
case(247): draw_text(5,5,"One day I might even repeat myself up here, maybe I won't, who knows...") break;
case(248): draw_text(5,5,"If you wanna see how long you've played in total, check your stats then!") break;
case(249): draw_text(5,5,"Dooooooooooot") break;
case(250): draw_text(5,5,"This is the official 250th splash text, what am I doing with my life.") break;
case(251): draw_text(5,5,"I've wrote so many text messages in this title menu.") break;
case(252): 	draw_set_font(global.classicfont)
	draw_text(5,5,"beat the troop trouble challenge") break;
case(253): 	draw_set_font(global.classicfont)
	draw_text(5,5,"collect 5000 coins") break;
case(254): 	draw_set_font(global.classicfont)
	draw_text(5,5,"i am your friend, trust me, i will help you out") break;
case(255): draw_text(5,5,"Laugh out loud.") break;
case(256): draw_text(5,5,"I AM MAKING A NEW GAME, ASTEROIDS++! CHECK IT OUT!") break;
case(257): draw_text(5,5,"Wish I knew FL Studio better so I can make cooler music lol...") break;
case(258): draw_text(5,5,"PRO TIP: While blue, you can accelerate faster on ice blocks.") break;
case(259): draw_text(5,5,"PRO TIP: While white, you can accelerate slower on ice blocks.") break;
case(260): draw_text(5,5,"Sorry for the big wait...") break;
case(261): draw_text(5,5,"Now with unrealistic physics!") break;
case(262): draw_text(5,5,"Now with Ice Blocks and Boxes!") break;
case(263): draw_text(5,5,"Did you know that colored photography began in 1840's?") break;
case(264): draw_text(5,5,"Are you entertained?") break;
case(265): draw_text(5,5,"Sit tight.") break;
case(266): draw_text(5,5,"Stay Safe!") break;
case(267): draw_text(5,5,"Backgrounds are now a thing. Cool!") break;
case(268): draw_text(5,5,"Look how pretty this looks!") break;
case(269): draw_text(5,5,"PRO TIP: Go back and fourth in menus to see different texts! You may find something...") break;
case(270): draw_text(5,5,"Did you know that the game was corrupted at one point? Yea, crazy right?") break;
case(271): draw_text(5,5,"PRO TIP: This is a pro tip?") break;
case(272): draw_set_font(global.classicfont)
	draw_text(5,5,"keep winning hardmode difficulties") break;
case(273): draw_set_font(global.classicfont)
	draw_text(5,5,"there is more to this game") break;
case(274): draw_text(5,5,"Slopes are not broken at all") break;
case(275): draw_text(5,5,"Handshake!") break;
case(276): draw_set_font(global.classicfont)
draw_text(5,5,"win world 6 under 25 deaths") break;
case(277): draw_text(5,5,"PRO TIP: In some hard levels, if you have a ton of deaths, they get easier for newbies.") break;
case(278): draw_text(5,5,"There are secrets scattered in the game, go ahead and find them!") break;
case(279): draw_text(5,5,"It's your host...") break;
case(280): draw_text(5,5,"Keep it up, proud of you.") break;
case(281): draw_text(5,5,"Du tu ruu.") break;
case(282): draw_text(5,5,"Join the party.") break;
case(283): draw_text(5,5,"Do Re Mi Fa Sol La Si Do") break;
case(284): draw_text(5,5,"You can just go to a different part of the main menu and come back to see this text change again.") break;
case(285): draw_text(5,5,"I AM JUST SPLASH TEXT PLEASE DON'T GO OR I WILL DIE!") break;
case(286): draw_text(5,5,"idkman") break;
case(287): draw_text(5,5,"What's 9 plus 10?") break;
case(288): draw_text(5,5,"PRO TIP: 1UPS in hardmode have a bigger hitbox than coins!") break;
case(289): draw_text(5,5,"LUL") break;
case(290): draw_text(5,5,"Thanks PowerMaster") break;
case(291): draw_text(5,5,"Check your stats!") break;
case(292): draw_text(5,5,"Zzzzzzzzzzz") break;
case(293): draw_text(5,5,"Color or Colour? Who cares it's the same thing!") break;
case(294): draw_text(5,5,"Stay hydrated.") break;
case(295): draw_text(5,5,"This has to be the game of the year") break;
case(296): draw_text(5,5,"1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40") break;
case(297): draw_text(5,5,"Don't protest.") break;
case(298): draw_text(5,5,"Are you excited?") break;
case(299): draw_text(5,5,"Hey you can try out the new calendar!") break;
case(300): draw_text(5,5,"Yo.") break;
case(301): draw_text(5,5,"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z") break;
case(302): draw_text(5,5,"Check your achievements!") break;
case(303): draw_text(5,5,"Welcome to the game!") break;
case(304): draw_text(5,5,"Welcome Back!") break;
case(305): draw_text(5,5,"How hard can this possibly be?") break;
case(306): draw_text(5,5,"Want more levels? Go to Start > Fun Mode > Challenges!") break;
case(307): draw_text(5,5,"Protip: When you beat a challenge you get a reward! (eg. skin)") break;
case(308): draw_text(5,5,"V\ne\nr\nt\ni\nc\na\nl") break;
case(309): draw_text(5,5,"Ever saw a golden spike?") break;
case(310): draw_text(5,5,"Protip: Every world in storymode has an unique boss.") break;
case(311): draw_text(5,5,"What are you looking at?") break;
case(312): draw_text(5,5,"Do you like the game? Check the support section!") break;
case(313): draw_text(5,5,"Join our discord server to hear about upcoming updates!") break;
case(314): draw_text(5,5,"Endless run is available in funmode. How long can you last?") break;
case(315): draw_text(5,5,"Settings!") break;
case(316): draw_text(5,5,"You can choose settings presets to quickly adjust the quality settings.") break;
case(317): draw_text(5,5,"The Calendar contains user levels created by the community, so don't complain!") break;
case(318): draw_text(5,5,"How cool is all of this?") break;
case(319): draw_text(5,5,"It keeps... expanding...") break;
case(320): draw_text(5,5,"Endless run features endless content, or does it?") break;
case(321): draw_text(5,5,"Click play!") break;
case(322): draw_text(5,5,"Now running in a better compiler.") break;
case(323): draw_text(5,5,"Writing this feels like writing a book, sort of.") break;
case(324): draw_text(5,5,"Five little monkeys jumping on the bed.") break;
case(325): draw_text(5,5,"A lot of these are plain garbage text.") break;
case(326): draw_text(5,5,"Lost to color.") break;
case(327): draw_text(5,5,"If you pressed F3, you can enable debug windows.") break;
case(328): draw_text(5,5,"If you pressed F4, you can quickly fullscreen.") break;
case(329): draw_text(5,5,"Pog") break;
case(330): draw_text(5,5,"How bro?") break;
case(331): draw_text(5,5,"Yeah.") break;
case(332): draw_text(5,5,"That's a cool title!") break;
case(333): draw_text(5,5,"There are probably millions of these.") break;
case(334): draw_text(5,5,"/v/") break;
case(335): 	draw_set_font(global.classicfont)
	draw_text(5,5,"Get a highscore of 50 in endless run.")  break;
case(336): draw_text(5,5,"??????????") break;
case(337): draw_text(5,5,"!!!!!!!!!!") break;
case(338): draw_text(5,5,"10 GOTO 20") break;
case(339): draw_text(5,5,"Simple as that.") break;
case(340): draw_text(5,5,":)") break;
case(341): draw_text(5,5,"If you want to support me, you can click the button in the bottom left. Thanks :)") break;
case(342): draw_text(5,5,"Unlock a skin!") break;
case(343): draw_text(5,5,"Beat a challenge!") break;
case(344): draw_text(5,5,"Change controls in settings if you don't think they are suitable.") break;
case(345): draw_text(5,5,"Even your grandma's computer won't have issues running this!") break;
case(346): draw_text(5,5,"overusing if else is quite bad") break;
case(347): draw_text(5,5,"Now with something!") break;
case(348): draw_text(5,5,"No running in the halls") break;
case(349): draw_text(5,5,"When will you learn?") break;
case(350): draw_text(5,5,"Actions have consequences.") break;
case(351): draw_text(5,5,"printf(''Hello'');") break;
case(352): draw_text(5,5,"Play another game from Infiland, Monophobia!") break;
case(353): draw_text(5,5,"Wahooooo!") break;
case(354): draw_text(5,5,"Shoutouts to Simpleflips.") break;
case(355): draw_text(5,5,"Shoutout to yall.") break;
case(356): draw_text(5,5,"This is crazy!") break;
case(357): draw_text(5,5,"Please report bugs in the Bug reporter. It is in the support section.") break;
case(358): draw_text(5,5,"Check the official twitter account: @TCC_Game") break;
case(359): draw_text(5,5,"You can enable custom splash texts in settings") break;
case(360): draw_text(5,5,"Node Graph out of Date. Rebuilding...") break;
case(361): draw_text(5,5,"Features: More splash texts! Lovely.") break;
case(362): draw_text(5,5,"L is Real 2401") break;
case(363): draw_text(5,5,"One day, you will see this text once again, filling you with satisfying or unsatisfying moments.") break;
case(364): draw_text(5,5,"There is a story of a man named Stanley...") break;
case(365): draw_text(5,5,"Speedrunning is real in this game.") break;
case(366): draw_set_color(make_color_rgb(red,green,blue))
draw_text(5,5,"W1% | bobinsky01 | 1:29:510") break;
case(367): draw_text(5,5,"BREAKING NEWS!") break;
case(368): draw_set_color(make_color_rgb(red,green,blue))
draw_text(5,5,"Why is this specific text in rainbow color? We don't know. Don't ask. Maybe it's for the best.") break;
case(369): draw_text(5,5,"Is this my life now? Writing hundreds or maybe infinite lines of text and code in here?") break;
case(370): draw_text(5,5,"Don't write anything in the skin menu in page 2. Oh wait, I shouldn't have said that.") break;
case(371): draw_text(5,5,string(diffmonth) + " months ago was when the game development started.") break;
case(372): draw_text(5,5,string(diffyear) + " years ago was when the game development started.") break;
case(373): draw_text(5,5,string(string_format(diffsecond,0,0)) + " seconds ago was when the game development started.") break;
case(374): draw_text(5,5,"Why are you reading this? Like what is so important in this text?") break;
case(375): 
if clicked = false {
draw_text(5,5,"DON'T CLICK ME!") 
} else { draw_text(5,5,"Jebaited.") } 
break;
case(376): draw_text(5,5,"Hello there sir.") break;
case(377): draw_text(5,5,"A lot of new stuff!") break;
case(378): draw_text(5,5,"A lot of optimizations were made, like... a lot!") break;
case(379): draw_text(5,5,"Hi there! Would you like to sign a petition?") break;
case(380): draw_text(5,5,"Everybody do a flop!") break;
case(381): draw_text(5,5,"It's muffin time!") break;
case(382): draw_text(5,5,"I like trains") break;
case(383): draw_text(5,5,"EXTRA PRECISE!") break;
case(384): draw_text(5,5,"What is the meaning of life?") break;
case(385): draw_text(5,5,"All splashes here are unimportant. OR ARE THEY?") break;
case(386): draw_text(5,5,"Splash!") break;
case(387): draw_text(5,5,"Did you know you can type in the skin menu? Wait, nevermind...") break;
case(388): draw_text(5,5,"This is ridonculous!") break;
case(389): draw_text(5,5,"How many attempts you've wasted on kaizo challenge?") break;
case(390): draw_text(5,5,"Where are the other colors?") break;
case(391): draw_text(5,5,"Don't read this!") break;
case(392): 
somethingwillhappen -= (0.016666666666665 * global.delta) * (60 / global.maxfps)
if somethingwillhappen > 0 {
draw_text(5,5,"Something will happen in: " + string(somethingwillhappen) + " seconds...")
} else { draw_text(5,5,"It happened.") 
	if !steam_get_achievement("IT_HAPPENED") { steam_set_achievement("IT_HAPPENED") }
	}
break;
case(393): draw_text(5,5,"Hi chat :)") break;
case(394): draw_text(5,5,"Thank you guys.") break;
case(395): draw_text(5,5,"Created by a single developer, Infiland.") break;
case(396): draw_text(5,5,"Cheeseus.") break;
case(397): draw_text(5,5,"Zorch!") break;
case(398): draw_text(5,5,"Speedrunner friendly!") break;
case(399): draw_text(5,5,"Cookies: " + string(global.cookies)) break;
case(400): draw_text(5,5,"F***") break;
case(401): draw_text(5,5,"Thy flesh consumed.") break;
case(402): draw_text(5,5,"Inferno.") break;
case(403): draw_text(5,5,"The shores of hell.") break;
case(404): draw_text(5,5,"ERROR 404") break;
case(405): draw_text(5,5,"Knee-Deep in the dead.") break;
case(406): draw_text(5,5,"1,094,795,585!") break;
case(407): draw_text(5,5,"Since there is rich presence, you can see if other people are playing TCC!") break;
case(408): draw_text(5,5,"Kitchen gun. BANG! BANG! BANG!") break;
case(409): draw_text(5,5,"Kifflom") break;
case(410): draw_text(5,5,"Thanks Monou for the Linux Support.") break;
case(411): draw_text(5,5,"Not inspired by Red Ball.") break;
case(412): draw_set_font(global.classicfont)
draw_text(5,5,"Beat hardmode on insane difficulty.") break;
case(413): draw_text(5,5,"Up Down Up Down Left Right Left Right B A Start") break;
case(414): draw_text(5,5,"Du, duru ru ru, du ru ru ruu") break;
case(415): draw_text(5,5,"Super Hexagon") break;
case(416): draw_text(5,5,"If you are colorblind, go to visual settings and pick your preferable setting!") break;
case(417): draw_text(5,5,"Penguins are glad to hear that a linux port is finally here!") break;
case(418): draw_text(5,5,"Wake up Reddie, we have troops to burn.") break;
case(419): draw_text(5,5,"No taxes included!") break;
case(420): draw_text(5,5,"It's time to kick ass and chew bubblegum.") break;
case(421): draw_text(5,5,"Protip: You can also get credits in challenges, hardmode, endless run and by converting coins into\ncredits.") break;
case(422): draw_text(5,5,"Not inspired by Bouncy Tales.") break;
case(423): draw_text(5,5,"3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679") break;
case(424): draw_set_font(global.classicfont)
draw_text(5,5,"The clock must make two full cycles.") break;
case(425): draw_text(5,5,"Wanna play with friends? Try local multiplayer.") break;
case(426): draw_text(5,5,"Do you want 'endless' content? Try endless run!") break;
case(427): draw_text(5,5,"Petition to make more splashtexts") break;
case(428): draw_text(5,5,"Every splash text is special!") break;
case(429): draw_text(5,5,"Every game needs splash texts!") break;
case(430): draw_text(5,5,"I have no strong feelings one way or the other.") break;
case(431): draw_text(5,5,"Why is Reddie starting out as specifically red?") break;
case(432): draw_text(5,5,"DOWNWARD SPIRAL DOWNWARD SPIRAL DOWNWARD SPIRAL DOWNWARD SPIRAL DOWNWARD SPIRAL DOWNWARD SPIRAL DOWNWARD SPIRAL") break;
case(433): draw_text(5,5,"The invisible skin is not a bug, it's a feature!") break;
case(434): draw_text(5,5,"If you have any feedback please visit the support section!") break;
case(435): draw_text(5,5,"Found a nasty bug? Please visit the support section!") break;
case(436): draw_text(5,5,"Do you want us to add something new? Please visit the support section!") break;
case(437): draw_text(5,5,"Introducing Custom Endless Run! Customize Endless Possibilities!") break;
case(438): draw_text(5,5,"Want MAXIMUM DETAIL? Go to settings and click the 'high' quality preset :)") break;
case(439): draw_text(5,5,"Missed old gravity sprites? (You know, the ones with numbers?) Go to settings to change them!") break;
case(440): draw_text(5,5,"Fun Fact: The Tutorial in W1-L1 and W1-L2 doesn't appear in Endless Run") break;
case(441): draw_text(5,5,"I know what you are doing, you are reading this text, aren't you.") break;
case(442): draw_text(5,5,"This text will be ignored by many.") break;
case(443): draw_text(5,5,"THIS TEXT WILL BE NOTICED BY MANY!") break;
case(444): 
switch(global.creditscurrency) {
case(0): draw_text(5,5,"You've got no credits, shame on you.") break;
default: draw_text(5,5,"You've got "+ string(global.creditscurrency) + " credits, nice I guess.") break;
}
break;
case(445):
if global.world1 = 0 { draw_text(5,5,"What? You are telling me that you HAVEN'T BEATEN the first world yet?!") } else {
draw_text(5,5,"Reddie's adventure begins...") }
break;
case(446):
if global.world2 = 0 { draw_text(5,5,"At some point you'll see spikes in the game.") } else {
draw_text(5,5,"Spikes are nothing compared to you!") }
break;
case(447):
if global.world3 = 0 { draw_text(5,5,"Moving platforms don't behave how you would expect them to behave.") } else {
draw_text(5,5,"Now you know how bad the moving platforms are.") }
break;
case(448):
if global.world4 = 0 { draw_text(5,5,"CORRUPpTION AwAITS") } else {
draw_text(5,5,"ThANKs FoR VISsssItTiNnnG tHE cOrrUptEd!") }
break;
case(449):
if global.world5 = 0 { draw_text(5,5,"The Castle's Door Opens!") } else {
draw_text(5,5,"The king is waiting for you.") }
break;
case(450): draw_text(5,5,"Rarer than a CS:GO knife. Take that Gabe!") break;
case(451): draw_text(5,5,"More splash texts than Minecraft. Take that Mojang!") break;
case(452): draw_text(5,5,"Welcome to the 'SUPA DUPA PREMIUM VERSION' of The Colorful Creature! Only on Steam!") break;
case(453): draw_text(5,5,"So, you've bought the game! Thank you very much! (unless you got a key lol)") break;
case(454): draw_text(5,5,"Waah! Golden Legendary!") break;
case(455): draw_text(5,5,"The Dopefish Lives!") break;
case(456): if !steam_get_achievement("EASTEREGG_1") {
draw_text(5,5,"The Egg was not found...")
} else { draw_text(5,5,"The Egg was found!") }
break;
case(457): draw_text(5,5,"The game started " + string(current_time / 1000) +" seconds ago") break;
case(458): draw_text(5,5,"A nightmare is better than a lucid nightmare...") break;
case(459): draw_text(5,5,"alt f4 for god mode") break;
case(460): draw_text(5,5,"Buttons look so HD!") break;
case(461): draw_text(5,5,"One like = one prayer") break;
case(462): draw_text(5,5,"It's been 6 months since the dev server posted a splashtext help") break;
case(463): draw_text(5,5,"Player 3 deserves a break man :(") break;
case(464): draw_text(5,5,"Sydew says hello from the top secret dev server!") break;
case(465): draw_text(5,5,"dha too op") break;
case(466): draw_text(5,5,"Speedrunning is fun.") break;
case(467): draw_text(5,5,"Play Monthly Endless Run to get those badges in the menu!") break;
case(468): draw_text(5,5,"STOP POSTING ABOUT 4:3 I'M TIRED OF SEEING IT, MY FRIENDS ON TIKTOK SEND ME MEMES ON DISCORD IT'S") break;
case(469): draw_text(5,5,"Steam Achievements is the best thing humanity invented.") break;
case(470): draw_text(5,5,"According to all known laws of aviation, there is no way a bee should be able to fly.") break;
case(471): draw_text(5,5,"Is anyone reading these?") break;
case(472): draw_text(5,5,"Did you know that Infiland loves drinking water?") break;
case(473): draw_text(5,5,"Failing W1-L1 since 2018!") break;
case(474): draw_text(5,5,"Did you know that 1 + 1 is 2?") break;
case(475): draw_text(5,5,"BREAKING NEWS: Chickens are invading space by laying eggs out!") break;
case(476): draw_text(5,5,"Worth 3.49 Euros!") break;
case(477): draw_text(5,5,"The entire game was made faster than Geometry Dash 2.2") break;
case(478): draw_text(5,5,"RubRub") break;
case(479): draw_text(5,5,"Infiland is " + string(diffyearinfi) + " years old!") break;
case(480): draw_text(5,5,"Big levels in level editor when???") break;
case(481): draw_text(5,5,"amogo") break;
case(482): draw_text(5,5,"I like memes, you like memes, we all like memes.") break;
case(483): draw_text(5,5,"Why do I keep updating this?") break;
case(484): draw_text(5,5,"Splashtext code alone has over 1000 lines, what the f") break;
case(485): draw_text(5,5,"Roasting myself: All levels are red.") break;
case(486): draw_text(5,5,"We love Geometry Dash!") break;
case(487): draw_text(5,5,"W5-L20 is the hardest level because it crashes.") break;
case(488): draw_text(5,5,"DON'T PLAY TCC AT 3AM (CURSED)") break;
case(489): draw_text(5,5,"This game's broken lo-") break;
case(490): draw_text(5,5,"I wanna be the very best") break;
case(491): draw_text(5,5,"Get deez diamond medalz") break;
case(492): draw_text(5,5,"Did you know that Infiland loves Steam Achievements?") break;
case(493): draw_text(5,5,"Probably can be played on the SteamDeck, maybe...") break;
case(494): draw_text(5,5,"Now you can play custom levels! Sort of.") break;
case(495): draw_text(5,5,"The Calendar is going to doom us all!") break;
case(496): draw_text(5,5,"What if I added more colors?") break;
case(497): draw_text(5,5,"Super Difficult!") break;
case(498): draw_text(5,5,"the end is never the end is never the end is never end is never the end is never the end is never the end") break;
case(499): draw_text(5,5,"He entered in the door on his left.") break;
case(500): draw_text(5,5,"What if the super artificial intelligence is writing this splash text? Hm...") break;
case(501): draw_text(5,5,"Kaizo Challenge 2 when?") break;
case(502): draw_text(5,5,"World 7 when?") break;
case(503): draw_text(5,5,"Thanks dha for translating in Italian!") break;
case(504): draw_text(5,5,"Thanks BLaacK for translating in German!") break;
case(505): draw_text(5,5,"Thanks KD_10 for translating in German!") break;
case(506): draw_text(5,5,"Thanks Reisch for translating in German!") break;
case(507): draw_text(5,5,"Thanks Maghreb for translating in French!") break;
case(508): draw_text(5,5,"Thanks devc for translating in German!") break;
case(509): draw_text(5,5,"Mortis!") break;
case(510): draw_text(5,5,"Thanks SuperYoshi_13 for translating in Spanish!") break;
case(511): draw_text(5,5,"Thanks Nightmareyoc for translating in Hungarian!") break;
case(512): draw_text(5,5,"Thanks Infiland for nothing!") break;
case(513): draw_text(5,5,"Geez, the youth these days!") break;
case(514): 	draw_set_font(global.classicfont)
	draw_text(5,5,"beat a world that has been locked by the previous one") break;
case(515): draw_text(5,5,"Why are people paying for Discord Nitro anyway? (Discord don't sue plz)") break;
case(516): draw_text(5,5,"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA") break;
case(517): draw_text(5,5,"If you are playing this on steam, thanks :)") break;
case(518): draw_text(5,5,"You can now share your levels on Steam Workshop!") break;
case(519): draw_text(5,5,"Pssst, there are hidden worlds that you can find!") break;
case(520): draw_text(5,5,"Nope, we aren't changing the Twitter logo.") break;
case(521): draw_text(5,5,"What do you mean there's a 7th world?") break;
case(522): draw_text(5,5,"Do you understand anything? If not, you can change languages!") break;
case(523): draw_text(5,5,"TCC 2: Golden Disc, includes infinite colors, 16:9 aspect ratio, and more!") break;
case(524): draw_text(5,5,"The best purchase of your life!") break;
case(525): draw_text(5,5,"y u do dis?") break;
case(526): draw_text(5,5,"A small loan of a million dollars.") break;
case(527): draw_text(5,5,"Buttons are more sexier on Steam!") break;
case(528): draw_text(5,5,"DMCA-Free!") break;
case(529): draw_text(5,5,"Infiland REALLY likes water!") break;
case(530): draw_text(5,5,"The Factory Must Grow...") break;
case(531): draw_text(5,5,"0.0.1 > Steam Version") break;
case(532): draw_text(5,5,"According to all known laws of aviation, there is no way that a bee should be able to fly. It's wings are") break;
case(533): draw_text(5,5,"Ski-Ba-Bop-Ba-Dop-Bop!") break;
case(534): draw_text(5,5,"Spikes are never your friends, don't forget that!") break;
case(535): draw_text(5,5,"Workshop is here!") break;
case(536): draw_text(5,5,"Infiland hates multiplayer games, that's why he sucks at networking!") break;
case(537): draw_text(5,5,"Who even put this here?") break;
case(538):
switch(global.hardmodeunlock) {
case(0): draw_text(5,5,"Did you know there was hardmode in the game? Wait...") break;
case(1): draw_text(5,5,"So it begins") break;
case(2): draw_set_color(c_red)
draw_text(5,5,"And you've chosen death.") break;
case(3): draw_set_color(c_red)
draw_text(5,5,"You have no idea what you are getting yourself into") break;
case(4): draw_set_color(c_red)
draw_text(5,5,"It is simply ridiculous") break;
case(5): draw_set_color(c_red)
draw_text(5,5,"It's an impossible task") break;
case(6): draw_set_color(c_red)
draw_text(5,5,"There's a lot of luck involved") break;
case(7): draw_set_color(c_red)
draw_text_scribble(5,5,"[shake][c_red]ETERNAL SUFFERING ETERNAL SUFFERING ETERNAL SUFFERING ETERNAL SUFFERING ETERNAL SUFFERING ") break;
case(8): draw_set_color(c_lime)
draw_text(5,5,"[rainbow][wave]You did it no more suffering :)")
break;
}
break;
case(539): draw_text(5,5,"999,999,999+ Social Credits (for playing TCC)") break;
case(540): draw_text(5,5,"The official soundtrack of TCC is now also on Steam!") break;
case(541): draw_text(5,5,"Slopes when?") break;
case(542): draw_text(5,5,"You can play workshop levels!") break;
case(543): draw_text(5,5,"You can publish your workshop levels in the level editor!") break;
case(544): draw_text(5,5,"reeeeee") break;
case(545): draw_text(5,5,"Damn son, where'd ya find this?") break;
case(546): draw_text(5,5,"Mom get the camera") break;
case(547): draw_text(5,5,"This is the future of gaming") break;
case(548): draw_text_scribble(5,5,"[wave][rainbow]INSANEEEEEEEEEEE[/wave][/rainbow]") break;
case(549): draw_text_scribble(5,5,"[pulse][c_red]Don't touch that dial now, we are just getting started...") break;
case(550): draw_text_scribble(5,5,"I died on LADDER-L3[scale,0.2]  [s_skull]") break;

//Impossible Splashes
case(-1): draw_set_color(make_color_rgb(red,green,blue)) 
draw_text_scribble(5,5,"[scale,2]"+ string(round(diffyear)) + "TH YEAR!") break;
case(-2): draw_text(5,5,"This is a wonderful day. There is nothing wrong with it.") break;
case(-3): draw_set_color(make_color_rgb(red,green,blue)) 
draw_text(5,5,"Happy Birthday Infiland") break;
case(-4): draw_text(5,5,"Quite a spooky halloween.") break;
case(-5): draw_text(5,5,"Merry Christmas!") break;
case(-6): draw_text(5,5,"Hoo, Hoo, Hoo") break;
case(-7): draw_text(5,5,"Santa Claus!") break;
case(-8): draw_text(5,5,"We wish you a merry christmas...") break;
case(-9): draw_text(5,5,"...and a happy new year!") break;
case(-10): draw_text(5,5,"Reindeers with red noses!") break;
case(-11): draw_text(5,5,"It is cold...") break;
case(-12): draw_text(5,5,"Snow is falling from the sky.") break;
case(-13): draw_text(5,5,"It is snowing.") break;
case(-14): draw_text(5,5,"The Presents are under the Christmas Tree!") break;
case(-15): draw_text(5,5,"The Bells are ringing.") break;
case(-16): draw_text(5,5,"Put the star at the top of the Christmas Tree!") break;
case(-17): draw_text(5,5,"You will now have a santa hat!") break;
case(-18): draw_text(5,5,"Decorate your Christmas Tree!") break;
}
}