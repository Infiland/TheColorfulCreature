y = -64
x = 224

text = loc("THIS_FEATURE_IS_NOT_AVAILABLE_IN_THE_DEMO_BUY_THE_FULL_VERSI") + " (Y/N)"
if gamepad_is_connected(0) {
text = loc("THIS_FEATURE_IS_NOT_AVAILABLE_IN_THE_DEMO_BUY_THE_FULL_VERSI") +" [s_xboxcontrollerscheme,5] / [s_xboxcontrollerscheme,7]"	
}

delay = 1

if os_type = os_android {
	instance_create(400,500,o_buttonandroidyes)
	instance_create(550,500,o_buttonandroidno)
}