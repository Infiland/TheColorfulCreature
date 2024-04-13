if instance_exists(o_progressask) { exit }

if !instance_exists(o_quitask) {
room_goto(r_support);
window_set_cursor(cr_default)
audio_sound_pitch(m_mainmenu,1)	
}