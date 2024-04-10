var e = 1
image_alpha = 1
image_index = 0
image_speed = 1/3 * (60 / global.maxfps)
gotheredead = random_range(2.5 * (60 / global.maxfps),-2.5 * (60 / global.maxfps))
fall = random_range(-1 * (60 / global.maxfps),1 * (60 / global.maxfps))
audio_stop_sound(snd_youfellformytrap)

if room = r_leveleditor {
instance_change(o_playerdeadLE,1)
}

global.gameoverplayerX = x
global.gameoverplayerY = y

if global.endless = 1 {
if global.endlessrunmode < 3 {
if global.infinitelivessettings = 0 {
if global.deaths > global.hardmodelives - 1 {
audio_stop_all()

if global.cheats = 0 {
if global.endlessrunmode = 1 {
if global.newendlesslevelhighscore < global.endlesslevel {
global.newendlesslevelhighscore = global.endlesslevel
steam_upload_score("Endless Run", global.newendlesslevelhighscore);
e = 2
}
steam_upload_score("Seasonal Endless Run", global.endlesslevel);

}
if global.endlessrunmode = 2 {
if global.endlesslevelhighscore < global.endlesslevel {
global.endlesslevelhighscore = global.endlesslevel
steam_upload_score("Old School Endless Run", global.endlesslevelhighscore);
e = 2
steam_upload_score("Seasonal Endless Run", global.endlesslevel);
}}

if global.endlessrunmode != 3 {
if global.skin[22] = 0 {
if global.endlesslevelhighscore > 49 || global.newendlesslevelhighscore > 49 {
global.skin[22] = 1
}}}
scr_saveendless()
}

if global.endlessrunmode != 3 {
global.creditscurrency += floor((global.endlesslevel * global.creditsmultiplier)*e)
} else { global.creditscurrency += floor((global.endlesslevel / 5) * global.creditsmultiplier) }
scr_savestats()
hidehud()
rousr_dissonance_set_timestamps(undefined,undefined)

hidehud()
instance_destroy(o_levelcounter)
if room != r_hardmodedeathroom {
room_goto(r_hardmodedeathroom)
}
}} else { global.hardmodelives = "Infinite" }
}}

switch(global.skinselected) {
case(5): sprite_index = s_blockplayerdead break;
case(19): sprite_index = s_hexagonplayerdead break;
case(24): 
x += 16
y += 16
break;
case(25):
instance_create(x+16,y+16,o_explosionbomber)
break;
}