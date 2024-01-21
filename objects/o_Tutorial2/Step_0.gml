scr_playercontrolsconfig()
if jumpcontrols = 0 { key_jump = (gamepad_button_check(0,gp_face1)) || keyboard_check(ord(global.controlsjump)) }
else { key_jump = (gamepad_button_check(0,gp_face1)) || keyboard_check(global.controlsjump) }
if global.pause = 1{ exit }
image_index = 0
if key_jump { image_index = 1 }
y = lerp(y,32,0.03* (60 / global.maxfps))