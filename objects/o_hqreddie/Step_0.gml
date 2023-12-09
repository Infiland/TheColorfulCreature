if image_yscale < 1.1 {
if change = 0 {
image_yscale -= 0.005 * (60 / global.maxfps)
if image_yscale < 0.9 {
	change = 1 
}
}}
if image_yscale > 0.01 {
if change = 1 {
image_yscale += 0.015 * (60 / global.maxfps)
if image_yscale > 1 {
	change = 0 
}
}}