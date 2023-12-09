if global.musicdistortionsettings = 1 {
if !(room = r_leveleditor) {
if instance_exists(o_player) {
if pitch < pitchspeed {
pitch += 0.02 * (60 / global.maxfps)
}
} else {
if pitch > 0 {
pitch -= 0.01 * (60 / global.maxfps)
}
pitchspeed = 1
}

}
if instance_exists(o_player) { 
	if o_player.walksp = 2.8 { pitchspeed = 0.8 }
	if o_player.walksp = 4 { pitchspeed = 1 }
	if o_player.walksp = 5.5 { pitchspeed = 1.2 }
	if o_player.walksp = 8.5 { pitchspeed = 1.35 }
	pitch = lerp(pitch,pitchspeed,0.02 * (60 / global.maxfps)) 
	}

} else {
if pitchspeed != 1 { pitchspeed = 1 }
}

audio_sound_pitch(m_basics,pitch)
audio_sound_pitch(m_owthespikes,pitch)
audio_sound_pitch(m_bosswin,pitch)
audio_sound_pitch(m_everythingismoving,pitch)
audio_sound_pitch(m_hammertime,pitch)
audio_sound_pitch(m_warp,pitch)
audio_sound_pitch(m_corruptedworld,pitch)
audio_sound_pitch(m_lesscorruption,pitch)
audio_sound_pitch(m_lavatime,pitch)
audio_sound_pitch(m_funmodelevels,pitch)
audio_sound_pitch(m_funmodelevels2,pitch)
audio_sound_pitch(m_funmodelevels3,pitch)
audio_sound_pitch(m_funmodelevels4,pitch)
audio_sound_pitch(m_pianotime,pitch)
audio_sound_pitch(m_thecastle,pitch)
audio_sound_pitch(m_troopsincoming,pitch)
audio_sound_pitch(m_emptyambient,pitch)
audio_sound_pitch(m_wearefinallyhere,pitch)
audio_sound_pitch(m_world6,pitch)
audio_sound_pitch(m_heaven,pitch)
audio_sound_pitch(m_kingsmarch,pitch)
audio_sound_pitch(m_heartbeat,pitch)
audio_sound_pitch(m_underwater,pitch)
audio_sound_pitch(m_multiplayerfight,pitch)
audio_sound_pitch(m_forthefans,pitch)
audio_sound_pitch(m_stealth,pitch)
audio_sound_pitch(m_lavatime,pitch)
audio_sound_pitch(m_somethingswrong,pitch)
audio_sound_pitch(m_kingsthrone,pitch)
audio_sound_pitch(m_blocktension,pitch)
audio_sound_pitch(m_neoncolor,pitch)
audio_sound_pitch(m_readyornot,pitch)
audio_sound_pitch(m_ahoy,pitch)
audio_sound_pitch(m_basicsretro,pitch)