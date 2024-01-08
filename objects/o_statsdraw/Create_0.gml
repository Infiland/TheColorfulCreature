dragy = 0

rank = 0
xp = 0
color = c_red

yscroll = 0
yscrollreal = 0
//Special Rainbow colors!
red = 255
green = 255
blue = 255
if rank = 2 {
red = 255
green = 0
blue = 255	
}
change = 0
color = make_color_rgb(red,green,blue)


//Hats bugfix
scr_savehats()
hatbugfix = 0
if global.hat001 = -1 {hatbugfix += 1}
if global.hat003 = -1 {hatbugfix += 1}
if global.hat008 = -1 {hatbugfix += 1}
if global.hat009 = -1 {hatbugfix += 1}
if global.hat010 = -1 {hatbugfix += 1}
if global.hat035 = -1 {hatbugfix += 1}

//Skins
normalskins = global.skin001+global.skin002+global.skin003+global.skin004+global.skin005+global.skin006+global.skin007+global.skin008+global.skin009+global.skin010+global.skin012+global.skin014+global.skin015+global.skin016+global.skin017+global.skin019+global.skin020+global.skin021+global.skin023+global.skin024+global.skin026+global.skin027+global.skin028+global.skin029+global.skin030+global.skin031+global.skin032+global.skin033+global.skin034+global.skin036+global.skin037+global.skin038+global.skin039+global.skin040+global.skin042+global.skin043+global.skin044+global.skin045+global.skin046+global.skin047+global.skin048
reqnormalskins = 41
normalskinspercentage = (normalskins / reqnormalskins) * 100

if normalskinspercentage = 100 {
if !steam_get_achievement("SKIN_COMPLETIONIST") {
steam_set_achievement("SKIN_COMPLETIONIST")
}}

legskins = global.skin011+global.skin013+global.skin018+global.skin022+global.skin025+global.skin035+global.skin041
reqlegskins = 7
legskinspercentage = (legskins / reqlegskins) * 100

allskins = normalskins + legskins

//Hats
allhats = global.hat001+global.hat002+global.hat003+global.hat004+global.hat005+global.hat006+global.hat007+global.hat008+global.hat009+global.hat010+global.hat011+global.hat012+global.hat013+global.hat014+global.hat015+global.hat016+global.hat017+global.hat018+global.hat019+global.hat020+global.hat021+global.hat022+global.hat023+global.hat024+global.hat025+global.hat026+global.hat027+global.hat028+global.hat029+global.hat030+global.hat031+global.hat032+global.hat033+global.hat034+global.hat035+global.hat036+global.hat037+global.hat038+global.hat039+global.hat040+global.hat041+global.hat042+global.hat043+global.hat044+global.hat045+global.hat046+global.hat047+global.hat048+global.hat049+global.hat050+global.hat051+global.hat052+global.hat053+global.hat054+global.hat055+global.hat056+global.hat057+global.hat058+global.hat059+global.hat060+global.hat061+global.hat062+hatbugfix
reqallhats = 62
hatspercentage = (allhats / reqallhats) * 100

//Items
allitems = global.item001+global.item002+global.item003
reqallitems = 3
itemspercentage = (allitems / reqallitems) * 100

if hatspercentage = 100 {
if !steam_get_achievement("HAT_COMPLETIONIST") {
steam_set_achievement("HAT_COMPLETIONIST")
}}

if allhats > 9 {
if !steam_get_achievement("A_FAN_OF_HATS") {
steam_set_achievement("A_FAN_OF_HATS")
}}


//Challenges Bugfix
challengebugfix = 0
if global.hat001 != -1 {challengebugfix = 1}
Cprogress = challengebugfix+global.skin002+global.skin004+global.skin010+global.skin011+global.skin014+global.skin016+global.skin017+global.skin019+global.skin021+global.skin023+global.skin028+global.skin031+global.skin040+global.skin037+global.skin041+global.skin043+global.skin045
reqchallenge = 18

challengepercenntage = (Cprogress / reqchallenge) * 100


//PERFECT CHALLENGES
perfectchallenge = 0
if global.kaizochallengedeaths = 0 { perfectchallenge += 1 }
if global.blindchallengedeaths = 0 { perfectchallenge += 1 }
if global.bigroomchallengedeaths = 0 { perfectchallenge += 1 }
if global.troopchallengedeaths = 0 { perfectchallenge += 1 }
if global.slipperychallengedeaths = 0 { perfectchallenge += 1 }
if global.world6challengedeaths = 0 { perfectchallenge += 1 }
if global.ladderchallengedeaths = 0 { perfectchallenge += 1 }
if global.tutorialchallengedeaths = 0 { perfectchallenge += 1 }
if global.spikechallengedeaths = 0 { perfectchallenge += 1 }
if global.waterchallengedeaths = 0 { perfectchallenge += 1 }
if global.movingchallengedeaths = 0 { perfectchallenge += 1 }
if global.communitychallengedeaths = 0 { perfectchallenge += 1 }
if global.djumpchallengedeaths = 0 { perfectchallenge += 1 }
if global.cspikechallengedeaths = 0 { perfectchallenge += 1 }
if global.world7challengedeaths = 0 { perfectchallenge += 1 }
if global.speedchallengedeaths = 0 { perfectchallenge += 1 }
if global.invisiblechallengedeaths = 0 { perfectchallenge += 1 }
if global.breakablechallengedeaths = 0 { perfectchallenge += 1 }

reqperfectchallenge = 18
perfectchallengepercentage = (perfectchallenge / reqperfectchallenge) * 100

//Hardmode
HMprogress = global.hardmodeunlock - 1
reqHM = 7
HMpercentage = (HMprogress / reqHM) * 100

//Worlds
Wprogress = global.world1 + global.world2 + global.world3 + global.world4 + global.world5 + global.skin017 + global.skin041
reqW = 7
Wpercentage = (Wprogress / reqW) * 100

//Achievements
allach = 0
scr_achievementstats()
reqach = 148
achpercentage = (allach / reqach) * 100

//Game progress
gameprogress = (Wpercentage + HMpercentage + achpercentage + legskinspercentage + challengepercenntage + perfectchallengepercentage + hatspercentage + normalskinspercentage + itemspercentage) / 9

//Languages
MAINSTATS = loc(72)
COINSCOLLECTED = loc(73) + ": "
JUMPS = loc(74)+": "
PLAYTIME = loc(75)+": "
SKIPPEDLEVELS = loc(76)+": "
TOTALPICKUPS = loc(77)+": "
NORMALPICKUPS = loc(78)+": "
GRAVITYPICKUPS = loc(79)+": "
ACCELERATIONPICKUPS = loc(80)+": "
SPIRALPICKUPS = loc(81)+": "
KEYPICKUPS = loc(82)+": "
PORTALSENTERED = loc(83)+": "
TORCHPICKUPS = loc(84)+": "
LEVELSCOMPLETED = loc(85)+": "
CUSTOMLEVELSCOMPLETED = loc(86)+": "
ENDLESSRUNHIGHSCORE = loc(87)+": "
OSENDLESSRUNHIGHSCORE = loc(88)+": "
GUNSHOTS = loc(89)+": "
GUNPICKUPS = loc(90)+": "
AMMOPICKUPS = loc(91)+": "
DESTROYEDBOXES = loc(92)+": "
ENEMYKILLS = loc(93)+": "
ONEUPSCOLLECTED = loc(94)+": "
ROCKETSDESTROYED = loc(95)+": "
OXYGENPICKUPS = loc(96)+": "
DOUBLEJUMPPICKUPS = loc(97)+": "
BLOCKSBROKEN = loc(617)+": "

DEATHS = loc(98)+":"
TOTALDEATHS = loc(99)+": "
BLOCKDEATHS = loc(100)+": "
RESTARTDEATHS = loc(101)+": "
SPIKEDEATHS = loc(102)+": "
INVSPIKEDEATHS = loc(103)+": "
VMOVINGSPIKEDEATHS = loc(104)+": "
HMOVINGSPIKEDEATHS = loc(105)+": "
GOLDENSPIKEDEATHS = loc(106)+": "
WEIRDSPIKEDEATHS = loc(107)+": "
VOIDDEATHS = loc(108)+": "
SETONFIRE = loc(109)+": "
LAVADEATHS = loc(110)+": "
BULLETDEATHS = loc(111)+": "
ROCKETDEATHS = loc(112)+": "
TROOPDEATHS = loc(113)+": "
DROWNED = loc(114)+": "

AVERAGES = loc(115)+":"
AVERAGEDEATHSPERLEVEL = loc(116)+": "
AVERAGETIMEPERLEVEL = loc(117)+": "

PROGRESSION = loc(118)+":"
NORMALSKINSUNLOCKED = loc(119)+": "
LEGENDARYSKINSUNLOCKED = loc(120)+": "
HATSACQUIRED = loc(121)+": "
ITEMSACQUIRED = loc(122)+": "
HARDMODEDIFFICULTIESBEATEN = loc(123)+": "
CHALLENGESBEATEN = loc(124)+": "
PERFECTCHALLENGESBEATEN = loc(125)+": "
WORLDSCOMPLETED = loc(126)+": "
TOTALACHIEVEMENTS = loc(127)+": "

FULLGAMECOMPLETION = loc(128)+": "

RANKL = loc(59) + ": "
NEWBIE = loc(301)
AMATEUR = loc(302)
NOVICE = loc(303)
EXPERIENCED = loc(304)
PROFESSIONAL = loc(305)
VETERAN = loc(306)
SUPERVETERAN = loc(307)
COLORMASTER = loc(308)
GODGAMER = loc(309)

NEWBIEP = NEWBIE + " +"
NEWBIEPP = NEWBIE + " ++"
AMATEURP = AMATEUR + " +"
AMATEURPP = AMATEUR + " ++"
NOVICEP = NOVICE + " +"
NOVICEPP = NOVICE + " ++"
EXPERIENCEDP = EXPERIENCED + " +"
EXPERIENCEDPP = EXPERIENCED + " ++"
PROFESSIONALP = PROFESSIONAL + " +"
PROFESSIONALPP = PROFESSIONAL + " ++"
VETERANP = VETERAN + " +"
VETERANPP = VETERAN + " ++"
SUPERVETERANP = SUPERVETERAN + " +"
SUPERVETERANPP = SUPERVETERAN + " ++"
COLORMASTERP = COLORMASTER + " +"
COLORMASTERPP = COLORMASTER + " ++"
GODGAMERP = GODGAMER + " +"
GODGAMERPP = GODGAMER + " ++"