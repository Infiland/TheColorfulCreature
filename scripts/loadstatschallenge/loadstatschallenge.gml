function loadstatschallenge(){
//Time
switch(challenge) {
//Tutorial
case 0: time = global.tutorialchallengetime
deaths = global.tutorialchallengedeaths break;
medalcheck(global.tutorialchallengetime,diamondtime,deaths)
//Ladder
case 1: 
if global.world1 = 1 {
time = global.ladderchallengetime
deaths = global.ladderchallengedeaths
medalcheck(global.ladderchallengetime,46,deaths)
} break;
//Big Room
case 2: 
if global.world2 = 1 {
time = global.bigroomchallengetime
deaths = global.bigroomchallengedeaths
medalcheck(global.bigroomchallengetime,150,deaths)
} break;
//Slippery
case 3:
if global.world2 = 1 {
time = global.slipperychallengetime
deaths = global.slipperychallengedeaths
medalcheck(global.slipperychallengetime,127.2,deaths)
} break;
//Blind
case 4:
if global.world3 = 1 {
time = global.blindchallengetime
deaths = global.blindchallengedeaths
medalcheck(global.blindchallengetime,194.2,deaths)
} break;
//Troop
case 5:
if global.world3 = 1 {
time = global.troopchallengetime
deaths = global.troopchallengedeaths
medalcheck(global.troopchallengetime,55,deaths)
} break;
//Speed
case 6:
if global.world3 = 1 {
time = global.speedchallengetime
deaths = global.speedchallengedeaths
medalcheck(global.speedchallengetime,105,deaths)
} break;
//Spike
case 7:
if global.world4 = 1 {
time = global.spikechallengetime
deaths = global.spikechallengedeaths
medalcheck(global.spikechallengetime,135,deaths)
} break;
//Kaizo
case 8:
if global.world5 = 1 {
time = global.kaizochallengetime
deaths = global.kaizochallengedeaths
medalcheck(global.kaizochallengetime,444,deaths)
} break;
//World Six
case 9:
if global.world5 = 1 {
time = global.world6challengetime
deaths = global.world6challengedeaths
medalcheck(global.world6challengetime,191.6,deaths)
} break;
//Water
case 10: 
if global.world3 = 1 {
time = global.waterchallengetime
deaths = global.waterchallengedeaths
medalcheck(global.waterchallengetime,101.2,deaths)
} break;
//Water
case 11: 
if global.world3 = 1 {
time = global.movingchallengetime
deaths = global.movingchallengedeaths
medalcheck(global.movingchallengetime,94.5,deaths)
} break;
//Community
case 12:
if global.world5 = 1 {
time = global.communitychallengetime
deaths = global.communitychallengedeaths
medalcheck(global.communitychallengetime,183.2,deaths)
} break;
//Double Jump
case 13:
if global.world2 = 1 {
time = global.djumpchallengetime
deaths = global.djumpchallengedeaths
medalcheck(global.djumpchallengetime,57.1,deaths)
} break;
//Corrupted Spike
case 14:
if global.world4 = 1 {
time = global.cspikechallengetime
deaths = global.cspikechallengedeaths
medalcheck(global.cspikechallengetime,205,deaths)
} break;
//World 7
case 15:
if global.skin017 = 1 {
time = global.world7challengetime
deaths = global.world7challengedeaths
medalcheck(global.world7challengetime,2097.9,deaths)
} break;
//Invisible
case 16:
if global.world1 = 1 {
time = global.invisiblechallengetime
deaths = global.invisiblechallengedeaths
medalcheck(global.invisiblechallengetime,60,deaths)
} break;
//Breakable
case 17:
if global.world3 = 1 {
time = global.breakablechallengetime
deaths = global.breakablechallengedeaths
medalcheck(global.breakablechallengetime,65,deaths)
} break;
}
}