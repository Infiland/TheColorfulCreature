y = -64
x = 224
text = loc("ARE_YOU_SURE_YOU_WANT_TO_RESET_YOUR_PROGRESS") + " (Y/N)"
if tcc_gamepad_is_connected(0) {
text = loc("ARE_YOU_SURE_YOU_WANT_TO_RESET_YOUR_PROGRESS") +" [s_xboxcontrollerscheme,5] / [s_xboxcontrollerscheme,7]"
}
delay = 1

mobile_confirmation_init();
