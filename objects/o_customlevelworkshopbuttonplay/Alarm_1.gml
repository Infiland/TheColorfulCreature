instance_create(x,y,o_customlevelworkshopcreate)
loadhud()
	var directory = game_save_id + "/Custom/Workshop/Medals/" + string(level) + "/"
	if !directory_exists(directory) {
	directory_create(directory)
	}
	
if !instance_exists(o_narrator) { instance_create(x,y,o_narrator) }
instance_destroy(o_coincounter)