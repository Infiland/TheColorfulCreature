// Only the level's creator saves, loads and publishes a level built together.
if (net_coop_is_guest()) exit;
if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_leveleditormenusetup) { exit }

if global.LEMode = 1 {

if instance_exists(o_namelevelLE) { exit }

if global.writingmode = 0 {
if !instance_exists(o_leveleditorresetask) {
instance_create(x,y,o_leveleditorresetask)
}
}

}