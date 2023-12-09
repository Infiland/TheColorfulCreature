steam_details = steam_ugc_request_item_details(level, 30);

/*if mTags != "" {
if mFeatured = false {
checkfeatured = string_count( "Level of the Week", mTags );
if checkfeatured > 0 {
mFeatured = true
}
}

if mFeatured = true {
	checkfeatured = string_count( "Level of the Week", mTags );	
}
if checkfeatured < 0 {
mFeatured = false
}
}*/

	var directory = working_directory + "/Custom/Workshop/Medals/" + string(level) + "/"
	if !directory_exists(directory) {
	directory_create(directory)
	}
	scr_loadworkshopmedals()


alarm[0] = 20