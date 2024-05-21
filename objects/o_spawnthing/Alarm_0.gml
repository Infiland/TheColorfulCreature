scr_loadleveleditor()

if !instance_exists(o_LEcounter) { instance_create(x,y,o_LEcounter) }
if !instance_exists(o_leveleditorselect) { instance_create(x,y,o_leveleditorselect) }
if !instance_exists(o_placeblock) { instance_create(x,y,o_placeblock) }
if !instance_exists(o_animatedLEicon) { instance_create(x,y,o_animatedLEicon) }
if !instance_exists(o_returnbutton) { instance_create(15,9,o_returnbutton) } //53
if !instance_exists(o_LESave) { instance_create(80,9,o_LESave) } 
if !instance_exists(o_LELoad) { instance_create(133,9,o_LELoad) }
if !instance_exists(o_LESettings) { instance_create(186,9,o_LESettings) }
if !instance_exists(o_LEItemMenu) { instance_create(239,9,o_LEItemMenu) }
if !instance_exists(o_LEMode) { instance_create(603,9,o_LEMode) }
if !instance_exists(o_LEThumbnail) { instance_create(371,9,o_LEThumbnail) }
if !instance_exists(o_LEPublish) { instance_create(424,9,o_LEPublish) }

//Camera
if global.LELevelHeightBlocks > 22 || global.LELevelWidthBlocks > 32 {
	if !instance_exists(o_smoothcamera) {
		if instance_exists(o_playerspawner) {
			instance_create(o_playerspawner.x,o_playerspawner.y,o_smoothcamera) 
		}
	}	
}

if global.LEFog = 1 { 
	if !instance_exists(o_fog) {
	instance_create(0,0,o_fog) }} else {
	instance_destroy(o_fog)	
	}


instance_destroy()