if x < room_width {
audio_stop_all()
audio_sound_gain(m_multiplayerfight,global.musicvolume,1)
audio_play_sound(m_multiplayerfight,0,1)
loadhudMU()
global.racescore[0] = 0
global.racescore[1] = 0
global.racescore[2] = 0
global.racescore[3] = 0
global.MinigameMU = 2
randomlevelMU()
rousr_dissonance_set_details("Multiplayer Minigame - Race")
}