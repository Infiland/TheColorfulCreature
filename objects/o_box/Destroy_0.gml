if room != r_leveleditor {
	increase_stat("totaldestroyedboxes","QUESTdestroyedboxes",1)
}
// Navigation geometry changed; culling alone never invalidates the cache.
scr_troop_nav_mark_dirty();
