if global.whiteblock > 0 {
if global.pause = 0 {	
instance_create(x,y,o_whitecircleeffect);
}
}
if global.whiteblock > 1 {
if global.pause = 0 {
if spawnchance = 0 {
instance_create(x+random_range(100,-100),y+random_range(100,-100),o_whiteparticle);
}}}
alarm[0] = random_range(20* (global.maxfps / 60),80* (global.maxfps / 60));