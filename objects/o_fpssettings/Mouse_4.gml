if global.choosesettings != 0 { exit }

global.fpssettings += 1
if global.fpssettings > 0 {
if !instance_exists(o_fpscounter) {
instance_create(x,y,o_fpscounter)
}	
}
if global.fpssettings > 2 {
global.fpssettings = 0
if instance_exists(o_fpscounter) {
instance_destroy(o_fpscounter)
}
}
scr_savesettings()