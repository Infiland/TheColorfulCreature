/*
if global.totaltime < 99000 + global.asteroidfun*150000 {
chance = (100000 + global.asteroidfun*150000) - global.totaltime
} else {
chance = 500
}
points = global.asteroidskeypoints + global.foundcog
randomize()
RNG = irandom(chance)+1

show_debug_message(string(RNG) + " " + string(global.asteroidskeypoints))

if !instance_exists(o_player) {
	if steam_user_owns_dlc(1651680) {
	if global.asteroidskeypoints > 2 {
		if global.cheats = 0 {
		if global.totaltime > 7200 {
			if RNG < points {
			show_debug_message("Gave a key")
			
							var arr = array_length(keylist)-1
			var rng = irandom(arr)
				steam_create_leaderboard(keylist[rng],lb_sort_ascending,lb_disp_time_ms)
				steam_upload_score(keylist[rng],1)
				show_debug_message(keylist[rng])
				
				var WHAT = keylist[rng]
				var ky = instance_create_depth(x,y,-10,o_keybanner)
				with ky {
				key = WHAT
				clipboard_set_text(WHAT)
				}
				global.asteroidfun += 1
				instance_destroy()
				scr_savestats()
				

				}
			}
		}
	}
}
}