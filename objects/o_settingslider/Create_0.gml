depth = -10000000001
image_speed = 0
grab = false

// Settings-specific instance variables (set by spawner)
slider_gvar = "musicvolume"
slider_menu = 2
slider_info_id = 6
slider_soundchange_id = 1
slider_label = "MUSIC_VOLUME"

// Custom range support (defaults for 0-1 volume sliders)
slider_min = 0
slider_max = 1
slider_integer = false
slider_beginx_offset = 116

// Slider range
xcam = camera_get_view_x(view_camera[0])
beginx = xcam + slider_beginx_offset
endx = beginx + 146
var _normalized = (slider_max != slider_min) ? (variable_global_get(slider_gvar) - slider_min) / (slider_max - slider_min) : 0
x = beginx + (_normalized * 146) - 200
