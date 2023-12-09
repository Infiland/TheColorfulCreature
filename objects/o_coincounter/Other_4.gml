scr_playercontrolsconfig()

if global.skiplevelholdsettings = 0 {
skip = "Press [" + string(keyd) + "] to skip\n a level ("+ string(reqcoin) + " Coins)"
}
if global.skiplevelholdsettings = 1 {
skip = "Hold [" + string(keyd) + "] to skip\n a level ("+ string(reqcoin) + " Coins)"
}
if room = r_boss1prepare { skip = "You can't skip\nthis level" }
if room = r_boss4 { skip = "You can't skip\nthis level" }
if room = r_boss3 { skip = "You can't skip\nthis level" }
if room = r_boss2 { skip = "You can't skip\nthis level" }
if room = r_boss1 { skip = "You can't skip\nthis level" 	}
if room = r_boss2prepare { skip = "You can't skip\nthis level" }
if room = r_boss3prepare { skip = "You can't skip\nthis level" 	}
if room = r_boss4prepare { skip = "You can't skip\nthis level" 	}
if room = r_easteregg1 { skip = "You can't skip\nthis level" }
if room = r_easteregg2 { skip = "You can't skip\nthis level" }
if room = r_easteregg3 { skip = "You can't skip\nthis level" }
if room = r_truelvl100_p1 { skip = "It's no use.\nCoins are meaningless." }
if room = r_truelvl100_p2 { skip = "It's no use.\nCoins are meaningless." }
if room = r_boss5 { skip = "You can't just\nskip the final boss." }