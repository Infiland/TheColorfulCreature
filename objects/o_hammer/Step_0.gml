if rotate = 1 {
image_angle += 7.5 * (60/global.maxfps)
}
if rotate = 2 {
image_angle -= 7.5 * (60/global.maxfps)
}

if place_meeting(x,y,o_redblock) {
rotate = 2
global.boss2button = 0
global.boss2health -= 1
alarm[0] = 1;
audio_play_sound(snd_bang,5,0)
}

hp = global.boss2health;

if image_angle < 0 {
rotate = 0
image_angle = 0
}

if global.boss2button = 1 {
rotate = 1	
}

if global.boss2health = 6 {
if change2 = 0 {
animation2 -= 0.0001 * (60/global.maxfps)
}
if change2 = 1 {
animation2 += 0.0003 * (60/global.maxfps)
}
if change2 = 0 {
if animation2 < 0.22 {
change2 = 1
}
}
if change2 = 1 {
if animation2 > 0.25 {
change2 = 0
}
}
}
if global.boss2health = 5 {
if change2 = 0 {
animation2 -= 0.0002 * (60/global.maxfps)
}
if change2 = 1 {
animation2 += 0.0006 * (60/global.maxfps)
}
if change2 = 0 {
if animation2 < 0.22 {
change2 = 1
}
}
if change2 = 1 {
if animation2 > 0.25 {
change2 = 0
}
}
}
if global.boss2health = 4 {
if change2 = 0 {
animation2 -= 0.0004 * (60/global.maxfps)
}
if change2 = 1 {
animation2 += 0.0012 * (60/global.maxfps)
}
if change2 = 0 {
if animation2 < 0.22 {
change2 = 1
}
}
if change2 = 1 {
if animation2 > 0.25 {
change2 = 0
}
}
}
if global.boss2health = 3 {
if change2 = 0 {
animation2 -= 0.0005 * (60/global.maxfps)
}
if change2 = 1 {
animation2 += 0.002 * (60/global.maxfps)
}
if change2 = 0 {
if animation2 < 0.22 {
change2 = 1
}
}
if change2 = 1 {
if animation2 > 0.25 {
change2 = 0
}
}
}
if global.boss2health = 2 {
if change2 = 0 {
animation2 -= 0.0007 * (60/global.maxfps)
}
if change2 = 1 {
animation2 += 0.0021 * (60/global.maxfps)
}
if change2 = 0 {
if animation2 < 0.22 {
change2 = 1
}
}
if change2 = 1 {
if animation2 > 0.25 {
change2 = 0
}
}
}
if global.boss2health = 1 {
if change2 = 0 {
animation2 -= 0.001 * (60/global.maxfps)
}
if change2 = 1 {
animation2 += 0.003 * (60/global.maxfps)
}
if change2 = 0 {
if animation2 < 0.22 {
change2 = 1
}
}
if change2 = 1 {
if animation2 > 0.25 {
change2 = 0
}
}
}

image_yscale = animation2