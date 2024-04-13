if locked = 0 {

if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

/*
global.workshop = 1
scr_loadchallengelevel()


var directory = program_directory + "//Challenges//Lunar Base Challenge//1/"

	if (file_exists(directory + "OtherLevelEditor.sav")) {
	ini_open(directory + "OtherLevelEditor.sav");
	global.LELevelWidthBlocks = ini_read_real("Other LE","Level Width Blocks",32);
	global.LELevelHeightBlocks = ini_read_real("Other LE","Level Height Blocks",22);
	}
	
room_set_width(r_challengelevel,global.LELevelWidthBlocks*32)
room_set_height(r_challengelevel,64+(global.LELevelHeightBlocks*32))

room_goto(r_challengelevel)

global.DiamondMedalTimeChallenge = diamondtime

global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_somethingswrong,0,1)
audio_sound_gain(m_somethingswrong,global.musicvolume,1)
*/
}