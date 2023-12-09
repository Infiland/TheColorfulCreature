y = -64
x = 224
switch(global.language) {
default: text = "Are you sure you want to quit the Level Editor? (Y/N)" break;
}

if os_type = os_android {
	instance_create(400,500,o_buttonandroidyes)
	instance_create(550,500,o_buttonandroidno)

}