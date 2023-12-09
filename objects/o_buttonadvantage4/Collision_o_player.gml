if image_index = 0 { audio_play_sound(snd_hitboss,0,0) }
image_index = 1
global.lavabuttonconfirm[button] = 1

if global.lavabuttonconfirm[1] = 1 {
if global.lavabuttonconfirm[2] = 1 {
if global.lavabuttonconfirm[3] = 1 {
instance_destroy(o_key)
}}}