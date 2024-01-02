y = ystart - global.achievementsscroll
draw_set_font(global.deathfont)
if y < -128 { exit }
if y > room_height { exit }
switch(achievement) {
case(0): draw_achievement(s_levelcompleteAIcon1,global.totallevelcompleted,1,0,"Default","This is just a funny\ntest",1,0) break;
case(1): draw_achievement(s_levelcompleteAIcon1,global.totallevelcompleted,1,0,"Your Adventure Begins","Complete the 1st Level",0.8,0) break;
case(2): draw_achievement(s_levelcompleteAIcon2,global.totallevelcompleted,5,0,"Understanding The Basics","Complete 5 Levels!",0.75,0) break;
case(3): draw_achievement(s_levelcompleteAIcon3,global.totallevelcompleted,15,0,"Beginner","Complete 15 Levels!",1,0) break;
case(4): draw_achievement(s_levelcompleteAIcon4,global.totallevelcompleted,30,0,"Getting used to it!","Complete 30 Levels!",0.83,0) break;
case(5): draw_achievement(s_levelcompleteAIcon5,global.totallevelcompleted,50,0,"How much is there?","Complete 50 Levels!",0.83,0) break;
case(6): draw_achievement(s_levelcompleteAIcon6,global.totallevelcompleted,75,0,"Oh there's a lot.","Complete 75 Levels!",0.85,0) break;
case(7): draw_achievement(s_levelcompleteAIcon7,global.totallevelcompleted,100,0,"Oneeeee Hundreeeed","Complete 100 Levels!",0.8,0) break;
case(8): draw_achievement(s_levelcompleteAIcon8,global.totallevelcompleted,150,0,"Advanced Player!","Complete 150 Levels!",0.85,0) break;
case(9): draw_achievement(s_levelcompleteAIcon9,global.totallevelcompleted,250,0,"You've done a lot to get here.","Complete 250 Levels!",0.64,0) break;
case(10): draw_achievement(s_levelcompleteAIcon10,global.totallevelcompleted,750,0,"Absolute Master!","Complete 750 Levels!",0.85,0) break;
case(11): draw_achievement(s_levelcompleteAIcon11,global.totallevelcompleted,2500,0,"TCC Addict!","Complete 2500 Levels!",1,0) break;
case(12): draw_achievement(s_deathAIcon1,global.totaldeaths,1,0,"First Death!","Die for the first time!",1,0) break;
case(13): draw_achievement(s_deathAIcon2,global.totaldeaths,10,0,"Ouch...","Die 10 Times.",1,0) break;
case(14): draw_achievement(s_deathAIcon3,global.totaldeaths,25,0,"That kinda hurts.","Die 25 Times.",1,0) break;
case(15): draw_achievement(s_deathAIcon4,global.totaldeaths,50,0,"Stop it!","Die 50 Times.",1,0) break;
case(16): draw_achievement(s_deathAIcon5,global.totaldeaths,100,0,"Is my life really like this?","Die 100 Times.",0.8,0) break;
case(17): draw_achievement(s_deathAIcon6,global.totaldeaths,175,0,"Maybe I can handle this.","Die 175 Times.",0.85,0) break;
case(18): draw_achievement(s_deathAIcon7,global.totaldeaths,300,0,"I died at the last second!","Die 300 Times.",0.8,0) break;
case(19): draw_achievement(s_deathAIcon8,global.totaldeaths,500,0,"Dear Diary, Today I died.","Die 500 Times.",0.8,0) break;
case(20): draw_achievement(s_deathAIcon9,global.totaldeaths,1000,0,"Die Die Die Die!","Die 1000 Times.",1,0) break;
case(21): draw_achievement(s_deathAIcon10,global.totaldeaths,3000,0,"Just few more attempts.","Die 3000 Times.",0.8,0) break;
case(22): draw_achievement(s_deathAIcon11,global.totaldeaths,10000,0,"Death Addict","Die a lot",1,0) break;
case(23): draw_achievement(s_CoinAIcon1,global.totalcoins,1,0,"First Coin!","Collect your First Coin!",1,0) break;
case(24): draw_achievement(s_CoinAIcon2,global.totalcoins,5,0,"I got few pennies.","Collect 5 Coins.",0.8,0) break;
case(25): draw_achievement(s_CoinAIcon3,global.totalcoins,15,0,"Handful of Coins!","Collect 15 Coins.",0.8,0) break;
case(26): draw_achievement(s_CoinAIcon4,global.totalcoins,30,0,"Now I am using two hands!","Collect 30 Coins.",0.7,0) break;
case(27): draw_achievement(s_CoinAIcon5,global.totalcoins,50,0,"Piggy Bank!","Collect 50 Coins.",1,0) break;
case(28): draw_achievement(s_CoinAIcon6,global.totalcoins,75,0,"Increasing Economy!","Collect 75 Coins.",0.8,0) break;
case(29): draw_achievement(s_CoinAIcon7,global.totalcoins,100,0,"One Dollar!","Collect 100 Coins.",1,0) break;
case(30): draw_achievement(s_CoinAIcon8,global.totalcoins,150,0,"The Rich Creature.","Collect 150 Coins.",0.9,0) break;
case(31): draw_achievement(s_CoinAIcon9,global.totalcoins,250,0,"Reddie Paul!","Collect 250 Coins.",1,0) break;
case(32): draw_achievement(s_CoinAIcon10,global.totalcoins,750,0,"Super Rich!","Collect 750 Coins.",0.8,0) break;
case(33): draw_achievement(s_CoinAIcon11,global.totalcoins,2500,0,"Never Enough...","Collect 2500 Coins.",1,0) break;
case(34): draw_achievement(s_TimeAIcon1,global.totaltime,300,0,"The Time Has Come","Play for 5 Minutes.",1,0) break;
case(35): draw_achievement(s_TimeAIcon2,global.totaltime,900,0,"Explored A Little","Play for 15 Minutes.",1,0) break;
case(36): draw_achievement(s_TimeAIcon3,global.totaltime,1800,0,"Well Taught","Play for 30 Minutes.",1,0) break;
case(37): draw_achievement(s_TimeAIcon4,global.totaltime,3600,0,"Tick-Tock","Play for 1 Hour.",1,0) break;
case(38): draw_achievement(s_TimeAIcon5,global.totaltime,7200,0,"The Patience Game","Play for 2 Hours.",1,0) break;
case(39): draw_achievement(s_TimeAIcon6,global.totaltime,14400,0,"I'm gonna keep my PC on","Play for 4 Hours.",0.8,0) break;
case(40): draw_achievement(s_TimeAIcon7,global.totaltime,28800,0,"Addiction","Play for 8 Hours.",1,0) break;
case(41): draw_achievement(s_TimeAIcon8,global.totaltime,43200,0,"Just one more level...","Play for 12 Hours.",0.85,0) break;
case(42): draw_achievement(s_TimeAIcon9,global.totaltime,86400,0,"One-Day Playtime","Play for 24 Hours.",1,0) break;
case(43): draw_achievement(s_TimeAIcon10,global.totaltime,115200,0,"Feels Unexplored","Play for 32 Hours.",1,0) break;
case(44): draw_achievement(s_TimeAIcon11,global.totaltime,230400,0,"Am I aging from this?","Play for 64 Hours.",0.9,0) break;
case(45): draw_achievement(s_JumpAIcon1,global.totaljumps,1,0,"First Jump!","Jump for the first time!",1,0) break;
case(46): draw_achievement(s_JumpAIcon2,global.totaljumps,20,0,"The Jumpventure Begins!","Jump 20 Times.",0.9,0) break;
case(47): draw_achievement(s_JumpAIcon3,global.totaljumps,100,0,"Jumper!","Jump 100 Times.",1,0) break;
case(48): draw_achievement(s_JumpAIcon4,global.totaljumps,250,0,"Decent Jumper!","Jump 250 Times.",1,0) break;
case(49): draw_achievement(s_JumpAIcon5,global.totaljumps,1000,0,"Jumpster!","Jump 1000 Times.",1,0) break;
case(50): draw_achievement(s_JumpAIcon6,global.totaljumps,2000,0,"Jump Lover","Jump 2000 Times.",1,0) break;
case(51): draw_achievement(s_JumpAIcon7,global.totaljumps,5000,0,"Jump Veteran","Jump 5000 Times.",1,0) break;
case(52): draw_achievement(s_JumpAIcon8,global.totaljumps,1500,0,"Jump Master","Jump 15000 Times.",1,0) break;
case(53): draw_achievement(s_JumpAIcon9,global.totaljumps,60000,0,"Jumping Legend","Jump 60000 Times.",1,0) break;
case(54): draw_achievement(s_JumpAIcon10,global.totaljumps,200000,0,"God at Jumping","Jump 200000 Times.",1,0) break;
case(55): draw_achievement(s_JumpAIcon11,global.totaljumps,500000,0,"The Plumber","Jump a lot",1,0) break;

//STEAM
case(56): draw_achievement(s_ithappenedAIcon,"IT_HAPPENED",1,1,"It Happened","It Happened",1,1) break;
case(57): draw_achievement(s_eastereggAIcon1,"EASTEREGG_1",1,1,"An... egg?","Find a secret path in W2-L3",1,1) break;
case(58): draw_achievement(s_invisibleAIcon,"INVISIBLE_SKIN",1,0,"The Unseen","Beat the game while the player is fully invisible!",1,1) break;
case(59): draw_achievement(s_grayscaleAIcon,"GRAYSCALE",1,0,"Achromatic Quest","Beat the game while grayscale is enabled!",0.85,1) break;
case(60): draw_achievement(s_bossAIcon1,"BOSS_KILL_1",1,0,"Ketchupt!","Beat the Hotdog Boss!",1,1) break;
case(61): draw_achievement(s_bossAIcon2,"BOSS_KILL_2",1,0,"Hammered!","Beat the Hammer Boss!",1,1) break;
case(62): draw_achievement(s_bossAIcon3,"BOSS_KILL_3",1,0,"Outplayed!","Beat the Piano Boss!",1,1) break;
case(63): draw_achievement(s_bossAIcon4,"BOSS_KILL_4",1,0,"Drained!","Beat the Lava Boss!",1,1) break;
case(64): draw_achievement(s_goldenspikeAIcon,"GOLDEN_SPIKE_DEATH",1,1,"Golden Spike Death","Touch the Golden Spike!",0.83,1) break;
case(65): draw_achievement(s_weirdspikeAIcon,"WEIRD_SPIKE_DEATH",1,1,"Weird Spike Death","Touch the Weird Spike!",0.85,1) break;
case(66): draw_achievement(s_hatAIcon,"FIRST_HAT",1,0,"First Hat!","Buy your very first hat!",1,1) break;
case(67): draw_achievement(s_challengeAIcon,"FIRST_CHALLENGE",1,0,"First Challenge!","Beat your first challenge!",1,1) break;
case(68): draw_achievement(s_PchallengeAIcon,"PERFECT_CHALLENGE",1,0,"Perfect!","Beat any challenge without dying!",1,1) break;
case(69): draw_achievement(s_bronzeAIcon,"BRONZE_MEDAL",1,0,"Bronze Medal!","Earn a bronze medal from a challenge!",1,1) break;
case(70): draw_achievement(s_silverAIcon,"SILVER_MEDAL",1,0,"Silver Medal!","Earn a silver medal from a challenge!",1,1) break;
case(71): draw_achievement(s_goldAIcon,"GOLD_MEDAL",1,0,"Gold Medal!","Earn a gold medal from a challenge!",1,1) break;
case(72): draw_achievement(s_diamondAIcon,"DIAMOND_MEDAL",1,0,"Diamond Medal!","Earn a diamond medal from a challenge!",1,1) break;
case(73): draw_achievement(s_diamond5AIcon,"DIAMOND_LOVER",1,0,"Diamond Lover!","Have 5 challenges that have a diamond medal.",1,1) break;
case(74): draw_achievement(s_antideathAIcon,"THE_ANTI_DEATH",1,0,"The Anti Death","Have 5 challenges that have a 'Perfect' rating.",1,1) break;
case(75): draw_achievement(s_makeLAIcon,"MAKE_LEVEL",1,0,"Make a level!","Make your first level and then save it!",1,1) break;
case(76): draw_achievement(s_C1AIcon,"A_SMALL_LOAN",1,0,"A Small Loan!","Have 100 credits in your current balance!",1,1) break; //REMOVED
case(77): draw_achievement(s_C2AIcon,"MONEY_SAVER",1,0,"Money Saver!","Have 1,000 credits in your current balance!",1,1) break;
case(78): draw_achievement(s_C3AIcon,"THE_GLITTERING_RICH",1,0,"The Glittering Rich","Have 10,000 credits in your current balance!",0.92,1) break; //REMOVED
case(79): draw_achievement(s_reverseAIcon,"THE_REVERSE_PROBLEM",1,0,"The Reverse Problem","Beat the game with reversed controls! (Reversed Left/Right and Jump/Interact)",0.92,1) break;
case(80): draw_achievement(s_byebyeAIcon,"BYE_BYE_LEVEL",1,0,"Bye Bye Level!","Skip a level using coins!",1,1) break;
case(81): draw_achievement(s_byebye2AIcon,"UH_OH",1,1,"Uh Oh...","Realise that you can't skip a level and that you basically ran out of coins to spend.",1,1) break;
case(82): draw_achievement(s_endlessAIcon1,"ENDLESS_BEGINNER",1,0,"Endless Beginner","Beat 5 Levels in Endless Run",1,1) break;
case(83): draw_achievement(s_endlessAIcon2,"ENDLESS_RUNNER",1,0,"Endless Runner","Beat 20 Levels in Endless Run",1,1) break;
case(84): draw_achievement(s_endlessAIcon3,"ENDLESS_EXPERT",1,0,"Endless Expert","Beat 50 Levels in Endless Run",1,1) break;
case(85): draw_achievement(s_endlessAIcon4,"ENDLESS_MASTER",1,0,"Endless Master","Beat 100 Levels in Endless Run",1,1) break;
case(86): draw_achievement(s_CERAIcon,"YOUR_OWN_ENDLESS_RUN",1,0,"Your Own Endless Run","Play your own Custom Endless Run!",0.9,1) break;
case(87): draw_achievement(s_poorAIcon,"POTATO_SETTINGS",1,0,"Potato Settings","Why is this an achievementnjssjsjswiwo",1,1) break;
case(88): draw_achievement(s_highAIcon,"BENCHMARK",1,0,"Benchmark","UserBenchmarks is useless! Run MAX settings!",1,1) break;
case(89): draw_achievement(s_trollAIcon,"TROLOLOLOL",1,1,"Trololololol","Press 'ALT-F4'",1,1) break; //REMOVED
case(90): draw_achievement(s_hatmerchantAIcon,"HAT_MERCHANT",1,0,"Hat Merchant","Find and talk to the Hat Merchant",1,1) break;
case(91): draw_achievement(s_youwinAIcon,"YOU_WIN",1,0,"You win!","Beat the main game! But, is it really over yet?",1,1) break;
case(92): draw_achievement(s_ohnotheresmoreAIcon,"OH_NO_THERES_MORE",1,1,"Oh no, there's more!","Discover the Hardmode section of the game.",0.9,1) break;
case(93): draw_achievement(s_clickhotdogAIcon,"CLICK_THE_HOTDOG",1,1,"Click the Hotdog!","You clicked the hotdog! Are you proud of yourself?",1,1) break;
case(94): draw_achievement(s_HMAIcon1,"HM_MEDIUM",1,0,"First Hardmode Win!","Beat the Hardmode for the first time!",0.95,1) break;
case(95): draw_achievement(s_HMAIcon2,"HM_DIFFICULT",1,0,"Difficult Stuff Man!","Beat Hardmode on the Difficult Difficulty",1,1) break;
case(96): draw_achievement(s_HMAIcon3,"HM_INSANE",1,0,"INSANITY!","Beat Hardmode on the Insane Difficulty",1,1) break;
case(97): draw_achievement(s_HMAIcon4,"HM_RIDICULOUS",1,0,"Absurd Difficulty!","Beat Hardmode on the Ridiculous Difficulty",1,1) break;
case(98): draw_achievement(s_HMAIcon5,"HM_IMPOSSIBLE",1,0,"Everything's Possible!","What could possibly go wrong now?",0.9,1) break;
case(99): draw_achievement(s_HMAIcon6,"HM_YEAHGL",1,0,"Luck was given!","But now the suffering begins...",1,1) break; //REMOVED
case(100): draw_achievement(s_HMAIcon7,"HM_ETERNALSUFFERING",1,0,"The Suffering is OVER!","Beat all hardmode difficulties!",0.9,1) break; //REMOVED
case(101): draw_achievement(s_makeLAIcon2,"SUPER_DETAILED_LEVEL",1,0,"Super Detailed Level!","Make and save a level that has 500 or more objects.",0.9,1) break;
case(102): draw_achievement(s_eastereggAIcon2,"EASTEREGG_2",1,1,"Space Shooter Ultimate!","Wait, a SSU reference?!!",0.8,1) break;
case(103): draw_achievement(s_cookieAIcon,"COOKIE_CLICKER",1,1,"Cookie Clicker!","Bake 1 Cookie!",1,1) break;
case(104): draw_achievement(s_lowonCAIcon,"LOW_ON_CREDITS",1,1,"Low on Credits?","Need more? Then give us your house!",1,1) break; //REMOVED
case(105): draw_achievement(s_lowonCAIcon2,"TOO_MUCH_CREDITS",1,1,"Too much credits!","Reach 1T Credits by giving your $ to Infiland Arts",1,1) break; //REMOVED
case(106): draw_achievement(s_kaizoAIcon,"KAIZO_CHALLENGE",1,0,"KAAAAZOOOOO!","Beat the Kaizo Challenge!",1,1) break;
case(107): draw_achievement(s_world1quickAIcon,"WORLD_1_QUICK",1,0,"Quick Hotdog Execution","Beat World 1 under 2 minutes.",0.8,1) break;
case(108): draw_achievement(s_world2quickAIcon,"WORLD_2_QUICK",1,0,"Spikes Don't Run as Fast!","Beat World 2 under 3 minutes.",0.8,1) break;
case(109): draw_achievement(s_world3quickAIcon,"WORLD_3_QUICK",1,0,"Platforms are Slow!","Beat World 3 under 4 minutes.",0.9,1) break;
case(110): draw_achievement(s_world4quickAIcon,"WORLD_4_QUICK",1,0,"Maybe the Time is Corrupted!","Beat World 4 under 5 minutes.",0.7,1) break;
case(111): draw_achievement(s_world5quickAIcon,"WORLD_5_QUICK",1,0,"VROOOOOM","Beat World 5 under 6 minutes.",1,1) break;
case(112): draw_achievement(s_jebaitedAIcon,"JEBAITED",1,1,"Jebaited!","Gotcha :)",1,1) break;
case(113): draw_achievement(s_checkpointAIcon,"CHECKPOINT",1,0,"Checkpoint!","Reach your first checkpoint!",1,1) break;
case(114): draw_achievement(s_hat2AIcon,"A_FAN_OF_HATS",1,0,"A Fan of Hats!","Buy 10 Hats!",1,1) break;
case(115): draw_achievement(s_skinallAIcon,"SKIN_COMPLETIONIST",1,0,"Skin Completionist!","Gather every skin in the game!",0.8,1) break;
case(116): draw_achievement(s_hatallAIcon,"HAT_COMPLETIONIST",1,0,"Hat Completionist!","Gather every hat in the game!",0.82,1) break;
case(117): draw_achievement(s_world6AIcon,"WORLD_6",1,1,"Wait, World 1 Again?","Beat World 6!",0.8,1) break;
case(118): draw_achievement(s_world7AIcon,"WORLD_7",1,1,"Buffed Spikes!","Beat World 7!",1,1) break; //REMOVED
case(119): draw_achievement(s_oopsAIcon,"OOPS",1,0,"Oops...","Infiland Moment :3",1,1) break;

default: instance_destroy() break;
}