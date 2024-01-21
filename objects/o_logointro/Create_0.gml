//CHANGE THIS FOR MODS
global.soundvolume = 0.5
global.maxfps = 60

scr_loading()

if global.skipintroscreensettings = 1 {
room_goto(r_loading)
audio_stop_sound(snd_difficultyupER)
exit
}

depth = -101
changey = 0
changex = 0
textchange = 0
textspeed = 0.03 * (60 / global.maxfps)
red = 0
blue = 0
green = 0
timer = 150
dist = 2

y = 850
change = 0
text = "Made by Infiland"
audio_sound_gain(snd_difficultydownER,global.soundvolume,1)
audio_sound_gain(snd_difficultyupER,global.soundvolume,1)
audio_play_sound(snd_difficultyupER,0,0)

timerlogo = 100
//alarm[0] = 1