scr_loadsettings()
gamepad_set_color(0,c_red)

customhat = 0
curhat = s_graduationhat
scr_moddinghats(global.CUSTOMhat)

if global.skinselected != 24 {
sprite_set_offset(sprite_index,0,0)
}

if room = r_customlevelworkshop { global.time = 0 }

AdMob_Banner_Hide()

window_set_cursor(cr_default)
mask_index = s_playerred

hsp = 0; //Horizontal
vsp = 0; //Vertical
grv = 0.5 //Gravity
walksp = 4; //Speed
realwalk = 0 //Total Speed
zerogrv = 0
hspzerogrv = 0
onice = false
if instance_place(x,y+32,o_iceblock) {
onice = true	
}
teleportcooldown = 0
portallast = 0
whiteplayer = 0
image_speed = 0
passblockcooldown = 0
torchcount = 0
firedeath = 10
tearcooldown = 5
goldcooldown = 5
red = 255
green = 0
blue = 0
change = 0
move = 0
inwater = 1 //1 = not in water, 2 = in water
breath = 500

color = c_white

//Items
itemrot = 0
itemtimer = 80
itemscale = 1
rot1 = 0
rot2 = -180

if room = r_leveleditor || room = r_customlevelworkshop {
global.LESavedWinTime = 0
global.color = global.defaultcolorLE
} else {
global.color = 0;	
}

global.gunammo = 0
global.gunammoinfinite = false

//Checkpoint system
if global.checkpointX != 0 {
x = global.checkpointX
}
if global.checkpointY != 0 {
y = global.checkpointY
}
if global.checkpointCOLOR != -1 {
global.color = global.checkpointCOLOR
}
if global.checkpointGRV != 0 {
grv = global.checkpointGRV
}
if global.checkpointAMMO != 0 {
global.gunammo = global.checkpointAMMO
}
if global.checkpointGUN != false {
instance_create(x,y,o_gunequipped)
}

audio_stop_sound(snd_explosionboss)
xchange = 0
ychange = 0
jumptestdebug = false
jumptest = 0
jumptest2 = 0
rotation = 0
lightbomberframe = 0

doublejump = 0

//Skins
scr_changecolorplayervx()

switch(global.skinselected) {
case 24:
xchange += 16
ychange += 1
break;
}

if global.hardmode = 0 {
if global.challenges = 0 {
if global.endless = 0 {
if room != r_leveleditor {
scr_savegame()
}}}}
musicandsoundvolumefix()
audio_stop_sound(m_mainmenu);

//Particles
par_walktimer = 12 * (60 / global.maxfps)

//Animated
eyesX = 0
eyesY = 0
basesize = 1
changesizeanimated = 0
randomblinking = 300
blinkinganimatioon = 0

//Googly
googlyeyesrot = 0
googlyeyesrotreal = 0
randomeeyerotationR = 0
randomeeyerotationL = 0

//Spiral
spiraleyerot = 0

//Heart
if instance_exists(o_door) {
heartbump = distance_to_object(o_door)
} else { heartbump = 120 }
hearteyeincrease = 1

/*Colors:
Red = 0 | Yellow = 1 | Green = 2 | Blue = 3 | White = 4 |*/

//Controls
global.controlsmoveright = string_upper(global.controlsmoveright)
global.controlsmoveleft = string_upper(global.controlsmoveleft)
global.controlsjump = string_upper(global.controlsjump)
scr_playercontrolsconfig()

//Endless Death Check
scr_endlessruncheck()

global.playermove = 0
depth = 1;
instance_destroy(o_bulletleft);
instance_destroy(o_bulletright);
if global.pickup = 1 {
global.special -= 1
global.pickup = 0
}


alarm[0] = 1 * (global.maxfps / 60 )