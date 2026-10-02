y = -64
x = 224

text = loc("THIS_FEATURE_IS_NOT_AVAILABLE_IN_THE_DEMO_BUY_THE_FULL_VERSI") + " (Y/N)"
if gamepad_ui_connected() {
text = loc("THIS_FEATURE_IS_NOT_AVAILABLE_IN_THE_DEMO_BUY_THE_FULL_VERSI") +" [s_xboxcontrollerscheme,5] / [s_xboxcontrollerscheme,7]"
}

delay = 1

mobile_confirmation_init();
