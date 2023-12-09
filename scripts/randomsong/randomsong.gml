function randomsong(){
	switch(global.chooserandommusic) {
	default: break;
	case(1): global.chosenmusicER = m_basics break;
	case(2): global.chosenmusicER = m_hotdogtimephase3 break;
	case(3): global.chosenmusicER = m_owthespikes break;
	case(4): global.chosenmusicER = m_hammertime break;
	case(5): global.chosenmusicER = m_everythingismoving break;
	case(6): global.chosenmusicER = m_funmodelevels break;
	case(7): global.chosenmusicER = m_funmodelevels2 break;
	case(8): global.chosenmusicER = m_corruptedworld break;
	case(9): global.chosenmusicER = m_lesscorruption break;
	case(10): global.chosenmusicER = m_troopsincoming break;
	case(11): global.chosenmusicER = m_lavatime break;
	case(12): global.chosenmusicER = m_thecastle break;
	case(13): global.chosenmusicER = m_funmodelevels3 break;
	case(14): global.chosenmusicER = m_troopsincoming break;
	case(15): global.chosenmusicER = m_wearefinallyhere break;
	case(16): global.chosenmusicER = m_emptyambient break;
	case(17): global.chosenmusicER = m_world6 break;
	case(18): global.chosenmusicER = m_heaven break;
	case(19): global.chosenmusicER = m_heartbeat break;
	case(20): global.chosenmusicER = m_kingsmarch break;
	case(21): global.chosenmusicER = m_underwater break;
	case(22): global.chosenmusicER = m_multiplayerfight break;
	case(23): global.chosenmusicER = m_funmodelevels4 break;
	case(24): global.chosenmusicER = m_forthefans break;
	case(25): global.chosenmusicER = m_stealth break;
	case(26): global.chosenmusicER = m_somethingswrong break;
	case(27): global.chosenmusicER = m_blocktension break;
	case(28): global.chosenmusicER = m_neoncolor break;
	case(29): global.chosenmusicER = m_readyornot break;
	}
	audio_stop_all()
	audio_play_sound(global.chosenmusicER,0,1)
	audio_sound_gain(global.chosenmusicER,global.musicvolume,1)
}