if global.choosesettings != 0 { exit }

if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if global.autothumbnailsettings = 0 { 
	global.autothumbnailsettings = 1
	} else { global.autothumbnailsettings = 0 }