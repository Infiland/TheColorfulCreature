state = 1
move = -1

if global.hardmode = 1 {
hp = 5
} else { hp = 2 }

if global.checkpointX != 0 { instance_destroy() }