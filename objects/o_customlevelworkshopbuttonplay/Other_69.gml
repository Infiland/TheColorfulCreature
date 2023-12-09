var map_id = async_load[? "id"];
var result = async_load[? "result"];
//var userresult = async_load[? "event_type"]


if (map_id == steam_details) && (result == ugc_result_success)
    {
    mTitle = async_load[? "title"];
	mDesc = async_load[? "description"];
    mTags = async_load[? "tags"];
	mPubFileId = async_load[? "published_file_id"];
    //mScore = async_load[? "score"];
	mOwner = async_load[? "steam_id_owner"];
	mLikes = async_load[? "votes_up"];
	mDislikes = async_load[? "votes_down"];
	mBanned = async_load[? "banned"];
	loaded = 1
	}


        if (async_load[?"id"] == requestname)
        {
			ownername = async_load[? "persona_name"];	
		}
	
/*var name_id = async_load[? "id"];
if (name_id == request_name) {
	mName = async_load[? "persona_name"];
}*/