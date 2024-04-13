if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}
audio_sound_gain(m_mainmenu,global.musicvolume,1)

//World progression is autoloaded here if someone ran the older version of the game
//for Level Select
if global.world1 = 1 && global.worldProgression < 20 {
	global.worldProgression = 20
}
if global.world2 = 1 && global.worldProgression < 40 {
	global.worldProgression = 40
}
if global.world3 = 1 && global.worldProgression < 60 {
	global.worldProgression = 60
}
if global.world4 = 1 && global.worldProgression < 80 {
	global.worldProgression = 80
}
if global.world5 = 1 && global.worldProgression < 100 {
	global.worldProgression = 100
}