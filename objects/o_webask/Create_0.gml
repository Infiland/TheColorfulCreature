y = -64
x = 224

//If there's more than 1 popup
if instance_number(o_webask) > 1 { instance_destroy() }

url = ""
text = loc("THIS_WILL_OPEN_YOUR_BROWSER_GO_TO_THE_PAGE") + " (Y/N)"
if tcc_gamepad_is_connected(0) {
text = loc("THIS_WILL_OPEN_YOUR_BROWSER_GO_TO_THE_PAGE") +" [s_xboxcontrollerscheme,5] / [s_xboxcontrollerscheme,7]"
}

delay = 1

mobile_confirmation_init();
