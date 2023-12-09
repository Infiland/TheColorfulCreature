if room = r_leveleditor {
if global.LEMode = 2 {
instance_create(x,y,o_deleteblockanimation)
audio_play_sound(snd_blockbreak1,0,0)
}} else {
instance_create(x,y,o_deleteblockanimation)
audio_play_sound(snd_blockbreak1,0,0)
}