depth = 11;
if room != r_leveleditor {
if global.blockbackgroundsettings = 0 { instance_destroy() }
} else {
if global.leveleditorversion = 1 { global.leveleditorversion = 2 }
image_index = global.LEBlockBackgroundRotation	
}