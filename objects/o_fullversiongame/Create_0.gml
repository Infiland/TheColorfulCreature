if (!platform_steam()) { instance_destroy(); exit; }
/// @description Variables
if tcc_steam_get_app_id() != 1749610 {
instance_destroy()
}

declarecustombutton()
text = loc("GET_FULL_VERSION")

scr_loadsettings()
