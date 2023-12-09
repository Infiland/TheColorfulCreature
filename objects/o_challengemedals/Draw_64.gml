draw_set_halign(fa_right)
draw_set_font(global.deathfont)
draw_set_color(c_white)
draw_set_alpha(1)
//Time
switch(challenge) {
//Tutorial
case 0: time = global.tutorialchallengetime
deaths = global.tutorialchallengedeaths break;
//Ladder
case 1: 
if global.world1 = 1 {
time = global.ladderchallengetime
deaths = global.ladderchallengedeaths
} break;
//Big Room
case 2: 
if global.world2 = 1 {
time = global.bigroomchallengetime
deaths = global.bigroomchallengedeaths
} break;
//Slippery
case 3:
if global.world2 = 1 {
time = global.slipperychallengetime
deaths = global.slipperychallengedeaths
} break;
//Blind
case 4:
if global.world3 = 1 {
time = global.blindchallengetime
deaths = global.blindchallengedeaths
} break;
//Troop
case 5:
if global.world3 = 1 {
time = global.troopchallengetime
deaths = global.troopchallengedeaths
} break;
//Speed
case 6:
if global.world3 = 1 {
time = global.speedchallengetime
deaths = global.speedchallengedeaths
} break;
//Spike
case 7:
if global.world4 = 1 {
time = global.spikechallengetime
deaths = global.spikechallengedeaths
} break;
//Kaizo
case 8:
if global.world5 = 1 {
time = global.kaizochallengetime
deaths = global.kaizochallengedeaths
} break;
//World Six
case 9:
if global.world5 = 1 {
time = global.world6challengetime
deaths = global.world6challengedeaths
} break;
//Water
case 10: 
if global.world3 = 1 {
time = global.waterchallengetime
deaths = global.waterchallengedeaths
} break;
//Water
case 11: 
if global.world3 = 1 {
time = global.movingchallengetime
deaths = global.movingchallengedeaths
} break;
//Community
case 12:
if global.world5 = 1 {
time = global.communitychallengetime
deaths = global.communitychallengedeaths
} break;
//Double Jump
case 13:
if global.world2 = 1 {
time = global.djumpchallengetime
deaths = global.djumpchallengedeaths
} break;
//Corrupted Spike
case 14:
if global.world4 = 1 {
time = global.cspikechallengetime
deaths = global.cspikechallengedeaths
} break;
//World 7
case 15:
if global.skin017 = 1 {
time = global.world7challengetime
deaths = global.world7challengedeaths
} break;
//Invisible
case 16:
if global.world1 = 1 {
time = global.invisiblechallengetime
deaths = global.invisiblechallengedeaths
} break;
//Breakable
case 17:
if global.world3 = 1 {
time = global.breakablechallengetime
deaths = global.breakablechallengedeaths
} break;

}

//Draw
if global.challengeinfo = true {
draw_set_halign(fa_left)
draw_text(x-270,y-50,BESTTIME + string(time))
if deaths != 999999 {
	draw_text(x-270,y-30,LEASTDEATHS + string(deaths))
	
if deaths > 100 { 
	draw_set_color(c_red)
	draw_text(x-270,y-10,TERRIBLE) }
if deaths >= 20 { 
if deaths < 100 { 
	draw_set_color(c_yellow)
	draw_text(x-270,y-10,MEDIOCRE) }}
if deaths >= 5 { 
if deaths < 20 { 
	draw_set_color(c_lime)
	draw_text(x-270,y-10,GOODJOB) }}
if deaths < 5 { 
if deaths != 0{ draw_set_color(c_fuchsia)
	draw_text(x-270,y-10,EPIC) }}
if deaths = 0 {
	draw_set_color(c_aqua)
	draw_text(x-270,y-10,PERFECT) }
}
}