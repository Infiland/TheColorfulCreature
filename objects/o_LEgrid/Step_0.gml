key_grid = keyboard_check_pressed(ord("G"))
if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_namelevelLE) { exit }
if instance_exists(o_inputtext) { exit }
if key_grid {
if grid = 0 { grid = 1 } else { grid = 0 }	
}

if global.LEMode = 2 { grid = 0 }