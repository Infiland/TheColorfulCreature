function scr_activateobjects(){
if global.pause = 1 { exit }
if global.biglevelperfsettings = 0 { exit }
var cam;
cam = view_camera[0]

instance_activate_region(x-100,y-100,x+100,y+100,true)
}