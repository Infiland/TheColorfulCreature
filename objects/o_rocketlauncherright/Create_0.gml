originaltimer = 84
timer = originaltimer
upsidedown = 0
tcc_randomize()
image_index = irandom_range(0,5)
if room = r_leveleditor {
alarm[0] = 1
}
// Navigation geometry changed; culling alone never invalidates the cache.
scr_troop_nav_mark_dirty();
