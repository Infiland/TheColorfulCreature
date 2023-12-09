if locked = 1 { exit }

if !instance_exists(o_progressask) {
window_set_cursor(cr_default)
audio_play_sound(m_leveleditor,0,1)
global.LEBuild = 1
global.levelname = ""
global.previoustext = ""
global.leveleditorstring = ""
global.naminglevel = false
global.LEVerified = 0
global.defaultcolorLE = 0
global.LEMode = 1
global.color = 0
global.leveleditormusic = 0
global.LEBackground = 0
global.LEStarRotation = 0
global.LEbuttonpage = 1
global.LEDiamondMedalTime = 100
global.leveleditorversion = 1
global.Publish_ID = 0
global.workshoplevelversion = 0
global.LEStarStyle = 0
global.LEBlockStyle = 0
sprite_set_offset(s_cannotplace,0,0)
audio_stop_sound(m_mainmenu);
/*room_set_width(r_leveleditor,3200)
room_set_height(r_leveleditor,3200)*/

room_goto(r_leveleditor);
instance_create(x,y,o_leveleditormenusetup)
rousr_dissonance_set_timestamps(0,undefined)
rousr_dissonance_set_details("Making a Level")

AdMob_Banner_Hide()
}