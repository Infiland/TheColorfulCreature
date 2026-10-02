image_alpha = 0
hidesprites = false

if global.visiblethings = 1 { image_alpha = 1 }
// Navigation geometry changed; culling alone never invalidates the cache.
scr_troop_nav_mark_dirty();
