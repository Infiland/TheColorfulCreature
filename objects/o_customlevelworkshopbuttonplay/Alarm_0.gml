if (!timing_is_tick()) exit;
// The details are asked again only until they have arrived (user event 0 refreshes them)
if loaded = 0 {
	request_details()
}
// No event announces the owner name: ask again every cycle until Steam knows it
if tcc_steam_id_valid(mOwner) {
	var _owner_name = tcc_steam_get_user_persona_name_sync(mOwner)
	if _owner_name != "" { ownername = _owner_name }
}

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
