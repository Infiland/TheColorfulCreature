if instance_exists(o_workshopchallengecreator) { exit }
if global.steam_api = true {
	instance_create(0,0,o_workshopchallengecreator)
}

