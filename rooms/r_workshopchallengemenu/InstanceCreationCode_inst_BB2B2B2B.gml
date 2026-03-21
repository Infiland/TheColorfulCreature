global.workshopchallenges_scrollmax = 0
global.workshopchallenge_scrollmax = 0
set_rich_presence()

// Auto-open creator after beating a draft challenge
if (variable_global_exists("workshopchallenge_open_creator") && global.workshopchallenge_open_creator == 1) {
	global.workshopchallenge_open_creator = 0
	if global.steam_api = true {
		if !instance_exists(o_workshopchallengecreator) {
			instance_create(0,0,o_workshopchallengecreator)
		}
	}
}

