if (!timing_instance_step()) exit;
if global.pause = 0 {
speed = 10 * (60 / TCC_SIM_HZ) }
else { speed = 0 }

if x < 1088 {
var givehp = hpproj
instance_destroy()
var troop = instance_create(x,y-2,o_enemyplayer)
with troop {
hp = givehp
state = 1
hasammo = 1
move = choose(1,-1)
}
}
// A slope blocks only its filled triangle.
if (scr_slope_projectile_sweep(x, y, x + hspeed, y + vspeed)) { instance_destroy(); exit; }
