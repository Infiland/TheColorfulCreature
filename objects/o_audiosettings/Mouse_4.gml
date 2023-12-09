if global.choosesettings != 0 { exit }
global.choosesettings = 2
if instance_exists(o_animatedtext) {
o_animatedtext.text = loc(10);
}