global.workshop = 0
timing_ui_register_target("workshop-level");
depth = -102
//level = 2561237485
level = 2592571669
mTitle = "Loading"
mDesc = ""
mName = ""
mOwner = 0
ownername = "Unknown"
mScore = 0
mLikes = 0
mDislikes = 0
mPubFileId = 0
mPath = ""
canrequest = 0
mBanned = false
mTags = ""
mFeatured = false
checkfeatured = 0

// Asks Steam for the details of this level and applies the answer. A reply can be lost
// without any signal, so a new request waits until the previous one is answered or 20 s passed.
details_wait_until = 0
request_details = function() {
	if current_time < details_wait_until { return }
	var _on_details = method({inst: id}, function(_ok, _items, _completed) {
		if !instance_exists(inst) { return }
		inst.details_wait_until = 0
		if !_ok { return }
		for (var i = 0; i < array_length(_items); i++) {
			var _item = _items[i]
			if _item.published_file_id != inst.level { continue }
			with (inst) {
				mTitle = _item.title
				mDesc = _item.description
				mTags = _item.tags
				mPubFileId = _item.published_file_id
				mOwner = _item.owner_steam_id
				mLikes = _item.votes_up
				mDislikes = _item.votes_down
				mBanned = (_item.banned == true)
				loaded = 1
			}
			break
		}
	})
	if tcc_steam_ugc_request_item_details(level, 30, _on_details, id) {
		details_wait_until = current_time + 20000
	}
}
request_details()

loaded = 0

//Medals
time = 9999999
requiredtime = 999999

//Difficulty
difficulty = 0


alarm[0] = 20
