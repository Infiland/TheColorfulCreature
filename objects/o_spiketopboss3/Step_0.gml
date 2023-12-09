if global.pianohealth > 0 {
if global.pause = 1 { exit }
y += global.boss3spikespeed * (60/global.maxfps)
}
image_speed = (global.boss3spikespeed * 4) * (60/global.maxfps)
if global.pianohealth = 0 {
if spikeremoved = 1 {
instance_destroy()	
}
if image_angle < 180 {
image_angle += 5 * (60/global.maxfps)
}
if image_angle > 175 {
	image_angle = 180
	y -= (global.boss3spikespeed) * (60/global.maxfps)
global.boss3spikespeed += 0.01 * (60/global.maxfps)
}
}