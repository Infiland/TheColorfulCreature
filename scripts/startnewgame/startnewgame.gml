function startnewgame(){
scr_loadskins()
room_goto(r_lvl1); //Change if you want to change levels.
rousr_dissonance_set_details("Story Mode - World 1")
rousr_dissonance_set_timestamps(0,undefined)
loadhud()
global.time = 0
global.hardmode = 0
global.challenges = 0
global.special = 0
global.endless = 0
global.boss1 = 0
global.boss2 = 0
global.boss3 = 0
global.boss4 = 0
global.boss5 = 0
global.world1time = 0
global.world2time = 0
global.world3time = 0
global.world4time = 0
global.world5time = 0
global.checkdeposit = false
global.hatmerchantdiscount = 1
if global.colorblindsettings = 4 {global.isgrayscale = true}

if global.skinselected = 35 {
if global.hatselected = 0 {
global.isinvisible = true
}}

if global.controlsmoveleft = 39 {
if global.controlsmoveright = 37 {
if global.controlsjump = "X" {
if global.controlsinteract = "Z" {
global.isreversed = true
}}}}

audio_stop_sound(m_mainmenu);
var directory = directory_set("/Save Files/")
if file_exists(directory + "SaveFile.sav") file_delete(directory +"SaveFile.sav")
}