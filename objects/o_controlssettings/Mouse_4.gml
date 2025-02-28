if global.choosesettings != 0 { exit }
global.choosesettings = 3

if os_type = os_android || os_type = os_gxgames {
	if !instance_exists(o_buttonleftandroid) { instance_create(x,y,o_buttonleftandroid) }
	if !instance_exists(o_buttonrightandroid) { instance_create(x,y,o_buttonrightandroid) }
	if !instance_exists(o_buttonjumpandroid) { instance_create(x,y,o_buttonjumpandroid) }
	if !instance_exists(o_buttoninteractandroid) { instance_create(x,y,o_buttoninteractandroid) }
	if !instance_exists(o_buttonrestartandroid) { instance_create(x,y,o_buttonrestartandroid) }
	if !instance_exists(o_buttonskipandroid) { instance_create(x,y,o_buttonskipandroid) }
}

if instance_exists(o_animatedtext) {
o_animatedtext.text = loc(11)
}