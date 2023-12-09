if instance_exists(o_leveleditorleaveask) { exit }
if instance_exists(o_leveleditormenusetup) { exit }
if instance_exists(o_namelevelwhenloadingLE) { exit }

if global.LEMode = 1 {
if instance_exists(o_namelevelLE) { instance_destroy(o_itemmenuLE) }
if global.writingmode = 0 {
	instance_create(x,y,o_itemmenuLE)

}}