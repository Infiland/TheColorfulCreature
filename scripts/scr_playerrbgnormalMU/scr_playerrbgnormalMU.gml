function scr_playerrbgnormalMU() {
if color = 0 {
	red = 255
	green = 0
	blue = 0
	}
if color = 1 {
	red = 255
	green = 255
	blue = 0
}
if color = 2 {
	red = 0
	green = 255
	blue = 0
}
if color = 3 {
	red = 0
	green = 255
	blue = 255
}
if color = 4 {
	red = 255
	green = 255
	blue = 255
	}
image_blend = make_color_rgb(red,green,blue)
}
