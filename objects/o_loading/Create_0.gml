//CHANGE THIS FOR MODS
global.moddedGameDir = "Test Mod 4"

scr_loading()

instance_create(x,y,o_loadingbar)
instance_create(x,y,o_musicvolumecreator)
instance_create(x,y,o_3ddot)
instance_create(x,y,o_deltatime)
instance_create(x,y,obj_controller_wave)
instance_create(x,y,o_getcalendartime)
instance_create(x,y,o_checkplayercount)
instance_create(x,y,o_fullscreensystem)
instance_create(x,y,Obj_AdMob)
instance_create(x,y,o_localization)

musicandsoundvolumefix()
if os_type = os_android {
if (!GooglePlayServices_IsSignedIn()) {
GooglePlayServices_StartSignInIntent();
}}

//global.langfont = font_add("Fonts\\OpenSans.tff",48,true,true,1,11)
alarm[0] = 15