state = 0
if global.hardmode = 0 {
	hp = 150 - (global.deaths / 15)
	if hp < 100 { hp = 100 }
} else { hp = 250 }
maxhp = hp

hsp = 0;
vsp = 0;
grv = 0.5


timerjump = 120
timercannon = irandom_range(7,10)

depth = -99

image_speed = 0

healthbar = instance_create_depth(0, 0, -1000, o_healthbar);
healthbar.target = id;