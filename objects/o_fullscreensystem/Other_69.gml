// Native create/join replies can outlive the destroyed manager.
// This persistent owner settles cancelled operations in menus/editor only.
if (!tcc_steam_initialised() || instance_exists(o_networkmanager)
    || !variable_global_exists("net_create_pending")) exit;
var _type = async_load[? "event_type"];
if (_type == "lobby_created" || _type == "lobby_joined") net_handle_async_steam(async_load);
