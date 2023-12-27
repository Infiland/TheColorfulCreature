switch(global.skinselected) {
default:
draw_self()
break;
case(23):
draw_self()
if global.cheats = 1 {
draw_sprite_ext(s_forsenCDglasses,0,x+80,y+80,5,5,0,c_white,1)
}
break;
case(34):
draw_sprite_ext(s_animatedskinbase,0,x,y+(31*image_xscale),5,5,0,image_blend,1)
draw_sprite_ext(s_clockminute,0,x+(16*image_xscale),y+(16*image_xscale),5,5,-current_minute * 6,c_white,1)
draw_sprite_ext(s_clocksecond,0,x+(16*image_xscale),y+(16*image_xscale),5,5,-current_second * 6,c_white,1)
break;
case(35):
if global.visiblethings = 1 { draw_self() }
break;
case(40):
draw_sprite_ext(s_scifiskinbase,0,x+80,y+80,5,5,0,c_red,1)
draw_sprite_ext(s_scifiskineyes,1,x+(4*image_xscale),y+(14*image_yscale),5,5,0,c_red,1)
draw_sprite_ext(s_scifiskineyes,0,x+(4*image_xscale),y+(14*image_yscale),5,5,0,c_white,1)
break;
case(46):
draw_self()
draw_sprite_ext(s_maidoutfit,0,x+80,y+80,5,5,0,c_white,1)
break;
case(47):
draw_self()
draw_sprite_ext(s_fire,anim,x+80,y+80,5,5,0,c_white,1)
break;
}

scr_items()