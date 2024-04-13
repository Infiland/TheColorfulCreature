function scr_endlessruncheck(){
if global.endless = 1 {
if global.infinitelivessettings = 0 {
if global.deaths > global.hardmodelives - 1 {
audio_stop_all()
room_goto(r_endlessrunmenu)
hidehud()

if global.cheats = 0 {
if global.endlessrunmode = 1 {
if global.newendlesslevelhighscore < global.endlesslevel {
global.newendlesslevelhighscore = global.endlesslevel
steam_upload_score("Endless Run", global.newendlesslevelhighscore);
}}
if global.endlessrunmode = 2 {
if global.endlesslevelhighscore < global.endlesslevel {
global.endlesslevelhighscore = global.endlesslevel
steam_upload_score("Old School Endless Run", global.endlesslevelhighscore);
}}

if global.endlessrunmode != 3 {
if global.skin[22] = 0 {
if global.endlesslevelhighscore > 49 || global.newendlesslevelhighscore > 49 {
global.skin[22] = 1
}}}
scr_saveendless()
}
if global.endlessrunmode != 3 {
global.creditscurrency += floor((global.endlesslevel / 2) *  global.creditsmultiplier)
} else { global.creditscurrency += floor((global.endlesslevel / 5) *  global.creditsmultiplier) }
scr_savestats()
global.endlesslevel = 0
global.time = 0
hidehud()
}} else { global.hardmodelives = "Infinite" }
}
}