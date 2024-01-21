draw_set_font(global.cool2font)
draw_text_ext(740,440,"Scroll to look through stats",20,400)
draw_set_font(global.deathfont)
draw_set_color(c_white)
everything = (global.totaldeaths / 4) + (global.endlesslevelhighscore * 100) + global.totalcoins + global.total1ups + (global.totaljumps / 5) + (global.totalskips * 5) + global.totalpickups + global.totalportal + (global.totaltime / 10) + (global.totallevelcompleted * 3) + (global.totalgunshots / 8) + global.totaldestroyedboxes + global.totalenemykills + (global.totalrocketkills / 2) + (global.totalgoldspikedeaths * 100) + (global.totalweirdspikedeaths * 1000) + global.totalblockdeaths
global.totalpickups = global.totalcoins + global.totalnormalpickups + global.totalgravitypickups + global.totalspeedpickups + global.totalusepickups + global.totalkeypickups + global.totaltorchpickups + global.totalammopickups + global.totalgunpickups + global.total1ups + global.totaloxygenpickups + global.totaldjumppickups

draw_text_color(30,110 - yscroll,MAINSTATS,c_yellow,c_orange,c_yellow,c_orange,1)
draw_text(30,130 - yscroll,COINSCOLLECTED + string(global.totalcoins))
draw_text(30,150 - yscroll,JUMPS + string(global.totaljumps))
if global.totaltime > 3600 {
draw_text(30,170 - yscroll,PLAYTIME + string(global.totaltime / 3600) + "h")
} else { draw_text(30,170 - yscroll,PLAYTIME + string(global.totaltime / 60) + "m") }
draw_text(30,190 - yscroll,SKIPPEDLEVELS + string(global.totalskips))
draw_text(30,210 - yscroll,TOTALPICKUPS + string(global.totalpickups))
draw_text(30,230 - yscroll,NORMALPICKUPS + string(global.totalnormalpickups))
draw_text(30,250 - yscroll,GRAVITYPICKUPS + string(global.totalgravitypickups))
draw_text(30,270 - yscroll,ACCELERATIONPICKUPS + string(global.totalspeedpickups))
draw_text(30,290 - yscroll,SPIRALPICKUPS + string(global.totalusepickups))
draw_text(30,310 - yscroll,KEYPICKUPS + string(global.totalkeypickups))
draw_text(30,330 - yscroll,PORTALSENTERED + string(global.totalportal))
draw_text(30,350 - yscroll,TORCHPICKUPS + string(global.totaltorchpickups))
draw_text(30,370 - yscroll,LEVELSCOMPLETED + string(global.totallevelcompleted))
draw_text(30,390 - yscroll,CUSTOMLEVELSCOMPLETED + string(global.customlevelcompleted))

draw_text(30,410 - yscroll,ENDLESSRUNHIGHSCORE + string(global.newendlesslevelhighscore))
draw_text(30,430 - yscroll,OSENDLESSRUNHIGHSCORE + string(global.endlesslevelhighscore))
draw_text(30,450 - yscroll,GUNSHOTS + string(global.totalgunshots))
draw_text(30,470 - yscroll,GUNPICKUPS + string(global.totalgunpickups))
draw_text(30,490 - yscroll,AMMOPICKUPS + string(global.totalammopickups))
draw_text(30,510 - yscroll,DESTROYEDBOXES + string(global.totaldestroyedboxes))
draw_text(30,530 - yscroll,ENEMYKILLS + string(global.totalenemykills))
draw_text(30,550 - yscroll,ONEUPSCOLLECTED + string(global.total1ups))
draw_text(30,570 - yscroll,ROCKETSDESTROYED + string(global.totalrocketkills))
draw_text(30,590 - yscroll,OXYGENPICKUPS + string(global.totaloxygenpickups))
draw_text(30,610 - yscroll,DOUBLEJUMPPICKUPS + string(global.totaldjumppickups))
draw_text(30,630 - yscroll,BLOCKSBROKEN + string(global.totalblockdeaths))

draw_text_color(30,670 - yscroll,DEATHS,c_yellow,c_orange,c_yellow,c_orange,1)
draw_text(30,690 - yscroll,TOTALDEATHS + string(global.totaldeaths))
draw_text(30,710 - yscroll,BLOCKDEATHS + string(global.totalblockdeaths))
draw_text(30,730 - yscroll,RESTARTDEATHS + string(global.totalrestartdeaths))
draw_text(30,750 - yscroll,SPIKEDEATHS + string(global.totalspikedeaths))
draw_text(30,770 - yscroll,INVSPIKEDEATHS + string(global.totalinvisiblespikedeaths))
draw_text(30,790 - yscroll,VMOVINGSPIKEDEATHS + string(global.totalverticalspikedeaths))
draw_text(30,810 - yscroll,HMOVINGSPIKEDEATHS + string(global.totalhorizontalspikedeaths))
draw_text(30,830 - yscroll,GOLDENSPIKEDEATHS + string(global.totalgoldspikedeaths))
draw_text(30,850 - yscroll,WEIRDSPIKEDEATHS + string(global.totalweirdspikedeaths))
draw_text(30,870 - yscroll,VOIDDEATHS + string(global.totalvoiddeaths))
draw_text(30,890 - yscroll,SETONFIRE + string(global.totalfiredeaths))
draw_text(30,910 - yscroll,LAVADEATHS + string(global.totallavadeaths))
draw_text(30,930 - yscroll,BULLETDEATHS + string(global.totalbulletdeaths))
draw_text(30,950 - yscroll,ROCKETDEATHS + string(global.totalrocketdeaths))
draw_text(30,970 - yscroll,TROOPDEATHS + string(global.totaltroopdeaths))
draw_text(30,990 - yscroll,DROWNED + string(global.totalwaterdeaths))

draw_text_color(30,1030 - yscroll,AVERAGES,c_yellow,c_orange,c_yellow,c_orange,1)
draw_text(30,1050 - yscroll,AVERAGEDEATHSPERLEVEL + string(global.totaldeaths / global.totallevelcompleted))
draw_text(30,1070 - yscroll,AVERAGETIMEPERLEVEL + string((global.totaltime / 60) / global.totallevelcompleted) + "m")	

draw_text_color(30,1110 - yscroll,PROGRESSION,c_yellow,c_orange,c_yellow,c_orange,1)
draw_text(30,1130 - yscroll,NORMALSKINSUNLOCKED + string(normalskins) + "/" + string(reqnormalskins) + " (" + string(normalskinspercentage) + "%)")
draw_text(30,1150 - yscroll,LEGENDARYSKINSUNLOCKED + string(legskins) + "/" + string(reqlegskins) + " (" + string(legskinspercentage) + "%)")
draw_text(30,1170 - yscroll,HATSACQUIRED + string(allhats) + "/" + string(reqallhats) + " (" + string(hatspercentage) + "%)")
draw_text(30,1190 - yscroll,ITEMSACQUIRED + string(allitems) + "/" + string(reqallitems) + " (" + string(itemspercentage) + "%)")
if global.hardmodeunlock != 0 {
draw_text(30,1210 - yscroll,HARDMODEDIFFICULTIESBEATEN + string(HMprogress) + "/" + string(reqHM) + " (" + string(HMpercentage) + "%)")
} else { draw_text(30,1210 - yscroll,HARDMODEDIFFICULTIESBEATEN + " 0/7") }
draw_text(30,1230 - yscroll,CHALLENGESBEATEN + string(Cprogress) + "/" + string(reqchallenge) + " (" + string(challengepercentage) + "%)")
draw_text(30,1250 - yscroll,PERFECTCHALLENGESBEATEN + string(perfectchallenge) + "/" + string(reqperfectchallenge) + " (" + string(perfectchallengepercentage) + "%)")
draw_text(30,1270 - yscroll,WORLDSCOMPLETED + string(Wprogress) + "/" + string(reqW) + " (" + string(Wpercentage) + "%)")
draw_text(30,1290 - yscroll,TOTALACHIEVEMENTS + string(allach) + "/" + string(reqach) + " (" + string(achpercentage) + "%)")

draw_text_color(30,1330 - yscroll,FULLGAMECOMPLETION + string(gameprogress) + "%",c_yellow,c_orange,c_yellow,c_orange,1)

draw_rectangle_color(0,670,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_rectangle_color(0,80,room_width,-10,c_black,c_black,c_black,c_black,false)
xp = lerp(xp,everything,0.1)
if xp < 250 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/2,1,0,make_color_rgb(red,green,blue),1)
}
if xp > 250 {
if xp < 1000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/8,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 1000 {
if xp < 2000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/16,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 2000 {
if xp < 5000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/40,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 5000 {
if xp < 25000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/200,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 25000 {
if xp < 69420 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/555.36,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 69420 {
if xp < 150000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/1200,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 150000 {
if xp < 500000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/4000,1,0,make_color_rgb(red,green,blue),1)	
}}
if xp > 500000 {
draw_sprite_ext(s_xpbar,0,30,730,(xp)/16000,1,0,make_color_rgb(red,green,blue),1)	
}

draw_text(30,680,"EXP: " + string_format(xp,0,0))

if everything > 2500000 { rank = 27} //You win, you can stop now
if everything < 2500000 { rank = 26} //God Gamer++
if everything < 1500000 { rank = 25} //God Gamer+
if everything < 1000000 { rank = 24} //God Gamer
if everything < 750000 { rank = 23} //Color Master++
if everything < 550000 { rank = 22} //Color Master+
if everything < 400000 { rank = 21} //Color Master
if everything < 300000 { rank = 20} //Super Veteran++
if everything < 225000 { rank = 19} //Super Veteran+
if everything < 170000 { rank = 18} //Super Veteran
if everything < 125000 { rank = 17} //Veteran++
if everything < 95000 { rank = 16} //Veteran+
if everything < 70000 { rank = 15} //Veteran
if everything < 50000 { rank = 14} //Professional++
if everything < 35000 { rank = 13} //Professional+
if everything < 27500 { rank = 12} //Professional
if everything < 20000 { rank = 11} //Experienced++
if everything < 15000 { rank = 10} //Experienced+
if everything < 11500 { rank = 9} //Experienced
if everything < 9000 { rank = 8} //Novice++
if everything < 6000 { rank = 7} //Novice+
if everything < 4000 { rank = 6} //Novice
if everything < 2500 { rank = 5} //Amateur++
if everything < 1400 { rank = 4} //Amateur+
if everything < 700 { rank = 3} //Amateur
if everything < 400 { rank = 2} //Newbie++
if everything < 200 { rank = 1} //Newbie+
if everything < 100 { rank = 0} //Newbie

switch(rank) {
case(0): draw_text(30,700,string(RANKL) + NEWBIE) break;
case(1): draw_text(30,700,string(RANKL) + NEWBIEP) break;
case(2): draw_text(30,700,string(RANKL) + NEWBIEPP) break;
case(3): draw_text(30,700,string(RANKL) + AMATEUR) break;
case(4): draw_text(30,700,string(RANKL) + AMATEURP) break;
case(5): draw_text(30,700,string(RANKL) + AMATEURPP) break;
case(6): draw_text(30,700,string(RANKL) + NOVICE) break;
case(7): draw_text(30,700,string(RANKL) + NOVICEP) break;
case(8): draw_text(30,700,string(RANKL) + NOVICEPP) break;
case(9): draw_text(30,700,string(RANKL) + EXPERIENCED) break;
case(10): draw_text(30,700,string(RANKL) + EXPERIENCEDP) break;
case(11): draw_text(30,700,string(RANKL) + EXPERIENCEDPP) break;
case(12): draw_text(30,700,string(RANKL) + PROFESSIONAL) break;
case(13): draw_text(30,700,string(RANKL) + PROFESSIONALP) break;
case(14): draw_text(30,700,string(RANKL) + PROFESSIONALPP) break;
case(15): draw_text(30,700,string(RANKL) + VETERAN) break;
case(16): draw_text(30,700,string(RANKL) + VETERANP) break;
case(17): draw_text(30,700,string(RANKL) + VETERANPP) break;
case(18): draw_text(30,700,string(RANKL) + SUPERVETERAN) break;
case(19): draw_text(30,700,string(RANKL) + SUPERVETERANP) break;
case(20): draw_text(30,700,string(RANKL) + SUPERVETERANPP) break;
case(21): draw_text(30,700,string(RANKL) + COLORMASTER) break;
case(22): draw_text(30,700,string(RANKL) + COLORMASTERP) break;
case(23): draw_text(30,700,string(RANKL) + COLORMASTERPP) break;
case(24): draw_text(30,700,string(RANKL) + GODGAMER) break;
case(25): draw_text(30,700,string(RANKL) + GODGAMERP) break;
case(26): draw_text(30,700,string(RANKL) + GODGAMERPP) break;
default: draw_text(30,700,string(RANKL) + "Reddie") break;
}