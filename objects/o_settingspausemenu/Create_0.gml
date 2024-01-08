depth = -100
instance_create(x,y,o_info)

if os_type = os_android {
instance_destroy(o_buttoninteractandroid)
instance_destroy(o_buttonjumpandroid)
instance_destroy(o_buttonpauseandroid)
instance_destroy(o_buttonleftandroid)
instance_destroy(o_buttonrightandroid)
instance_destroy(o_buttonrestartandroid)
}

//Main

instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_visualsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+224,o_audiosettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+288,o_controlssettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+352,o_cheatssettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+416,o_languagessettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+480,o_fpssettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+544,o_autopausesettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+608,o_decimalsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_maxfpssettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+224,o_objcountersettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+288,o_casualmodesettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+352,o_autothumbnailsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+416,o_skipintroscreensettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+480,o_antialiasingsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+544,o_vsyncsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+608,o_biglevelperfsettings)

//Visuals
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_starsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+224,o_blocksettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+288,o_itemsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+352,o_playersettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+416,o_backroundsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+480,o_vignettesettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+544,o_3dsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+608,o_blockbackgroundsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_colorblindsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+224,o_fullscreensettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+288,o_watershadersettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+352,o_gunvisibilitysettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+416,o_oldGSsettings)

instance_create(camera_get_view_x(view_camera[0])+1030,camera_get_view_y(view_camera[0])+189,o_poorsettings)
instance_create(camera_get_view_x(view_camera[0])+1030,camera_get_view_y(view_camera[0])+189,o_lowsettings)
instance_create(camera_get_view_x(view_camera[0])+1030,camera_get_view_y(view_camera[0])+244,o_mediumsettings)
instance_create(camera_get_view_x(view_camera[0])+1030,camera_get_view_y(view_camera[0])+244,o_highsettings)

//Audio
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_musicdistortionsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+224,o_troopvoicelinessettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+288,o_musicsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+352,o_soundsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+416,o_mastervolumesettings)
instance_create(camera_get_view_x(view_camera[0]),camera_get_view_y(view_camera[0])+313,o_settingsslidermusic)
instance_create(camera_get_view_x(view_camera[0]),camera_get_view_y(view_camera[0])+377,o_settingsslidersound)
instance_create(camera_get_view_x(view_camera[0]),camera_get_view_y(view_camera[0])+441,o_settingsslidermastervolume)

//Cheats
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_turnoncheatssettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+224,o_easysettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+288,o_infinitelivessettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+352,o_noclipsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+416,o_berserksettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+480,o_visiblethingssettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+544,o_managablejumpsettings)

//Controls
var i = 0
for(i=0;i<6;i++) {
lol = instance_create(camera_get_view_x(view_camera[0])-128,camera_get_view_y(view_camera[0])+160+80*i,o_controlsbuttonsettings)
with lol {
controls = i
}}

instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_skiplevelholdsettings)
instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160,o_controllervibrationsettings)
if os_type != os_android {
instance_create(camera_get_view_x(view_camera[0])-128,camera_get_view_y(view_camera[0])+640,o_defaultkeysbuttonsetings)
} else { instance_create(camera_get_view_x(view_camera[0])-128,camera_get_view_y(view_camera[0])+160,o_defaultkeysbuttonsetings) }

//Languages
var i2 = 0
for (i2=0;i2<12;i2++) {
lang = instance_create(camera_get_view_x(view_camera[0])-256,camera_get_view_y(view_camera[0])+160+((64*i2)-(floor(i2/8)*512)),o_changelanguagesettings)
with lang {
depth = -101
image_xscale = 37.7
image_yscale = 10
language = i2
xscale = 0.7
yscale = 0.7
width = 3
}}

instance_create(x,y,o_animatedtext)
with(o_animatedtext) {
texty = 40
text = loc(8);
}

alarm[0] = 2

instance_deactivate_object(o_settings)
instance_deactivate_object(o_givefeedback)
instance_deactivate_object(o_pausescreen)
if global.challenges = 1 {
instance_deactivate_object(o_restartchallengebutton)
}