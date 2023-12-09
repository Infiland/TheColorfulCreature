scr_loading()
musicandsoundvolumefix()
if os_type = os_android {
if (!GooglePlayServices_IsSignedIn()) {
GooglePlayServices_StartSignInIntent();
}}

//global.langfont = font_add("Fonts\\OpenSans.tff",48,true,true,1,11)
alarm[0] = 15