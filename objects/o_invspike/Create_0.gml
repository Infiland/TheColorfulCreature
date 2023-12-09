randomize()
depth = 1
image_index = irandom_range(0,5)
image_speed = (1/6) * (60 / global.maxfps)
goldenspikechance = irandom_range(1,1000)
if room != r_leveleditor {
dissaperance = irandom_range(0,100000)
if dissaperance = 9999 {
instance_destroy();	
}
}
if goldenspikechance = 420 {
sprite_index = s_goldenspike	
}
if room = r_lvl21 {
audio_stop_sound(m_bosswin);	
}

if !place_meeting(x+32,y+32,o_anyblock) and !place_meeting(x-32,y+32,o_anyblock) and place_meeting(x,y+32,o_anyblock){
mask_index = s_spikeblockhitbox
}