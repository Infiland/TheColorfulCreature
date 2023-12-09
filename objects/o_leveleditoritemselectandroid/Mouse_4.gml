if instance_exists(o_leveleditorleaveask) { exit }

if global.LEMode = 1 {
if instance_exists(o_namelevelLE) { instance_destroy(o_itemmenuLE) instance_destroy(o_itemmenuselectLE) }
if global.writingmode = 0 {
	instance_create(x,y,o_itemmenuLE)

}}