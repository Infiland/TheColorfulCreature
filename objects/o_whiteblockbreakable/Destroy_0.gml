if room = r_leveleditor {
if global.LEMode = 2 {
instance_create(x,y,o_deleteblockanimation)
audio_play_sound(snd_blockbreak1,0,0)
}} else {
instance_create(x,y,o_deleteblockanimation)
audio_play_sound(snd_blockbreak1,0,0)
}
// Navigation geometry changed; culling alone never invalidates the cache.
scr_troop_nav_mark_dirty();
