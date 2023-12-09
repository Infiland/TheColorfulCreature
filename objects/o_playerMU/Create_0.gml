//Multiplayer Player
multiplayerplayer = 1

xchange = 0
ychange = 0
rotation = 0
lightbomberframe = 0
customhat = 0
zerogrv = 0

audio_stop_sound(m_mainmenu);

hsp = 0; //Horizontal
vsp = 0; //Vertical
grv = 0.5 //Gravity
walksp = 4; //Speed
realwalk = 0 //Total Speed
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
doublejump = 0

//Items
itemrot = 0
itemtimer = 80
itemscale = 1
rot1 = 0
rot2 = -180


//Particles
par_walktimer = 12 * (60 / global.maxfps)

//Gun
hasgun = false
gunframe = 30
gunangle = 0 //angle
gunrotation = 30
xcord = 7
ycord = 5
timer = 0

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

color = 0
colorH = c_red
playermove = 0
ammo = 0
infammo = false
depth = 1;

alarm[0] = 1 * (global.maxfps / 60 )