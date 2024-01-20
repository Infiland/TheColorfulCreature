steam_details = steam_ugc_request_item_details(level, 30);
requestname = steam_get_user_persona_name(mOwner);

if loaded = 1 {
	var bruh = string_count( "Level of the Week",  string(mTags));
	if bruh = 1 {
		mFeatured = true
	}
}
	var directory = directory_set("/Custom/Workshop/Medals/" + string(level) + "/")
	if !directory_exists(directory) {
	directory_create(directory)
	}
	scr_loadworkshopmedals()
	
if loaded = 1 {

var easy = string_count( "Easy", string(mTags) );
var medium = string_count( "Medium", string(mTags) );
var difficult = string_count( "Difficult", string(mTags) );
var insane = string_count( "Insane", string(mTags) );
var unfair = string_count( "Unfair", string(mTags) );
var impossible = string_count( "Impossible", string(mTags) );

if easy = 1 { difficulty = 1 }
if medium = 1 { difficulty = 2 }
if difficult = 1 { difficulty = 3 }
if insane = 1 { difficulty = 4 }
if unfair = 1 { difficulty = 5 }
if impossible = 1 { difficulty = 6 }

}


alarm[0] = 30


/*steam_details = steam_ugc_request_item_details(level, 30);
/*if canrequest = 1 {
if mName = "" {
request_name = steam_get_user_persona_name(mOwner);
}}
if mTags != "" {
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
}

	var directory = working_directory + "/Custom/Workshop/Medals/" + string(level) + "/"
	if !directory_exists(directory) {
	directory_create(directory)
	}
	scr_loadworkshopmedals()
	
alarm[0] = 20