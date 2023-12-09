if global.choosesettings != 0 { exit }

if image_alpha = 1 {
global.choosesettings = 5
if instance_exists(o_animatedtext) {
o_animatedtext.text = loc(226)
}}