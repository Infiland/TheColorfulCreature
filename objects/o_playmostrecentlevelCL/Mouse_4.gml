steam_details = steam_ugc_request_item_details(global.fileID, 60);

var map_id = async_load[? "id"];
var result = async_load[? "result"];
if (map_id == steam_details) && (result == ugc_result_success)
    {
    mTitle = async_load[? "title"];
    mDesc = async_load[? "description"];
    mTags = async_load[? "tags"];
    m_hPreviewFile = async_load[? "handle_preview_file"];
    m_hOwnerSteamId = async_load[? "steam_id_owner"];
    mOwnerAccountId = async_load[? "account_id_owner"];
    mPubFileId = async_load[? "published_file_id"];
    mScore = async_load[? "score"];
    }