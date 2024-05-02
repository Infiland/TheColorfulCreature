//Shows debug screen only if cheats are on
if global.cheats = 1 {
	if global.debugoverlaysettings = 0 { global.debugoverlaysettings = 1 }
	else { global.debugoverlaysettings = 0 }
	show_debug_overlay(global.debugoverlaysettings)
}