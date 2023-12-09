function scr_playerrbgMU() {
	if color = 0 {
		red = lerp(red,255,0.1 * (60 / global.maxfps))
		blue = lerp(blue,0,0.1 * (60 / global.maxfps))
		green = lerp(green,0,0.1 * (60 / global.maxfps))
		}
	if color = 1 {
		red = lerp(red,255,0.1 * (60 / global.maxfps))
		blue = lerp(blue,0,0.1 * (60 / global.maxfps))
		green = lerp(green,255,0.1 * (60 / global.maxfps))
		}
	if color = 2 {
		red = lerp(red,0,0.1 * (60 / global.maxfps))
		blue = lerp(blue,0,0.1 * (60 / global.maxfps))
		green = lerp(green,255,0.1 * (60 / global.maxfps))
		}
	if color = 3 {
		red = lerp(red,0,0.1 * (60 / global.maxfps))
		blue = lerp(blue,255,0.1 * (60 / global.maxfps))
		green = lerp(green,255,0.1 * (60 / global.maxfps))
		}
	if color = 4 {
	if change = 0 {
	blue += 15 * (60 / global.maxfps)
	if blue > 255 {
	blue = 255
	change = 1
	}}
	if change = 1 {
	red -= 15 * (60 / global.maxfps)
	if red < 0 {
	red = 0
	change = 2
	}}
	if change = 2 {
	green += 15 * (60 / global.maxfps)
	if green > 255 {
	green = 255
	change = 3
	}}
	if change = 3 {
	blue -= 15 * (60 / global.maxfps)
	if blue < 0 {
	blue = 0
	change = 4
	}}
	if change = 4 {
	red += 15 * (60 / global.maxfps)
	if red > 255 {
	red = 255
	change = 5
	}}
	if change = 5 {
	green -= 15 * (60 / global.maxfps)
	if green < 0 {
	green = 0
	change = 0
	}}
		}
	image_blend = make_color_rgb(red,green,blue)


}
