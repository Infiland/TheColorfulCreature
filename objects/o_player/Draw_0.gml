//draw_text(x,y,global.workshopfolder)
//draw_text(x,y-10,realwalk)

//draw_text(50,50,part_particles_count(ps_redblockjump))

if jumptestdebug = true {
draw_text(x+30,y,jumptest);
draw_text(x+30,y+20,jumptest2);
}
draw_set_alpha(1)
//Breathing
draw_set_color(c_white)

if breath > 375 { 
if breath < 500 { draw_sprite(s_breathinghud,0,x,y-35) }
}
if breath > 250 { 
if breath < 376 { draw_sprite(s_breathinghud,1,x,y-35) }
}
if breath > 125 { 
if breath < 251 { draw_sprite(s_breathinghud,2,x,y-35) }
}
if breath > 40 { 
if breath < 126 { draw_sprite(s_breathinghud,3,x,y-35) }
}
if breath < 41 { draw_sprite(s_breathinghud,4,x-random_range(-3,3),y-random_range(32,38)) }

//Skins
switch(global.skinselected) {
default:
draw_self()
break;
case(17):
draw_self()
draw_sprite(s_hazardousplayerskin,image_index,x,y)
break;
case(21):
draw_sprite_ext(s_animatedskinbase,0,x,y+31,1,1*basesize,0,image_blend,1)
draw_sprite_ext(s_animatedskineyes,blinkinganimatioon,x+eyesX,(y+31)+eyesY,1,1*basesize,0,image_blend,1)
break;
case(22):
draw_self()
if zerogrv = 0 {
if vsp > -0.1 and vsp < 0.1 { draw_sprite_ext(s_underwatermask,0,x+16,y+16,1,1,image_angle,c_white,1) }
if vsp < -0.1  { draw_sprite_ext(s_underwatermask,1,x+16,y+16,1,1,image_angle,c_white,1) }
if vsp > 0.1 { draw_sprite_ext(s_underwatermask,2,x+16,y+16,1,1,image_angle,c_white,1) }
} else { draw_sprite_ext(s_underwatermask,1,x,y,1,1,image_angle,c_white,1) }
break;
case(23):
if global.cheats = 1 {
draw_self()
draw_sprite_ext(s_forsenCDglasses,image_index,x+16-(zerogrv*16),y+16-(zerogrv*16),1,1,image_angle,c_white,1)
} else { draw_self() }
break;
case(24):
draw_sprite_ext(s_redballplayerskin,image_index,x + xchange ,y + ychange,1,1,rotation,image_blend,1)
break;
case(25):
draw_self()
lightbomberframe += 0.1 * (60 / global.maxfps)
if lightbomberframe > 4 { lightbomberframe = 0 }
if zerogrv = 0 {
if hsp = 0 {
	draw_sprite(s_bomberoutfit,0,x,y) 
	draw_sprite(s_bomberlight,lightbomberframe,x+10,y+23)
	}
if hsp < 0  { 
	draw_sprite(s_bomberoutfit,1,x,y)
	draw_sprite(s_bomberlight,lightbomberframe,x+5,y+21)
	}
if hsp > 0 { 
	draw_sprite(s_bomberoutfit,2,x,y)
	draw_sprite(s_bomberlight,lightbomberframe,x+17,y+23)
	}} else {
	draw_sprite(s_bomberoutfit,0,x-16,y-16) 
	draw_sprite(s_bomberlight,lightbomberframe,x-6,y+7)
	}
break;
case(28):
draw_self()
draw_sprite_ext(s_monocleglassesoutfit,image_index,x+16-(zerogrv*16),y+16-(zerogrv*16),1,1,image_angle,c_white,1)
break;
case(30):

var _xx = lengthdir_x(6,image_angle+90)
var _yy = lengthdir_y(6,image_angle+90)

draw_sprite_ext(s_animatedskinbase,0,x-(zerogrv*16),y+31-(zerogrv*16),1,1,0,image_blend,1)
draw_sprite_ext(s_googlyeye,0,x+9+eyesX-(zerogrv*16)+(_xx*zerogrv),y+16+eyesY-(zerogrv*16)+(_yy*zerogrv),1,1*basesize,image_angle + (googlyeyesrotreal + randomeeyerotationR),c_white,1)
draw_sprite_ext(s_googlyeye,0,x+22+eyesX-(zerogrv*16)+(_xx*zerogrv),y+16+eyesY-(zerogrv*16)+(_yy*zerogrv),1,1*basesize,image_angle + (googlyeyesrotreal + randomeeyerotationL) ,c_white,1)
break;
case(32):
spiraleyerot += (4 * (60 / global.maxfps)) * (walksp / 4)
if spiraleyerot > 7200 { spiraleyerot = 0 }
draw_sprite_ext(s_animatedskinbase,0,x,y+31,1,1,0,image_blend,1)
draw_sprite_ext(s_spiraleye,0,x+9+eyesX,y+16+eyesY,1,1,spiraleyerot,image_blend,1)
draw_sprite_ext(s_spiraleye,0,x+22+eyesX,y+16+eyesY,1,1,180+spiraleyerot,image_blend,1)
break;
case(33):
heartbump -= (1 * (60 / global.maxfps))
if distance_to_object(o_door) < heartbump { heartbump = distance_to_object(o_door) / 1.5 }
if heartbump < 0 { 
	hearteyeincrease = 1.3
	if instance_exists(o_door) {
heartbump = distance_to_object(o_door) / 1.5
} else { heartbump = 120 }
	}
hearteyeincrease = lerp(hearteyeincrease,1,0.1 *(60 / global.maxfps))
draw_sprite_ext(s_animatedskinbase,0,x,y+31,1,1,0,image_blend,1)
draw_sprite_ext(s_hearteye,0,x+9+eyesX,y+16+eyesY,1 * hearteyeincrease,1 * hearteyeincrease,0,image_blend,1)
draw_sprite_ext(s_hearteye,0,x+22+eyesX,y+16+eyesY,1 * hearteyeincrease,1 * hearteyeincrease,0,image_blend,1)
break;
case(34):
draw_circle_color(x+15,y+15,15.5,image_blend,image_blend/2,false)
draw_sprite_ext(s_clockborder,0,x,y,1,1,0,image_blend,1)
draw_sprite_ext(s_clockminute,0,x+16,y+16,1,1,-current_minute * 6,c_white,1)
draw_sprite_ext(s_clocksecond,0,x+16,y+16,1,1,-current_second * 6,c_white,1)
break;
case(35):
//Invisible Skin
break;
case(39):
draw_self()
draw_sprite_ext(s_pirateeyepatch,image_index,x+16-(zerogrv*16),y+16-(zerogrv*16),1,1,image_angle,c_white,1)
break;
case(40):
draw_sprite_ext(s_scifiskinbase,0,x+16-(zerogrv*16),y+16-(zerogrv*16),1,1,image_angle,image_blend,1)
draw_sprite_ext(s_scifiskineyes,1,x+4+eyesX-(zerogrv*16),y+14+eyesY-(zerogrv*16),1,1,0,image_blend,1)
draw_sprite_ext(s_scifiskineyes,0,x+4+eyesX-(zerogrv*16),y+14+eyesY-(zerogrv*16),1,1,0,c_white,1)
break;
case(41):
draw_self()
if zerogrv = 0 {
if hsp = 0 { draw_sprite(s_hevsuitoutfit,0,x+16,y+16) }
if hsp < 0 { draw_sprite(s_hevsuitoutfit,1,x+16,y+16) }
if hsp > 0 { draw_sprite(s_hevsuitoutfit,2,x+16,y+16) }
} else { draw_sprite_ext(s_hevsuitoutfit,0,x,y,1,1,image_angle,c_white,1) }
break;
case(42):
draw_self()
if zerogrv = 0 {
if hsp = 0 { draw_sprite(s_fancyoutfit,0,x+16,y+16) }
if hsp < 0 { draw_sprite(s_fancyoutfit,1,x+16,y+16) }
if hsp > 0 { draw_sprite(s_fancyoutfit,2,x+16,y+16) }
} else { draw_sprite_ext(s_fancyoutfit,0,x,y,1,1,image_angle,c_white,1) }
break;
case(46):
draw_self()
if zerogrv = 0 {
if hsp = 0 { draw_sprite(s_maidoutfit,0,x+16,y+16) }
if hsp < 0 { draw_sprite(s_maidoutfit,1,x+16,y+16) }
if hsp > 0 { draw_sprite(s_maidoutfit,2,x+16,y+16) }
} else { draw_sprite_ext(s_maidoutfit,0,x,y,1,1,image_angle,c_white,1) }
break;
case(47):
draw_self()
if zerogrv = 0 {
	draw_sprite(s_fire,global.time * 30,x+16,y+16)
} else {
draw_sprite_ext(s_fire,global.time * 30,x,y,1,1,image_angle,c_white,1) }
break;
}


//Hats
scr_hats()

//Items
scr_items()