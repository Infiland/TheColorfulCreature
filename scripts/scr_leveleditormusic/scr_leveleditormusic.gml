function scr_leveleditormusic() {
	audio_stop_all()
	
	if room = r_leveleditor {
var directory = game_save_id + "/LevelEditor Files/" + global.levelname + "/Music.ogg"
} else {
//var directory = global.workshopfolder + "/Music.ogg/"
var directory = global.workshopfolder + "/Music.ogg"
directory = string_replace_all(directory,"\\","/")
}

if file_exists(directory) {
var mus = audio_create_stream(directory)
audio_stop_all()
audio_create_stream(mus)
audio_play_sound(mus,0,1)
audio_sound_gain(mus,global.musicvolume,1)
exit;
}

	switch(global.leveleditormusic) {
	case(0):
	audio_sound_gain(m_leveleditor,global.musicvolume,1)
	audio_play_sound(m_leveleditor,0,1)
	break;
	case(1):
	audio_sound_gain(m_basics,global.musicvolume,1)
	audio_play_sound(m_basics,0,1)
	break;
	case(2):
	audio_sound_gain(m_hotdogtimephase3,global.musicvolume,1)
	audio_play_sound(m_hotdogtimephase3,0,1)
	break;
	case(3):
	audio_sound_gain(m_owthespikes,global.musicvolume,1)
	audio_play_sound(m_owthespikes,0,1)
	break;
	case(4):
	audio_sound_gain(m_hammertime,global.musicvolume,1)
	audio_play_sound(m_hammertime,0,1)
	break;
	case(5):
	audio_sound_gain(m_everythingismoving,global.musicvolume,1)
	audio_play_sound(m_everythingismoving,0,1)
	break;
	case(6):
	audio_sound_gain(m_funmodelevels,global.musicvolume,1)
	audio_play_sound(m_funmodelevels,0,1)
	break;
	case(7):
	audio_sound_gain(m_funmodelevels2,global.musicvolume,1)
	audio_play_sound(m_funmodelevels2,0,1)
	break;
	case(8):
	audio_sound_gain(m_corruptedworld,global.musicvolume,1)
	audio_play_sound(m_corruptedworld,0,1)	
	break;
	case(9):
	audio_sound_gain(m_lesscorruption,global.musicvolume,1)
	audio_play_sound(m_lesscorruption,0,1)
	break;
	case(10):
	audio_sound_gain(m_pianotime,global.musicvolume,1)
	audio_play_sound(m_pianotime,0,1)
	break;
	case(11):
	audio_sound_gain(m_lavatime,global.musicvolume,1)
	audio_play_sound(m_lavatime,0,1)
	break;
	case(12):
	audio_sound_gain(m_thecastle,global.musicvolume,1)
	audio_play_sound(m_thecastle,0,1)
	break;
	case(13):
	audio_sound_gain(m_funmodelevels3,global.musicvolume,1)
	audio_play_sound(m_funmodelevels3,0,1)
	break;
	case(14):
	audio_sound_gain(m_troopsincoming,global.musicvolume,1)
	audio_play_sound(m_troopsincoming,0,1)
	break;
	case(15):
	audio_sound_gain(m_wearefinallyhere,global.musicvolume,1)
	audio_play_sound(m_wearefinallyhere,0,1)
	break;
	case(16):
	audio_sound_gain(m_emptyambient,global.musicvolume,1)
	audio_play_sound(m_emptyambient,0,1)
	break;
	case(17):
	audio_sound_gain(m_world6,global.musicvolume,1)
	audio_play_sound(m_world6,0,1)
	break;
	case(18):
	audio_sound_gain(m_heaven,global.musicvolume,1)
	audio_play_sound(m_heaven,0,1)
	break;
	case(19):
	audio_sound_gain(m_heartbeat,global.musicvolume,1)
	audio_play_sound(m_heartbeat,0,1)
	break;
	case(20):
	audio_sound_gain(m_kingsmarch,global.musicvolume,1)
	audio_play_sound(m_kingsmarch,0,1)
	break;
	case(21):
	audio_sound_gain(m_underwater,global.musicvolume,1)
	audio_play_sound(m_underwater,0,1)
	break;
	case(22):
	audio_sound_gain(m_multiplayerfight,global.musicvolume,1)
	audio_play_sound(m_multiplayerfight,0,1)
	break;
	case(23):
	audio_sound_gain(m_funmodelevels4,global.musicvolume,1)
	audio_play_sound(m_funmodelevels4,0,1)
	break;
	case(24):
	audio_sound_gain(m_forthefans,global.musicvolume,1)
	audio_play_sound(m_forthefans,0,1)
	break;
	case(25):
	audio_sound_gain(m_stealth,global.musicvolume,1)
	audio_play_sound(m_stealth,0,1)
	break;
	case(26):
	audio_sound_gain(m_somethingswrong,global.musicvolume,1)
	audio_play_sound(m_somethingswrong,0,1)
	break;
	case(27):
	audio_sound_gain(m_kingsthrone,global.musicvolume,1)
	audio_play_sound(m_kingsthrone,0,1)
	break;
	case(28):
	audio_sound_gain(m_blocktension,global.musicvolume,1)
	audio_play_sound(m_blocktension,0,1)
	break;
	case(29):
	audio_sound_gain(m_neoncolor,global.musicvolume,1)
	audio_play_sound(m_neoncolor,0,1)
	break;
	case(30):
	audio_sound_gain(m_readyornot,global.musicvolume,1)
	audio_play_sound(m_readyornot,0,1)
	break;
	case(31):
	audio_sound_gain(m_ahoy,global.musicvolume,1)
	audio_play_sound(m_ahoy,0,1)
	break;
	}
	if global.leveleditormusic < 0 {
	audio_sound_gain(m_ahoy,global.musicvolume,1)
	audio_play_sound(m_ahoy,0,1)
	global.leveleditormusic = 31
	}
	if global.leveleditormusic > 31 {
	audio_sound_gain(m_leveleditor,global.musicvolume,1)
	audio_play_sound(m_leveleditor,0,1)
	global.leveleditormusic = 0
	}


}
