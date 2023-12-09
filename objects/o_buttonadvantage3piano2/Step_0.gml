//Collision
if place_meeting(x,y,o_player) {
if global.pianohealth = 2 {
if cooldown <= 0 {
switch(global.pianotries) {
case(4):
if button = 1 {
global.pianobuttonconfirm1 = 1
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 2 {
global.pianobuttonconfirm1 = 2
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 3 {
global.pianobuttonconfirm1 = 3
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 4 {
global.pianobuttonconfirm1 = 4
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 5 {
global.pianobuttonconfirm1 = 5
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 6 {
global.pianobuttonconfirm1 = 6
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
break;
case(3):
if button = 1 {
global.pianobuttonconfirm2 = 1
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 2 {
global.pianobuttonconfirm2 = 2
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 3 {
global.pianobuttonconfirm2 = 3
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 4 {
global.pianobuttonconfirm2 = 4
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 5 {
global.pianobuttonconfirm2 = 5
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 6 {
global.pianobuttonconfirm2 = 6
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
break;
case(2):
if button = 1 {
global.pianobuttonconfirm3 = 1
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 2 {
global.pianobuttonconfirm3 = 2
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 3 {
global.pianobuttonconfirm3 = 3
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 4 {
global.pianobuttonconfirm3 = 4
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 5 {
global.pianobuttonconfirm3 = 5
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 6 {
global.pianobuttonconfirm3 = 6
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
break;
case(1):
if button = 1 {
global.pianobuttonconfirm4 = 1
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 2 {
global.pianobuttonconfirm4 = 2
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 3 {
global.pianobuttonconfirm4 = 3
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 4 {
global.pianobuttonconfirm4 = 4
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 5 {
global.pianobuttonconfirm4 = 5
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
if button = 6 {
global.pianobuttonconfirm4 = 6
cooldown = 50
audio_play_sound(snd_pickup,0,0)
global.pianotries -= 1
}
break;
}}}}


if cooldown >= 0 { 
if !place_meeting(x,y,o_player) {	
cooldown -= 1 * (60/global.maxfps)
}
image_index = 1
} else {
image_index = 0	
}

if global.pianotries = 0 {
if global.pianohealth = 2 {
if global.pianobuttonconfirm1 = global.pianobutton1 {
if global.pianobuttonconfirm2 = global.pianobutton2 {
if global.pianobuttonconfirm3 = global.pianobutton3 {
if global.pianobuttonconfirm4 = global.pianobutton4 {
o_spiketopboss3.y -= (66.66666666666667 + (global.boss3spikespeed * 150)) * (60/global.maxfps)
global.pianobuttonconfirm1 = 0
global.pianobuttonconfirm2 = 0
global.pianobuttonconfirm3 = 0
global.pianobuttonconfirm4 = 0
global.pianobuttonconfirm5 = 0
global.pianobuttonconfirm6 = 0
global.pianohealth -= 1
o_player.x = 512
o_player.y = 672
global.pianotries = 6
audio_play_sound(snd_tada,0,0)
instance_destroy(o_enemyplayer)
if global.hardmode = 1 { instance_create(800,512,o_enemyplayer) }
instance_destroy(o_buttonadvantage3piano2)
}}}}
if global.pianobuttonconfirm1 != global.pianobutton1 {
global.boss3spikespeed += 0.01
global.pianobuttonconfirm1 = 0
global.pianobuttonconfirm2 = 0
global.pianobuttonconfirm3 = 0
global.pianobuttonconfirm4 = 0
global.pianobuttonconfirm5 = 0
global.pianobuttonconfirm6 = 0
if !audio_is_playing(snd_pianofail) { audio_play_sound(snd_pianofail,0,0) }
global.pianotries = 4
}
if global.pianobuttonconfirm2 != global.pianobutton2 {	
global.boss3spikespeed += 0.01
global.pianobuttonconfirm1 = 0
global.pianobuttonconfirm2 = 0
global.pianobuttonconfirm3 = 0
global.pianobuttonconfirm4 = 0
global.pianobuttonconfirm5 = 0
global.pianobuttonconfirm6 = 0
if !audio_is_playing(snd_pianofail) { audio_play_sound(snd_pianofail,0,0) }
global.pianotries = 4
}
if global.pianobuttonconfirm3 != global.pianobutton3 {
global.boss3spikespeed += 0.01
global.pianobuttonconfirm1 = 0
global.pianobuttonconfirm2 = 0
global.pianobuttonconfirm3 = 0
global.pianobuttonconfirm4 = 0
global.pianobuttonconfirm5 = 0
global.pianobuttonconfirm6 = 0
if !audio_is_playing(snd_pianofail) { audio_play_sound(snd_pianofail,0,0) }
global.pianotries = 4
}
if global.pianobuttonconfirm4 != global.pianobutton4 {
global.boss3spikespeed += 0.01
global.pianobuttonconfirm1 = 0
global.pianobuttonconfirm2 = 0
global.pianobuttonconfirm3 = 0
global.pianobuttonconfirm4 = 0
global.pianobuttonconfirm5 = 0
global.pianobuttonconfirm6 = 0
if !audio_is_playing(snd_pianofail) { audio_play_sound(snd_pianofail,0,0) }
global.pianotries = 4
}
}}

if global.pianohealth = 3 {
image_alpha = 0
}
if global.pianohealth = 2 {
if timer = 0 {
alarm[5] = 1
timer = 1
}}