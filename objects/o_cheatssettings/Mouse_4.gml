if global.choosesettings != 0 { exit }

if image_alpha != 0.5 {
global.choosesettings = 4
if instance_exists(o_animatedtext) {
o_animatedtext.text = loc(13)
}
}