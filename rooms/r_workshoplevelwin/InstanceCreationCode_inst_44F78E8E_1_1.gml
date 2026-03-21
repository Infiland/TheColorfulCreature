if (variable_global_exists("workshopchallenge") && global.workshopchallenge == 1) {
	if (variable_global_exists("workshopchallenge_return_to_creator") && global.workshopchallenge_return_to_creator == 1) {
		text = global.workshopchallenge_title + "\nChallenge beaten! Press back to upload."
	} else {
		text = global.workshopchallenge_title
	}
} else {
	text = global.levelname
}
