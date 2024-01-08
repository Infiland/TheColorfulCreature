if result = 1 { timer2 -= 1 

if timer < 0 {
if !instance_exists(o_restartgameLE) {
var restart = instance_create(416,512,o_restartgameLE)
with restart {
	x = 400
	y = 500
	image_xscale = 50
	image_yscale = 20
}}
}

}