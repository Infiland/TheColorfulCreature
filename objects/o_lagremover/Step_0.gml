var cam,cleft,ctop,cw,ch
cam = view_camera[0]
cleft = camera_get_view_x(cam)
ctop = camera_get_view_y(cam)
cw = camera_get_view_width(cam)
ch = camera_get_view_height(cam)
instance_activate_region(cleft,ctop,cw,ch,false)