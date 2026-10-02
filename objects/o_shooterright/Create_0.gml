originaltimer = 84
timer = originaltimer
upsidedown = 0
image_index = 0
image_speed = 0
if room = r_leveleditor {
alarm[0] = 1
}
// Navigation geometry changed; culling alone never invalidates the cache.
scr_troop_nav_mark_dirty();
