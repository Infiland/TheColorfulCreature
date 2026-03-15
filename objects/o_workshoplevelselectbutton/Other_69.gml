var map_id = async_load[? "id"];
var result = async_load[? "result"];

if (map_id == steam_details) && (result == ugc_result_success) {
	mTitle = async_load[? "title"];
	mTags = async_load[? "tags"];
	owner_id = async_load[? "steam_id_owner"];
	loaded = 1

	var easy = string_count("Easy", string(mTags));
	var medium = string_count("Medium", string(mTags));
	var difficult = string_count("Difficult", string(mTags));
	var insane = string_count("Insane", string(mTags));
	var unfair = string_count("Unfair", string(mTags));
	var impossible = string_count("Impossible", string(mTags));

	difficulty = 0
	if easy = 1 { difficulty = 1 }
	if medium = 1 { difficulty = 2 }
	if difficult = 1 { difficulty = 3 }
	if insane = 1 { difficulty = 4 }
	if unfair = 1 { difficulty = 5 }
	if impossible = 1 { difficulty = 6 }
}
