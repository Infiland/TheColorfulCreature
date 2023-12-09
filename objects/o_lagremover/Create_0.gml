//instance_deactivate_all(true)

var cam,cleft,ctop,cw,ch
cam = view_camera[0]
cleft = camera_get_view_x(cam)
ctop = camera_get_view_y(cam)
cw = camera_get_view_width(cam)
ch = camera_get_view_height(cam)
instance_activate_region(cleft,ctop,cw,ch,false)
/*
instance_activate_object(o_fadecontroller)
instance_activate_object(o_pausesystem)
instance_activate_object(o_deathcounter)
instance_activate_object(o_musicdistortion)
instance_activate_object(o_timecounter)
instance_activate_object(o_time)
instance_activate_object(o_deltatime)
instance_activate_object(o_fullscreensystem)
instance_activate_object(o_foggenerator)
instance_activate_object(o_smoothcamera)
instance_activate_object(o_vignettesystem)
instance_activate_object(o_esc)
instance_activate_object(o_volumebugfix)
instance_activate_object(o_player)
instance_activate_object(o_playerdead)*/