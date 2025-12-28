y = -64
x = 224
text = loc("ARE_YOU_SURE_YOU_WANT_TO_QUIT_THE_LEVEL_EDITOR") + " (Y/N)"

if os_type = os_android || os_type = os_gxgames {
	instance_create(400,500,o_buttonandroidyes)
	instance_create(550,500,o_buttonandroidno)

}