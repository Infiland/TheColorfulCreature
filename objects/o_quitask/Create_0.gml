y = -64
x = 224
text = loc("ARE_YOU_SURE_YOU_WANT_TO_QUIT_THE_GAME") +" (Y/N)"
if gamepad_ui_connected() {
text = loc("ARE_YOU_SURE_YOU_WANT_TO_QUIT_THE_GAME") +" [s_xboxcontrollerscheme,5] / [s_xboxcontrollerscheme,7]"
}

delay = 1

mobile_confirmation_init();
