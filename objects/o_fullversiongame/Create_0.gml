/// @description Variables
if steam_get_app_id() != 1749610 {
instance_destroy()
}

declarecustombutton()
text = loc(608)

scr_loadsettings()
image_speed = 0;
image_index = 0