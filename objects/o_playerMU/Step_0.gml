//Get Player Input
scr_multiplayercontrolsplayer()
//Restart
if global.pause = 1{ exit }
if key_restart {
if global.pause = 0 {
deathMU()
}}
//Water
if place_meeting(x,y,o_water) { inwater = 2 } else { inwater = 1 }
if inwater = 2 { 
	breath -= 1 * (60 / global.maxfps)
	if breath < 0 { deathMU() }
	} else { breath += 3 * (60 / global.maxfps)
	if breath > 500 { breath = 500 }
		}
//Sound Manipultation
if passblockcooldown > -1 { passblockcooldown -= 1 }
if grv = 0.83 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,1.25)	}
if grv = 0.5 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,1)	}
if grv = 0.172 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,0.8)	}
if grv = 0.027 * (60 / global.maxfps) {audio_sound_pitch(snd_jump,0.7)	}

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
hsp = ((move * realwalk) / inwater) * (60 / global.maxfps)
}
if move = 0 { 
	if onice = false {
	realwalk = 0 
	} else {
	if realwalk > 0 {
		realwalk -= 0.05 * (60 / global.maxfps)
	}
	}}
	
vsp = (vsp + ((grv* (60 / global.maxfps))/inwater));
if place_meeting(x,y+1,o_anyblock) {onice = false}
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
if place_meeting(x,y+1,o_iceblock) {onice = true}

if y > room_height - 30 {
	deathMU()
}

//Particles
if global.playerpar = 2 {
par_walktimer -= 1 * (60 / global.maxfps)
if par_walktimer < 0 {
if key_right || key_left {
if place_meeting(x,y+1,o_anyblock) {
par_walk = instance_create(x+14,y+27,o_parwalk)
par_walktimer = 3
}}}

}

//Jumps (Optimized Code)
if (place_meeting(x,y+1,o_anyblock)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_redblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_yellowblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_greenblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_blueblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_whiteblockmove)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_shooter)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_shooterright)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_rocketlauncher)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_rocketlauncherright)) and (key_jump) {jump()}
if vsp > 0 {
if (place_meeting(x,y+1,o_onewayupblock)) and (key_jump) { {jump()} }
}
if (place_meeting(x,y,o_ladder)) and (key_jump) { 
	vsp = -3
	onice = false
	if !audio_is_playing(snd_ladder) {
	audio_play_sound(snd_ladder,0,0)
	}
	}
if (place_meeting(x,y+1,o_iceblock)) and (key_jump) {jump()}
if (place_meeting(x,y+1,o_playerMU)) and (key_jump) {jump()}
	
//Sound
if global.writingmode = 0 {
if (place_meeting(x,y+1,o_anyblock)) || (place_meeting(x,y+1,o_redblockmove)) || (place_meeting(x,y+1,o_yellowblockmove)) || (place_meeting(x,y+1,o_greenblockmove)) || (place_meeting(x,y+1,o_blueblockmove)) || (place_meeting(x,y+1,o_whiteblockmove)) || (place_meeting(x,y+1,o_shooter)) || (place_meeting(x,y+1,o_rocketlauncherright)) || (place_meeting(x,y+1,o_rocketlauncher)) || (place_meeting(x,y+1,o_shooterright)) || (place_meeting(x,y+1,o_onewayupblock)) || (place_meeting(x,y+1,o_box)) || (place_meeting(x,y+1,o_boxwithammo)) || (place_meeting(x,y+1,o_boxwithinfiniteammo)){
if (key_jump) {
if !place_meeting(x,y,o_onewayupblock) {
if !place_meeting(x,y,o_onewaydownblock) {
audio_sound_pitch(snd_jump,random_range(0.9,1.1));
audio_sound_gain(snd_jump,global.soundvolume,1)
if !place_meeting(x,y-4,o_playerMU) {
audio_play_sound(snd_jump,10,0)
}
}}}}}
//Horizontal Collision
horizontalcollision()
x = x + hsp

//Vertical Collision
verticalcollision()
y = y + vsp * (60 / global.maxfps)
if vsp > 30 * (global.maxfps / 60) { vsp = 30 * (global.maxfps / 60) }

//Animation
if multiplayerplayerskin != 23 {
if vsp < -0.1 and !hsp  { image_index = 6 } //Jump
if vsp > 0.1 and !hsp  { image_index = 3 } //Fall
if key_right and vsp = 0 { image_index = 1 } //Moving right without jumping
if key_right and vsp < -0.1 { image_index = 7 } //Jumping right
if key_right and vsp > 0.1 { image_index = 4 } //Falling rightH
if key_left and vsp = 0 { image_index = 2 } //Moving left without jumpin
if key_left and vsp < -0.1 { image_index = 8 } //Jumping left
if key_left and vsp > 0.1 { image_index = 5 } //Falling left
if key_right and key_left and vsp > 0.1 { image_index = 3 } //Falling while pressing left and right
if key_right and key_left and vsp < -0.1 { image_index = 6 } //Jumping while pressing left and right
if key_right and key_left and vsp = 0 { image_index = 0} //Pressing left and right
}
if key_right { playermove = 1 }
if key_left { playermove = -1 }
//Colors (AND SKINS)
switch(multiplayerplayerskin) {
case 0:
if color = 0 {sprite_index = s_playerred}
if color = 1 {sprite_index = s_playeryellow}
if color = 2 {sprite_index = s_playergreen}
if color = 3 {sprite_index = s_playerblue}
if color = 4 {sprite_index = s_playerwhite}
break;
case 2:
if color = 0 {sprite_index = s_kaizoplayerred}
if color = 1 {sprite_index = s_kaizoplayeryellow}
if color = 2 {sprite_index = s_kaizoplayergreen}
if color = 3 {sprite_index = s_kaizoplayerblue}
if color = 4 {sprite_index = s_kaizoplayerwhite}
break;
case 1:
if color = 0 {sprite_index = s_madplayerred}
if color = 1 {sprite_index = s_madplayeryellow}
if color = 2 {sprite_index = s_madplayergreen}
if color = 3 {sprite_index = s_madplayerblue}
if color = 4 {sprite_index = s_madplayerwhite}
break;
case 3:
if color = 0 {sprite_index = s_blindplayerred}
if color = 1 {sprite_index = s_blindplayeryellow}
if color = 2 {sprite_index = s_blindplayergreen}
if color = 3 {sprite_index = s_blindplayerblue}
if color = 4 {sprite_index = s_blindplayerwhite}
break;
case 4:
if color = 0 {sprite_index = s_sadplayerred}
if color = 1 {sprite_index = s_sadplayeryellow}
if color = 2 {sprite_index = s_sadplayergreen}
if color = 3 {sprite_index = s_sadplayerblue}
if color = 4 {sprite_index = s_sadplayerwhite}
if global.playerpar > 0 {
tearcooldown -= random_range(0.1,0.3)

if tearcooldown < 0 {
instance_create(x+random_range(8,22),y+18,o_playertear)
tearcooldown = 5 * (global.maxfps / 60)
}}
break;
case 5:
if color = 0 {sprite_index = s_blockplayerred}
if color = 1 {sprite_index = s_blockplayeryellow}
if color = 2 {sprite_index = s_blockplayergreen}
if color = 3 {sprite_index = s_blockplayerblue}
if color = 4 {sprite_index = s_blockplayerwhite}
break;
case 6:
if color = 0 {sprite_index = s_hdplayerred}
if color = 1 {sprite_index = s_hdplayeryellow}
if color = 2 {sprite_index = s_hdplayergreen}
if color = 3 {sprite_index = s_hdplayerblue}
if color = 4 {sprite_index = s_hdplayerwhite}
break;
case 7:
if color = 0 {sprite_index = s_rewardedplayerred}
if color = 1 {sprite_index = s_rewardedplayeryellow}
if color = 2 {sprite_index = s_rewardedplayergreen}
if color = 3 {sprite_index = s_rewardedplayerblue}
if color = 4 {sprite_index = s_rewardedplayerwhite}
break;
case 8:
if color = 0 {sprite_index = s_angryplayerred}
if color = 1 {sprite_index = s_angryplayeryellow}
if color = 2 {sprite_index = s_angryplayergreen}
if color = 3 {sprite_index = s_angryplayerblue}
if color = 4 {sprite_index = s_angryplayerwhite}
break;
case 9:
if color = 0 {sprite_index = s_coolplayerred}
if color = 1 {sprite_index = s_coolplayeryellow}
if color = 2 {sprite_index = s_coolplayergreen}
if color = 3 {sprite_index = s_coolplayerblue}
if color = 4 {sprite_index = s_coolplayerwhite}
break;
case 10:
sprite_index = s_thedarkknightskin
scr_playerrbgMU()
break;
case 11:
if color = 0 {sprite_index = s_richplayerred}
if color = 1 {sprite_index = s_richplayeryellow}
if color = 2 {sprite_index = s_richplayergreen}
if color = 3 {sprite_index = s_richplayerblue}
if color = 4 {sprite_index = s_richplayerwhite}
break;
case 12:
sprite_index = s_goldplayerskin
goldcooldown = irandom_range(0,10)
	if global.playerpar > 0 {
	if goldcooldown = 0 {
var star = instance_create(x+12,y+14,o_itemstar);
with star { image_blend = c_yellow }	
}}
break;
case 13:
if color = 0 {sprite_index = s_frozenplayerred}
if color = 1 {sprite_index = s_frozenplayeryellow}
if color = 2 {sprite_index = s_frozenplayergreen}
if color = 3 {sprite_index = s_frozenplayerblue}
if color = 4 {sprite_index = s_frozenplayerwhite}
break;
case 14:
scr_playerrbgnormalMU()
break;
case 15:
if color = 0 {sprite_index = s_coronaplayerred}
if color = 1 {sprite_index = s_coronaplayeryellow}
if color = 2 {sprite_index = s_coronaplayergreen}
if color = 3 {sprite_index = s_coronaplayerblue}
if color = 4 {sprite_index = s_coronaplayerwhite}
break;
case 16:
if color = 0 {sprite_index = s_canadianplayerred}
if color = 1 {sprite_index = s_canadianplayeryellow}
if color = 2 {sprite_index = s_canadianplayergreen}
if color = 3 {sprite_index = s_canadianplayerblue}
if color = 4 {sprite_index = s_canadianplayerwhite}
break;
case 17:
if color = 0 {sprite_index = s_playerred}
if color = 1 {sprite_index = s_playeryellow}
if color = 2 {sprite_index = s_playergreen}
if color = 3 {sprite_index = s_playerblue}
if color = 4 {sprite_index = s_playerwhite}
break;
case 18:
if color = 0 {sprite_index = s_babyplayerred}
if color = 1 {sprite_index = s_babyplayeryellow}
if color = 2 {sprite_index = s_babyplayergreen}
if color = 3 {sprite_index = s_babyplayerblue}
if color = 4 {sprite_index = s_babyplayerwhite}
break;
case 19:
if color = 0 {sprite_index = s_hexagonplayerred}
if color = 1 {sprite_index = s_hexagonplayeryellow}
if color = 2 {sprite_index = s_hexagonplayergreen}
if color = 3 {sprite_index = s_hexagonplayerblue}
if color = 4 {sprite_index = s_hexagonplayerwhite}
break;
case 20:
if color = 0 {sprite_index = s_tuxedoplayerred}
if color = 1 {sprite_index = s_tuxedoplayeryellow}
if color = 2 {sprite_index = s_tuxedoplayergreen}
if color = 3 {sprite_index = s_tuxedoplayerblue}
if color = 4 {sprite_index = s_tuxedoplayerwhite}
break;
case 21:
scr_playerrbgMU()
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
if playermove = 1 {
eyesX = lerp(eyesX,6,0.2 * (60 / global.maxfps))
}
if playermove = -1 {
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
randomblinking -= 1 * (60 / global.maxfps)
if randomblinking < 0 {
blinkinganimatioon += 0.33 * (60 / global.maxfps)
if blinkinganimatioon > 9 {
blinkinganimatioon = 0
randomblinking = irandom_range(250,450)	
}}
break;
case 22:
if color = 0 {sprite_index = s_playerred}
if color = 1 {sprite_index = s_playeryellow}
if color = 2 {sprite_index = s_playergreen}
if color = 3 {sprite_index = s_playerblue}
if color = 4 {sprite_index = s_playerwhite}
break;
case 23:
if key_right { image_index = 0 }
if key_left {image_index = 1 }
scr_playerrbgnormalMU()
break;
case 24:
if key_right { rotation -= realwalk }
if key_left {rotation += realwalk }
scr_playerrbgnormalMU()
break;
case 26:
scr_playerrbgnormalMU()
break;
case 27:
scr_playerrbgnormalMU()
break;
case 28:
scr_playerrbgnormalMU()
break;
case 29:
scr_playerrbgnormalMU()
break;
case 30:
scr_playerrbgnormalMU()
scr_animatedeyesMU()

if vsp < -0.1 and !hsp  { googlyeyesrot = 0 } //Jump
if vsp > 0.1 and !hsp  { googlyeyesrot = 180 } //Fall
if key_right and vsp = 0 { googlyeyesrot = 270 } //Moving right without jumping
if key_right and vsp < -0.1 { googlyeyesrot = 315 } //Jumping right
if key_right and vsp > 0.1 { googlyeyesrot = 225 } //Falling right
if key_left and vsp = 0 { googlyeyesrot = 90 } //Moving left without jumpin
if key_left and vsp < -0.1 { googlyeyesrot = 35 } //Jumping left
if key_left and vsp > 0.1 { googlyeyesrot = 135 } //Falling left
if key_right and key_left and vsp > 0.1 { googlyeyesrot = 180 } //Falling while pressing left and right
if key_right and key_left and vsp < -0.1 { googlyeyesrot = 0 } //Jumping while pressing left and right
if key_right and key_left and vsp = 0 { googlyeyesrot = 0 } //Pressing left and right
googlyeyesrotreal = lerp(googlyeyesrotreal,googlyeyesrot,0.25 * (60 / global.maxfps))
if keyboard_check_pressed(vk_anykey) {
randomeeyerotationR = lerp(randomeeyerotationR,random_range(-360,360),0.2 * (60 / global.maxfps))
randomeeyerotationL = lerp(randomeeyerotationL,random_range(-360,360),0.2 * (60 / global.maxfps))	
}
case 31:
scr_playerrbgnormalMU()
case 32:
scr_playerrbgnormalMU()
scr_animatedeyesMU()
break;
case 33:
scr_playerrbgnormalMU()
scr_animatedeyesMU()
case 34: scr_playerrbgnormalMU() break;
case 36: scr_playerrbgnormalMU() break;
case 37: scr_playerrbgnormalMU() break;
case 38: scr_playerrbgnormalMU() break;
case 39: sprite_index = s_playerwhite
scr_playerrbgnormalMU() break;
case 40: scr_playerrbgMU()
scr_animatedeyesMU() break;
case 41: sprite_index = s_playerwhite
scr_playerrbgnormalMU() break;
case 42: sprite_index = s_playerwhite
scr_playerrbgnormalMU() break;
case 43:
sprite_index = s_steamplayerskin
scr_playerrbgnormalMU()
break;
case 44:
sprite_index = s_breakableplayerskin
scr_playerrbgnormalMU()
break;
case 45:
sprite_index = s_smileyplayerskin
scr_playerrbgnormalMU()
break;
}

if color = 4 { 
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
if teleportcooldown > 0 {
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
if instance_exists(o_playerMU) {
if place_meeting(x,y,o_portalpurpleopen) {
if instance_exists(o_portalpurpleclosed) {
teleportcooldown = 15
if global.itempar > 0 {
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar)
with star { image_blend = c_fuchsia }}
}
audio_sound_pitch(snd_portal,random_range(0.9,1.1));
audio_play_sound(snd_portal,10,0)
x = o_portalpurpleclosed.x
y = o_portalpurpleclosed.y
}}}
if place_meeting(x,y,o_portalpurpleclosed) {
if portallast = 1 {		
if instance_exists(o_portalpurpleopen) {
teleportcooldown = 15
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar)
with star { image_blend = c_fuchsia }}
audio_sound_pitch(snd_portal,random_range(0.9,1.1));
audio_play_sound(snd_portal,10,0)
x = o_portalpurpleopen.x
y = o_portalpurpleopen.y
}}}}}


//Gun
if hasgun = true {
if key_interact {
if inwater = 1 {
if ammo > 0 {
if playermove = -1 {
bulletleft = instance_create(x-3 - xchange,y+12 - xchange ,o_playerbulletMU)
with bulletleft { playerbullet = 2 }
}
if playermove = 1 {
bulletright = instance_create(x+33 - xchange,y+12 - xchange,o_playerbulletMU)
with bulletright { playerbullet = 1 }
}
if playermove = 0 {
bulletcenter = instance_create(x+28 - xchange,y+12 - xchange,o_playerbulletMU)
with bulletcenter { playerbullet = 1 }
image_index = 1
}
if infammo = false { ammo -= 1 }
}
if ammo < 1 {
audio_play_sound(snd_noammo,0,0)
}
} else { audio_play_sound(snd_noammo,0,0) }
}}
if instance_exists(o_gunequipped) {
if key_right { o_gunequipped.timer = 0 }	
if key_left { o_gunequipped.timer = 0 }
}

//Death

if color != 4 {
if place_meeting(x,y-3,o_yellowblock) || place_meeting(x,y+3,o_yellowblock) {
deathMU()
}
if place_meeting(x-3,y,o_yellowblock) || place_meeting(x+3,y,o_yellowblock) {
deathMU()
}
if place_meeting(x,y-3,o_greenblock) || place_meeting(x,y+3,o_greenblock) {
deathMU()
}
if place_meeting(x-3,y,o_greenblock) || place_meeting(x+3,y,o_greenblock) {
deathMU()
}
if place_meeting(x,y-3,o_blueblock) || place_meeting(x,y+3,o_blueblock) {
deathMU()
}
if place_meeting(x-3,y,o_blueblock) || place_meeting(x+3,y,o_blueblock) {
deathMU()
}}
/*if color != 4 {
if color = 0 {
if place_meeting(x,y-3,o_yellowblock) || place_meeting(x,y-3,o_greenblock) || place_meeting(x,y-3,o_blueblock) {
deathMU()
}}
if color = 1 {
if place_meeting(x,y-3,o_redblock) || place_meeting(x,y-3,o_greenblock) || place_meeting(x,y-3,o_blueblock) {
deathMU()
}}
if color = 2 {
if place_meeting(x,y-3,o_yellowblock) || place_meeting(x,y-3,o_redblock) || place_meeting(x,y-3,o_blueblock) {
deathMU()
}}
if color = 3 {
if place_meeting(x,y-3,o_yellowblock) || place_meeting(x,y-3,o_greenblock) || place_meeting(x,y-3,o_redblock) {
deathMU()
}}
}*/

/*//RED DEATH
if color != 4 {
if color != 0 {
if !place_meeting(x,y-1,o_yellowblock) and !place_meeting(x,y+1,o_yellowblock) and !place_meeting(x,y-1,o_greenblock) and !place_meeting(x,y+1,o_greenblock) and !place_meeting(x,y-1,o_blueblock) and !place_meeting(x,y+1,o_blueblock) {
if place_meeting(x-10,y-10,o_redblockmove) || place_meeting(x+1,y+2,o_redblockmove) || place_meeting(x+1,y+1,o_redblock) || place_meeting(x-1,y+1,o_redblock) || place_meeting(x+1,y-1,o_redblock) || place_meeting(x-1,y-1,o_redblock) {
	deathMU()
}}
if hsp = 0 {
if place_meeting(x+1,y,o_redblock) || place_meeting(x-1,y,o_redblock) {
deathMU()
}}
if passblockcooldown < 1 {
if place_meeting(x,y,o_redpassblock) { deathMU() }
}

}

//YELLOW DEATH
if color != 1 {
if !place_meeting(x,y-1,o_redblock) and !place_meeting(x,y+1,o_redblock) and !place_meeting(x,y-1,o_greenblock) and !place_meeting(x,y+1,o_greenblock) and !place_meeting(x,y-1,o_blueblock) and !place_meeting(x,y+1,o_blueblock) {
if place_meeting(x-10,y-10,o_yellowblockmove) || place_meeting(x+1,y+2,o_yellowblockmove) || place_meeting(x-1,y-1,o_yellowblock) || place_meeting(x+1,y+1,o_yellowblock) || place_meeting(x-1,y+1,o_yellowblock) || place_meeting(x+1,y-1,o_yellowblock) {
deathMU() 
}}

if hsp = 0 {
if place_meeting(x+1,y,o_yellowblock) || place_meeting(x-1,y,o_yellowblock) {
deathMU()
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_yellowpassblock) { deathMU() }
}}


//GREEN DEATH
if color != 2 {
if !place_meeting(x,y-1,o_yellowblock) and !place_meeting(x,y+1,o_yellowblock) and !place_meeting(x,y-1,o_redblock) and !place_meeting(x,y+1,o_redblock) and !place_meeting(x,y-1,o_blueblock) and !place_meeting(x,y+1,o_blueblock) {
if place_meeting(x-10,y-10,o_greenblockmove) || place_meeting(x+1,y+2,o_greenblockmove) || place_meeting(x-1,y-1,o_greenblock) || place_meeting(x+1,y+1,o_greenblock) || place_meeting(x-1,y+1,o_greenblock) || place_meeting(x+1,y-1,o_greenblock) {
deathMU() 
}}

if hsp = 0 {
if place_meeting(x+1,y,o_greenblock) || place_meeting(x-1,y,o_greenblock) {
deathMU()
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_greenpassblock) { deathMU() }
}}

//BLUE DEATH
if color != 3 {
if !place_meeting(x,y-1,o_yellowblock) and !place_meeting(x,y+1,o_yellowblock) and !place_meeting(x,y-1,o_greenblock) and !place_meeting(x,y+1,o_greenblock) and !place_meeting(x,y-1,o_redblock) and !place_meeting(x,y+1,o_redblock) {
if place_meeting(x-10,y-10,o_blueblockmove) || place_meeting(x+1,y+2,o_blueblockmove) || place_meeting(x-1,y-1,o_blueblock) || place_meeting(x+1,y+1,o_blueblock) || place_meeting(x-1,y+1,o_blueblock) || place_meeting(x+1,y-1,o_blueblock) {
deathMU() 
}}

if hsp = 0 {
if place_meeting(x+1,y,o_blueblock) || place_meeting(x-1,y,o_blueblock) {
deathMU()
}}

if passblockcooldown < 1 {
if place_meeting(x,y,o_bluepassblock) { deathMU() }
}}

//WHITE
if passblockcooldown < 1 {
if place_meeting(x,y,o_whitepassblock) {
deathMU() 
}}

}*/

//Other Deaths

if place_meeting(x,y,o_hazard) { deathMU() }

if instance_exists(o_lockedblock) {
if o_lockedblock.sprite_index = s_lockedblock {
if place_meeting(x,y,o_lockedblock) { deathMU() }
}}
if instance_exists(o_unlockedblock) {
if o_unlockedblock.sprite_index = s_lockedblock {
if place_meeting(x,y,o_unlockedblock) { deathMU() }
}}
if place_meeting(x,y,o_gravitylimit01) { 
if grv != 0.027 {
	deathMU() 
	}}
if place_meeting(x,y,o_gravitylimit05) { 
if grv != 0.172 {
	deathMU() 
	}}
if place_meeting(x,y,o_gravitylimit15) { 
if grv != 0.5 {
	deathMU() 
	}}
if place_meeting(x,y,o_gravitylimit25) { 
if grv != 0.83 {
	deathMU() 
	}}
if place_meeting(x,y,o_speedlimit5) { 
if walksp != 2.8 {
	deathMU() 
	}}
if place_meeting(x,y,o_speedlimit7) { 
if walksp != 4 {
	deathMU() 
	}}
if place_meeting(x,y,o_speedlimit10) { 
if walksp != 5.5 {
	deathMU() 
	}}
if place_meeting(x,y,o_speedlimit15) { 
if walksp != 8.5 {
	deathMU() 
	}}