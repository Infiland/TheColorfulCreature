//Get Player Input

/*if !audio_is_playing(snd_troopattack6) {
audio_play_sound_at(snd_troopattack6,x-mouse_x,y-mouse_y,0,100,100,100,0,1)
}*/

if global.pause = 1{ 
	scr_playercontrolsconfig()
	speed = 0
	exit }
if os_type != os_android {
//Left
if leftcontrols = 0 {
key_left = (gamepad_axis_value(0,gp_axislh) < -0.2 || gamepad_button_check(0,gp_padl)) || keyboard_check(ord(global.controlsmoveleft))
}
if leftcontrols = 1 {
key_left = (gamepad_axis_value(0,gp_axislh) < -0.2 || gamepad_button_check(0,gp_padl)) || keyboard_check(global.controlsmoveleft)
}
//Right
if rightcontrols = 0 {
key_right = (gamepad_axis_value(0,gp_axislh) > 0.2 || gamepad_button_check(0,gp_padr)) || keyboard_check(ord(global.controlsmoveright));
}
if rightcontrols = 1 {
key_right = (gamepad_axis_value(0,gp_axislh) > 0.2 || gamepad_button_check(0,gp_padr)) || keyboard_check(global.controlsmoveright);
}
//Jump
if doublejump = 0 {
if jumpcontrols = 0 { key_jump = (gamepad_button_check(0,gp_face1)) || keyboard_check(ord(global.controlsjump)) }
else { key_jump = (gamepad_button_check(0,gp_face1)) || keyboard_check(global.controlsjump) }
} else {
if jumpcontrols = 0 { key_jump = (gamepad_button_check_pressed(0,gp_face1)) || keyboard_check_pressed(ord(global.controlsjump)) }
else { key_jump = gamepad_button_check_pressed(0,gp_face1) || keyboard_check_pressed(global.controlsjump) }
}


//Interact
if interactcontrols = 0 {
key_interact = keyboard_check_pressed(ord(global.controlsinteract)) || (gamepad_button_check_pressed(0,gp_shoulderrb)) //|| keyboard_check_pressed(ord("S"));
} else { key_interact = keyboard_check_pressed(global.controlsinteract) || (gamepad_button_check_pressed(0,gp_shoulderrb)) }
//Interact Hold
if interactcontrols = 0 {
key_interact_h = keyboard_check(ord(global.controlsinteract)) || (gamepad_button_check(0,gp_shoulderrb)) //|| keyboard_check_pressed(ord("S"));
} else { key_interact_h = keyboard_check(global.controlsinteract) || (gamepad_button_check(0,gp_shoulderrb)) }
//Restart
if restartcontrols = 0 { key_restart = keyboard_check(ord(global.controlsrestart)) || (gamepad_button_check(0,gp_shoulderlb)) } else { key_restart = keyboard_check(global.controlsrestart) || (gamepad_button_check(0,gp_shoulderlb)) }
} else {
if instance_exists(o_buttonleftandroid) { key_left = o_buttonleftandroid.image_index = 1; }
if instance_exists(o_buttonrightandroid) { key_right = o_buttonrightandroid.image_index = 1; }
if instance_exists(o_buttonjumpandroid) { key_jump = o_buttonjumpandroid.image_index = 1; }
if instance_exists(o_buttoninteractandroid) {key_interact = o_buttoninteractandroid.image_index = 1; }
if instance_exists(o_buttoninteractandroid) { key_interact_h = o_buttoninteractandroid.image_index = 1; }
if instance_exists(o_buttonrestartandroid) { key_restart = o_buttonrestartandroid.image_index = 1; }
}

if global.noclip = 1 {
if keyboard_check(vk_right) || keyboard_check(ord("D")) { x += walksp * (60 / global.maxfps) }
if keyboard_check(vk_left) || keyboard_check(ord("A")) { x -= walksp * (60 / global.maxfps) }
if keyboard_check(vk_up) || keyboard_check(ord("W")) { y -= walksp * (60 / global.maxfps) }
if keyboard_check(vk_down) || keyboard_check(ord("S")) { y += walksp * (60 / global.maxfps) }
}


if instance_exists(o_hatshopmenu) { exit }


if key_restart {
if global.pause = 0 {
if room != r_theend || room != r_easteregg1 {
if room != r_leveleditor {
	increase_stat("totalrestartdeaths","QUESTrestartdeaths",1)
	}
death()
}}}

//Restart Challenge
if keyboard_check(vk_control) {
	if key_restart {
	restartchallenge()	
}}

//Water
if place_meeting(x,y,o_water) { inwater = 2 } else { inwater = 1 }
if inwater = 2 { 
	if global.musicdistortionsettings = 1 {
	global._ef_water.cutoff = lerp(global._ef_water.cutoff,500,0.05);
	global._ef_gain.gain = lerp(global._ef_gain.gain,0.5*(breath/500),0.05);
	}
	breath -= 1 * (60 / global.maxfps)
	if breath < 0 {
		increase_stat("totalwaterdeaths","QUESTwaterdeaths",1)
		death() }
	} else { breath += 3 * (60 / global.maxfps)
	if breath > 500 { breath = 500 }
	global._ef_water.cutoff = lerp(global._ef_water.cutoff,20000,0.05);
	global._ef_gain.gain = lerp(global._ef_gain.gain,1,0.03);
		}
//Sound Manipultation
if passblockcooldown > -1 { passblockcooldown -= 1 }
if grv = 0.83 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,1.25)	}
if grv = 0.5 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,1)	}
if grv = 0.172 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,0.8)	}
if grv = 0.027 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,0.7)	}

if zerogrv = 0 {

//Calculate Movement
var move = key_right - key_left;
if onice = true {
var move = global.playermove
} else { var move = key_right - key_left }

if key_right or key_left {
if onice = true {
	if realwalk < walksp {
	realwalk += 0.05 * (60 / global.maxfps)
	} else { realwalk = walksp }
} else {
	realwalk = walksp

}}


if !key_right and !key_left {
		if onice = true {
			if realwalk > 0 {
	realwalk -= 0.05 * (60 / global.maxfps)
		} else { realwalk = 0 }
	} else { realwalk = 0}
}
if key_right and key_left {
		if onice = true {
		if realwalk > 0 {
	realwalk -= 0.05 * (60 / global.maxfps)
		} else { realwalk = 0 }
	} else { realwalk = 0 }	
}
if global.writingmode = 0 {
hsp = (((move * realwalk) + hspzerogrv) / inwater) * (60 / global.maxfps)
}
if move = 0 { 
	if onice = false {
	realwalk = 0 
	} else {
	if realwalk > 0 {
		realwalk -= 0.05 * (60 / global.maxfps)
	}
	}}

vsp = (vsp + ((grv * (60 / global.maxfps))/inwater))

if place_meeting(x,y+1,o_anyblock) {onice = false}
if place_meeting(x,y+1,o_iceblock) {onice = true}
if place_meeting(x,y+1,o_redblockmove) {onice = false}
if place_meeting(x,y+1,o_yellowblockmove) {onice = false}
if place_meeting(x,y+1,o_greenblockmove) {onice = false}
if place_meeting(x,y+1,o_blueblockmove) {onice = false}
if place_meeting(x,y+1,o_whiteblockmove) {onice = false}
if place_meeting(x,y+1,o_shooter) {onice = false}
if place_meeting(x,y+1,o_shooterright) {onice = false}
if place_meeting(x,y+1,o_rocketlauncher) {onice = false}
if place_meeting(x,y+1,o_rocketlauncherright) {onice = false}
if place_meeting(x,y+1,o_onewayupblock) {onice = false}

if onice = false {
	hspzerogrv = 0
}

//Particles (Left/Right)

if global.playerpar > 1 {
par_walktimer -= 1 * (60 / global.maxfps)
if par_walktimer < 0 {
if key_right || key_left {
if place_meeting(x,y+1,o_anyblock) {
//par_walk = instance_create(x+14,y+27,o_parwalk)
//var par = part_system_create(ps_redblockrunleft)
//if key_left { var par = part_system_create(ps_redblockrunleft) }
//if key_right { var par = part_system_create(ps_redblockrunright) }
/*part_system_create(ps_redblockrunleft)
part_system_position(ps_redblockrunleft,x+16,y+32)*/
par_walktimer = 10
}}}

}

if global.managablejump = 1 {
if (gamepad_button_check_released(0,gp_face1)) || keyboard_check_released(ord(global.controlsjump)) &&  vsp <= 0 {
//vsp = lerp(vsp,0,0.15)
vsp = 0
}}

if coyotetime > 0 and (key_jump) and vsp != 0 { jump() }
if (place_meeting(x,y+1,o_anyblock)) and (key_jump) {jump()}
if (place_meeting(x,y+2,o_redblockslope)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_redblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_yellowblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_greenblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_blueblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_whiteblockmove)) and (key_jump) {jump()}
if vsp > 0 {
if (place_meeting(x,y+1,o_onewayupblock)) and (key_jump) { {jump()} }
}
if (place_meeting(x,y+1,o_iceblock)) and (key_jump) {jump()}
if (place_meeting(x,y,o_ladder)) and (key_jump) { 
	vsp = -3
	onice = false
	if !audio_is_playing(snd_ladder) {
	audio_play_sound(snd_ladder,0,0)
	}
	}

if jumptestdebug = true {
if !(place_meeting(x,y+1,o_anyblock)) { jumptest += 1 * (60 / global.maxfps) } else {
if jumptest > jumptest2 {
jumptest2 = jumptest
}
jumptest = 0
}}
	
//Sound Jumping
if global.noclip = 0 {
if global.writingmode = 0 {
if (place_meeting(x,y+1,o_anyblock)) || (place_meeting(x,y+1,o_redblockmove)) || (place_meeting(x,y+1,o_yellowblockmove)) || (place_meeting(x,y+1,o_greenblockmove)) || (place_meeting(x,y+1,o_blueblockmove)) || (place_meeting(x,y+1,o_whiteblockmove))  || (place_meeting(x,y+1,o_shooter)) || (place_meeting(x,y+1,o_rocketlauncherright)) || (place_meeting(x,y+1,o_rocketlauncher)) || (place_meeting(x,y+1,o_shooterright)) || (place_meeting(x,y+1,o_onewayupblock)) {
if (key_jump) {
if !place_meeting(x,y,o_onewayupblock) {
if !place_meeting(x,y,o_onewaydownblock) {
audio_sound_pitch(snd_jump,random_range(0.9,1.1));
audio_sound_gain(snd_jump,global.soundvolume,1)	
audio_play_sound(snd_jump,10,0)
}}}}}

	if hsp < 0 {
	if (place_meeting(x+hsp,y,o_onewayrightblock)) {
	    while (!place_meeting(x+sign(hsp),y,o_onewayrightblock))
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}}
	if hsp > 0 {
	if (place_meeting(x+hsp,y,o_onewayleftblock)) {
	    while (!place_meeting(x+sign(hsp),y,o_onewayleftblock))
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}}

//Horizontal Collision

horizontalcollision()
x = x + hsp

//Vertical Collision

/*
	if (place_meeting(x,y+vsp,o_redblockslope)) { //Test
	    while (!place_meeting(x,y+sign(vsp),o_redblockslope)) 
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}*/
verticalcollision(o_redblockslope)
verticalcollision(o_anyblock)
verticalcollision(o_movingplatforms,1)
verticalcollision(o_shooter)
verticalcollision(o_shooterright)
verticalcollision(o_rocketlauncher)
verticalcollision(o_rocketlauncherright)
verticalcollision(o_onewayupblock)
verticalcollision(o_onewaydownblock)
verticalcollision(o_playerMU)

coyotetime -= 0.03

y = y + vsp

//move_and_collide(hsp,0,o_redblockslope,20)

if vsp > 30 * (global.maxfps / 60) { vsp = 30 * (global.maxfps / 60) }
}

//Animation
if global.skinselected != 23 {
if vsp < -0.3 and !hsp  { image_index = 6 } //Jump
if vsp > 0.3 and !hsp  { image_index = 3 } //Fall
if key_right and vsp = 0 { image_index = 1 } //Moving right without jumping
if key_right and vsp < -0.3 { image_index = 7 } //Jumping right
if key_right and vsp > 0.3 { image_index = 4 } //Falling right
if key_left and vsp = 0 { image_index = 2 } //Moving left without jumpin
if key_left and vsp < -0.3 { image_index = 8 } //Jumping left
if key_left and vsp > 0.3 { image_index = 5 } //Falling left
if key_right and key_left and vsp > 0.3 { image_index = 3 } //Falling while pressing left and right
if key_right and key_left and vsp < -0.3 { image_index = 6 } //Jumping while pressing left and right
if key_right and key_left and vsp = 0 { image_index = 0 } //Pressing left and right
}
if key_right { global.playermove = 1 }
if key_left { global.playermove = -1 }

} else { //ZERO GRAVITY
image_index = 6

if key_right { direction -= 3 * (60 / global.maxfps) }
if key_left { direction += 3 * (60 / global.maxfps) }
if key_jump {
if !key_interact_h {
	if speed < walksp / (3 * (global.maxfps / 144)) {
	speed += walksp / (40 * (global.maxfps / 60)) } }}
		if speed > 0 {
		if key_interact_h {
			speed -= 0.05 * (60 / global.maxfps)
		}
		speed -= 0.01 * (60 / global.maxfps) } else { speed = 0 }

var col = instance_place(x, y, o_anyblock);
if (col > -1) {
    dir = point_direction(col.x+16, col.y+16, x, y);
    x += lengthdir_x(speed*2, dir);
    y += lengthdir_y(speed*2, dir);
}
image_angle = direction - 90 //EXIT ZERO G
//vsp = (vspeed * speed) * (global.maxfps / 144)
//hspzerogrv = (hspeed * speed) * (global.maxfps / 144)
vsp = vspeed * (global.maxfps / 60)
hspzerogrv = hspeed * (global.maxfps / 60)
}

if y > room_height - 30 {
	death()
	increase_stat("totalvoiddeaths","QUESTvoiddeaths",1)
}

//Jumps (Optimized Code)

	if instance_exists(o_buttonjumpandroid) {
if o_buttonjumpandroid.press = 1 and (doublejump = 1) and (key_jump) {
jump()
}} else {
	if (doublejump > 0) and (key_jump) {
	jump()
	}}
	
//Colors (AND SKINS)
switch(global.skinselected) {
case 4:
if global.playerpar > 0 {
if global.deaths > 0 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 1 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 3 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 5 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 10 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 25 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 50 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 100 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 150 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 250 {tearcooldown -= random_range(0.01,0.1)}
if global.deaths > 500 {tearcooldown -= random_range(0.01,0.1)}
if tearcooldown < 0 {
instance_create(x+random_range(8,22),y+18,o_playertear)
tearcooldown = 5 * (global.maxfps / 60)
}}
break;
case 10:
scr_playerrbg()
break;
case 12:
goldcooldown = irandom_range(0,10)
	if global.playerpar > 0 {
	if goldcooldown = 0 {
var star = instance_create(x+12,y+14,o_itemstar);
with star { image_blend = c_yellow }
}}
break;
case 14:
scr_playerrbgnormal()
break;
case 21:
scr_playerrbg()
if vsp = 0 {
eyesY = lerp(eyesY,0,0.2 * (60 / global.maxfps))
}
if vsp < 0 {
eyesY = lerp(eyesY,-7,0.2 * (60 / global.maxfps))
}
if vsp > 0 {
eyesY = lerp(eyesY,7,0.2 * (60 / global.maxfps))
}
if hsp != 0 {
if global.playermove = 1 {
eyesX = lerp(eyesX,6,0.2 * (60 / global.maxfps))
}
if global.playermove = -1 {
eyesX = lerp(eyesX,-6,0.2 * (60 / global.maxfps))
}
if changesizeanimated = 0 {
if basesize < 1.1 {
basesize = lerp(basesize,0.92,0.1 * (60 / global.maxfps))
if basesize < 0.93 {
changesizeanimated = 1
}
}}

if changesizeanimated = 1 {
if basesize > 0.92 {
basesize = lerp(basesize,1.01,0.1 * (60 / global.maxfps))
if basesize > 1 {
changesizeanimated = 0
}
}}
}
if hsp = 0 {
eyesX = lerp(eyesX,0,0.2 * (60 / global.maxfps))
basesize = lerp(basesize,1,0.1 * (60 / global.maxfps))
changesizeanimated = 0
}
randomblinking -= 1
if randomblinking < 0 {
blinkinganimatioon += 0.33 * (60 / global.maxfps)
if blinkinganimatioon > 9 {
blinkinganimatioon = 0
randomblinking = irandom_range(250,450)	
}}
break;
case 22: scr_playerrbgnormal() break;
case 23:
if key_right { image_index = 0 }
if key_left {image_index = 1 }
scr_playerrbgnormal()
break;
case 24:
if key_right { rotation -= realwalk }
if key_left {rotation += realwalk }
scr_playerrbgnormal()
case 26: scr_playerrbgnormal() break;
case 27: scr_playerrbgnormal() break;
case 28: scr_playerrbgnormal() break;
case 29: scr_playerrbgnormal() break;
case 30:
scr_playerrbgnormal()
scr_animatedeyes()

if vsp < -0.3 and !hsp  { googlyeyesrot = 0 } //Jump
if vsp > 0.3 and !hsp  { googlyeyesrot = 180 } //Fall
if key_right and vsp = 0 { googlyeyesrot = 270 } //Moving right without jumping
if key_right and vsp < -0.3 { googlyeyesrot = 315 } //Jumping right
if key_right and vsp > 0.3 { googlyeyesrot = 225 } //Falling right
if key_left and vsp = 0 { googlyeyesrot = 90 } //Moving left without jumpin
if key_left and vsp < -0.3 { googlyeyesrot = 35 } //Jumping left
if key_left and vsp > 0.3 { googlyeyesrot = 135 } //Falling left
if key_right and key_left and vsp > 0.3 { googlyeyesrot = 180 } //Falling while pressing left and right
if key_right and key_left and vsp < -0.3 { googlyeyesrot = 0 } //Jumping while pressing left and right
if key_right and key_left and vsp = 0 { googlyeyesrot = 0 } //Pressing left and right
googlyeyesrotreal = lerp(googlyeyesrotreal,googlyeyesrot,0.25 * (60 / global.maxfps))
if keyboard_check_pressed(vk_anykey) {
randomeeyerotationR = lerp(randomeeyerotationR,random_range(-360,360),0.2 * (60 / global.maxfps))
randomeeyerotationL = lerp(randomeeyerotationL,random_range(-360,360),0.2 * (60 / global.maxfps))	
}
break;
case 31: scr_playerrbgnormal() break;
case 32:
scr_playerrbgnormal()
scr_animatedeyes()
break;
case 33:
scr_playerrbgnormal()
scr_animatedeyes()
break;
case 34: scr_playerrbgnormal() break;
case 36: scr_playerrbgnormal() break;
case 37: scr_playerrbgnormal() break;
case 38: scr_playerrbgnormal() break;
case 39: scr_playerrbgnormal() break;
case 40: scr_playerrbg()
scr_animatedeyes()
break;
case 41: scr_playerrbgnormal() break;
case 42: scr_playerrbgnormal() break;
case 43: scr_playerrbgnormal() break;
case 44: scr_playerrbgnormal() break;
case 45: scr_playerrbgnormal() break;
case 46: scr_playerrbgnormal() break;
case 48: scr_playerrbgnormal() break;
case 49: scr_playerrbgnormal()
scr_animatedeyes() break;
}
if global.color = 4 { 
	if global.playerpar > 0 {
	if whiteplayer = 0 {
	instance_create(x+12,y+14,o_whitecircleeffect);	
	whiteplayer = 1
	}}}
//Wrap Script
if place_meeting(x,y,o_blockwrapleft) {
x = room_width;
}
if place_meeting(x,y,o_blockwrapright){
x = -32
}
//Teleporter
if teleportcooldown >= 0 {
if !place_meeting(x,y,o_portalpurpleclosed) {
if !place_meeting(x,y,o_portalpurpleopen) {
teleportcooldown -= 1 * (60 / global.maxfps)
}}}
if teleportcooldown < 0 {
if place_meeting(x,y,o_portalpurpleopen) {
portallast = 0	
}
if place_meeting(x,y,o_portalpurpleclosed) {
portallast = 1
}
}
if teleportcooldown <= 0 {
if portallast = 0 {	
if place_meeting(x,y,o_portalpurpleopen) {
if instance_exists(o_portalpurpleclosed) {
teleportcooldown = 15
if global.itempar = 1 {
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar)
with star { image_blend = c_fuchsia }}
}
audio_sound_pitch(snd_portal,random_range(0.9,1.1));
audio_play_sound(snd_portal,10,0)
x = o_portalpurpleclosed.x + (zerogrv * 16)
y = o_portalpurpleclosed.y + (zerogrv * 16)
if room != r_leveleditor {
increase_stat("totalportal","QUESTportal",1)
}
}}}
if place_meeting(x,y,o_portalpurpleclosed) {
if portallast = 1 {		
if instance_exists(o_portalpurpleopen) {
teleportcooldown = 15
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar)
with star { image_blend = c_fuchsia }}
audio_sound_pitch(snd_portal,random_range(0.9,1.1));
audio_play_sound(snd_portal,10,0)
x = o_portalpurpleopen.x + (zerogrv * 16)
y = o_portalpurpleopen.y + (zerogrv * 16)
if room != r_leveleditor {
increase_stat("totalportal","QUESTportal",1)
}
}}}}

//Gun
if place_meeting(x,y,o_gunequipped) {
if key_interact {
if instance_exists(o_buttoninteractandroid) {
if o_buttoninteractandroid.press = 0 { exit }
}
if inwater = 1 {
if global.gunammo > 0 {
instance_destroy(o_lastshotplayer)
instance_create(x+16,y+16,o_lastshotplayer)
if room != r_leveleditor {
	increase_stat("totalgunshots","QUESTgunshots",1)
	}
if zerogrv = 0 {
if global.playermove = -1 {
instance_create(x,y+12,o_playerbullet)
}
if global.playermove = 1 {
instance_create(x+30,y+12,o_playerbullet)
}
if global.playermove = 0 {
instance_create(x+25,y+12,o_playerbullet)
image_index = 1
}} else { instance_create(x,y,o_playerbullet) }
if global.gunammoinfinite = false { global.gunammo -= 1 }
}
if global.gunammo < 1 {
audio_play_sound(snd_noammo,0,0)
}
} else { audio_play_sound(snd_noammo,0,0) }
}}
if instance_exists(o_gunequipped) {
if key_right { o_gunequipped.timer = 0 }	
if key_left { o_gunequipped.timer = 0 }
}

//Death Triggers
if global.easy = 0 {
if global.color != 4 {

//RED DEATH
if global.color != 0 {
if !place_meeting(x,y-1,o_yellowblock) and !place_meeting(x,y+1,o_yellowblock) and !place_meeting(x,y-1,o_greenblock) and !place_meeting(x,y+1,o_greenblock) and !place_meeting(x,y-1,o_blueblock) and !place_meeting(x,y+1,o_blueblock) {
if place_meeting(x-10,y-10,o_redblockmove) || place_meeting(x+1,y+2,o_redblockmove) || place_meeting(x+1,y+1,o_redblock) || place_meeting(x-1,y+1,o_redblock) || place_meeting(x+1,y-1,o_redblock) || place_meeting(x-1,y-1,o_redblock) {
	blockdeath()
}}
if hsp = 0 {
if place_meeting(x+1,y,o_redblock) || place_meeting(x-1,y,o_redblock) {
blockdeath()
}}
if passblockcooldown < 1 {
if place_meeting(x,y,o_redpassblock) { blockdeath() }
}

}


//YELLOW DEATH
if global.color != 1 {
if !place_meeting(x,y-1,o_redblock) and !place_meeting(x,y+1,o_redblock) and !place_meeting(x,y-1,o_greenblock) and !place_meeting(x,y+1,o_greenblock) and !place_meeting(x,y-1,o_blueblock) and !place_meeting(x,y+1,o_blueblock) {
if place_meeting(x-10,y-10,o_yellowblockmove) || place_meeting(x+1,y+2,o_yellowblockmove) || place_meeting(x-1,y-1,o_yellowblock) || place_meeting(x+1,y+1,o_yellowblock) || place_meeting(x-1,y+1,o_yellowblock) || place_meeting(x+1,y-1,o_yellowblock) {
blockdeath() 
}}

if hsp = 0 {
if place_meeting(x+1,y,o_yellowblock) || place_meeting(x-1,y,o_yellowblock) {
blockdeath()
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_yellowpassblock) { blockdeath() }
}}


//GREEN DEATH
if global.color != 2 {
if !place_meeting(x,y-1,o_yellowblock) and !place_meeting(x,y+1,o_yellowblock) and !place_meeting(x,y-1,o_redblock) and !place_meeting(x,y+1,o_redblock) and !place_meeting(x,y-1,o_blueblock) and !place_meeting(x,y+1,o_blueblock) {
if place_meeting(x-10,y-10,o_greenblockmove) || place_meeting(x+1,y+2,o_greenblockmove) || place_meeting(x-1,y-1,o_greenblock) || place_meeting(x+1,y+1,o_greenblock) || place_meeting(x-1,y+1,o_greenblock) || place_meeting(x+1,y-1,o_greenblock) {
blockdeath() 
}}

if hsp = 0 {
if place_meeting(x+1,y,o_greenblock) || place_meeting(x-1,y,o_greenblock) {
blockdeath()
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_greenpassblock) { blockdeath() }
}}

//BLUE DEATH
if global.color != 3 {
if !place_meeting(x,y-1,o_yellowblock) and !place_meeting(x,y+1,o_yellowblock) and !place_meeting(x,y-1,o_greenblock) and !place_meeting(x,y+1,o_greenblock) and !place_meeting(x,y-1,o_redblock) and !place_meeting(x,y+1,o_redblock) {
if place_meeting(x-10,y-10,o_blueblockmove) || place_meeting(x+1,y+2,o_blueblockmove) || place_meeting(x-1,y-1,o_blueblock) || place_meeting(x+1,y+1,o_blueblock) || place_meeting(x-1,y+1,o_blueblock) || place_meeting(x+1,y-1,o_blueblock) {
blockdeath() 
}}

if hsp = 0 {
if place_meeting(x+1,y,o_blueblock) || place_meeting(x-1,y,o_blueblock) {
blockdeath()
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_bluepassblock) { blockdeath() }
}}

//WHITE
if passblockcooldown < 1 {
if place_meeting(x,y,o_whitepassblock) {
blockdeath() 
}}

}

//Other Deaths
if place_meeting(x,y,o_hazard) {death()}
if instance_exists(o_lockedblock) {
if o_lockedblock.sprite_index = s_lockedblock {
if place_meeting(x,y,o_lockedblock) { blockdeath() }
}}
if instance_exists(o_unlockedblock) {
if o_unlockedblock.sprite_index = s_lockedblock {
if place_meeting(x,y,o_unlockedblock) { blockdeath() }
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_gravitylimit01) { 
if grv != 0.027 {
	blockdeath() 
	}}
if place_meeting(x,y,o_gravitylimit05) { 
if grv != 0.172 {
	blockdeath() 
	}}
if place_meeting(x,y,o_gravitylimit15) { 
if grv != 0.5 {
	blockdeath() 
	}}
if place_meeting(x,y,o_gravitylimit25) { 
if grv != 0.83 {
	blockdeath() 
	}}
if place_meeting(x,y,o_zerogravitylimit) { 
if zerogrv = 0 {
	blockdeath()
}}}

if place_meeting(x,y,o_speedlimit5) { 
if walksp != 2.8 {
	blockdeath() 
	}}
if place_meeting(x,y,o_speedlimit7) { 
if walksp != 4 {
	blockdeath() 
	}}
if place_meeting(x,y,o_speedlimit10) { 
if walksp != 5.5 {
	blockdeath() 
	}}
if place_meeting(x,y,o_speedlimit15) { 
if walksp != 8.5 {
	blockdeath() 
	}}
}

//Next Level
if room != r_leveleditor {
if place_meeting(x,y+3,o_door) {
	if global.wheelmultiplier < 3 {
	global.wheelmultiplier += 0.01
	}
if global.dailylevel = 0 {
if global.endless = 0 {
global.pickup = 0
scr_loadsettings()
increase_stat("totallevelcompleted","QUESTlevelcompleted",1)

if room = asset_get_index("r_lvl" + string(global.worldProgression)) {
global.worldProgression += 1
}

scr_savestats()

room_goto_next()
if global.challenges = 0 {
global.wheeltimeleft -= 20
} else { global.wheeltimeleft -= 10 }
scr_resetcheckpointdata()
if global.hardmodedifficulty = 6 { 
	global.timeleftHM += 10 + (global.time / 90)
	}
if global.hardmodedifficulty = 7 {
	global.timeleftHM += 8 + (global.time / 80)
	}
if global.hardmode = 0 {
if global.challenges = 0 {
scr_savegame()
}
}
} else {
	var highscorepitch = 1
	randomlevel()
	increase_stat("totallevelcompleted","QUESTlevelcompleted",1)
	global.endlesslevel += 1
	if global.cheats = 0 {
	if global.endlessrunmode != 3 {
	if global.endlesslevel = 20 { steam_upload_score("Endless Run 20L", global.time * 1000)}
	if global.endlesslevel = 50 { steam_upload_score("Endless Run 50L", global.time * 1000)}
	}}
	scr_checkachievements()
	if global.endlessrunmode = 1 {
	if global.endlesslevel > global.newendlesslevelhighscore { 
		highscorepitch = (global.endlesslevel - 1) / global.newendlesslevelhighscore
		if highscorepitch > 1.6 { highscorepitch = 1.6 }
		audio_sound_pitch(snd_newhighscore,highscorepitch)
		audio_play_sound(snd_newhighscore,10,0) }}
	if global.endlessrunmode = 2 {
		highscorepitch = (global.endlesslevel - 1) / global.endlesslevelhighscore
		if highscorepitch > 1.6 { highscorepitch = 1.6 }
		audio_sound_pitch(snd_newhighscore,highscorepitch)
	if global.endlesslevel > global.endlesslevelhighscore { audio_play_sound(snd_newhighscore,10,0) }}
		
	}} else {
		increase_stat("totallevelcompleted","QUESTlevelcompleted",1)
		room_goto(r_dailylevelwin)
		window_set_cursor(cr_default)
		global.dailylevel = 0
		audio_stop_all()
		audio_play_sound(m_goodending,0,1)
	}
if global.calendar = 1 {
	
	switch(global.calendarday - (7 * (global.calendarweek - 1))) {
	case(1): global.calendarday1required = 1 break;
	case(2): global.calendarday2required = 1 break;
	case(3): global.calendarday3required = 1 break;
	case(4): global.calendarday4required = 1 break;
	case(5): global.calendarday5required = 1 break;
	case(6): global.calendarday6required = 1 break;
	case(7): global.calendarday7required = 1 break;
	}
	
	scr_saverewardscalendar()
	scr_checkcalendarrewards(global.calendarmonth,global.calendarweek)
	
	global.calendarday++
		
	if global.calendarday > 7 {
	global.calendarweek = 2
	}
	if global.calendarday > 14 {
	global.calendarweek = 3
	}
	if global.calendarday > 21 {
	global.calendarweek = 4
	}
	if global.calendarday > 28 {
	global.calendarweek = 1
	global.calendarday = 1
	global.calendarmonth += 1
	calendarcheckmusic()
	}
	
	scr_loadrewardscalendar()
	
	if steam_get_app_id() = 1749610 {
if global.calendarmonth > 2 {
kickoutofcalendar()
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}}
	
	if global.calendarmonth = global.calendarcurrentmonth {
	if global.calendarcurrentday < 8 {
	if global.calendarweek = 2 {
		kickoutofcalendar()
	}}
	if global.calendarcurrentday < 15 {
	if global.calendarweek = 3 {
		kickoutofcalendar()
	}}
	if global.calendarcurrentday < 22 {
	if global.calendarweek = 4 {
		kickoutofcalendar()
	}}} 
	if global.calendarmonth > global.calendarcurrentmonth {
		kickoutofcalendar()
	}
	
	}
if global.calendar = 2 {
if room = asset_get_index("r_c2022lvl" + string(global.calendarday1)) {
room_goto(asset_get_index("r_c2022lvl" + string(global.calendarday2))) global.newcalendarlevel1 = 1
}
if room = asset_get_index("r_c2022lvl" + string(global.calendarday2)) {
room_goto(asset_get_index("r_c2022lvl" + string(global.calendarday3))) global.newcalendarlevel2 = 1
}
if room = asset_get_index("r_c2022lvl" + string(global.calendarday3)) {
room_goto(asset_get_index("r_c2022lvl" + string(global.calendarday4))) global.newcalendarlevel3 = 1
}
if room = asset_get_index("r_c2022lvl" + string(global.calendarday4)) {
room_goto(asset_get_index("r_c2022lvl" + string(global.calendarday5))) global.newcalendarlevel4 = 1
}
if room = asset_get_index("r_c2022lvl" + string(global.calendarday5)) {
room_goto(asset_get_index("r_c2022lvl" + string(global.calendarday6))) global.newcalendarlevel5 = 1
}
if room = asset_get_index("r_c2022lvl" + string(global.calendarday6)) {
room_goto(asset_get_index("r_c2022lvl" + string(global.calendarday7))) global.newcalendarlevel6 = 1
}
if room = asset_get_index("r_c2022lvl" + string(global.calendarday7)) {
kickoutofcalendar() global.newcalendarlevel7 = 1
}

//This code is terrible, this is supposed to give rewards to the player
//when he completes the calendar week
if global.newcalendarrewarded = 0 {
if global.newcalendarlevel1 = 1 {
if global.newcalendarlevel2 = 1 {
if global.newcalendarlevel3 = 1 {
if global.newcalendarlevel4 = 1 {
if global.newcalendarlevel5 = 1 {
if global.newcalendarlevel6 = 1 {
if global.newcalendarlevel7 = 1 {
random_set_seed(global.newcalendarseed)
var rwd = irandom_range(1,global.calendardifficulty)

if rwd = 1 { //Hats
var cust = irandom_range(1,global.totalhatsAM)
if global.hat[cust] = 1 { global.creditscurrency += floor(50 * global.creditsmultiplier) } else { global.hat[cust] = 1 } 
}
if rwd = 2 { //Skins
var cust = irandom_range(1,global.totalskinsAM)
if global.skin[cust] = 1 { global.creditscurrency += floor(50 * global.creditsmultiplier) } else { global.skin[cust] = 1 } 
}
if rwd = 3 { //Items
var cust = irandom_range(1,global.totalitemsAM)
if global.item[cust] = 1 { global.creditscurrency += floor(50 * global.creditsmultiplier) } else { global.item[cust] = 1 } 
}

if global.calendardifficulty = 2 { global.creditscurrency += floor(100 * global.creditsmultiplier) }
if global.calendardifficulty = 3 { global.creditscurrency += floor(250 * global.creditsmultiplier) }
global.newcalendarrewarded = 1
global.newcalendarrecord += 1
steam_upload_score("Calendar Wins", global.newcalendarrecord);
global.newcalendarreward = cust
}}}}}}}

scr_savenewcalendar()
}

}


}
} else { 
if place_meeting(x,y+3,o_door) {
if !instance_exists(o_key) {
global.LEMode = 1
global.LEVerified = 1

instance_destroy(o_time)
instance_destroy(o_timecounter)
instance_destroy(o_deathcounter)
instance_destroy(o_savedandloaded)
box = instance_create(x,y,o_savedandloaded)
with box { image_index = 2 }
instance_destroy() }}}

//Debug
if debug_mode{
	if keyboard_check_pressed(ord("N")) {
	if global.endless = 0 {
room_goto_next()	
	} else { randomlevel() }
	}	
		if keyboard_check_pressed(ord("P")) {
	if global.endless = 0 {
room_goto_previous()	
	} else { randomlevel() }
	}
		if keyboard_check_pressed(ord("M")) {
audio_stop_all()
	}	
}

if global.biglevelperfsettings < 1 { exit }

//show_debug_message("lol")
instance_activate_region(x-150,y-150,x+150,y+150,true)