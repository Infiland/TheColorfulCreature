depth = -10000000001
image_speed = 0
grab = false

// Settings-specific instance variables (set by spawner)
slider_gvar = "musicvolume"
slider_menu = 2
slider_info_id = 6
slider_soundchange_id = 1
slider_label = "MUSIC_VOLUME"

// Slider range
xcam = camera_get_view_x(view_camera[0])
x = xcam + 116 + (variable_global_get(slider_gvar) * 146) - 200
beginx = xcam + 116
endx = xcam + 262
