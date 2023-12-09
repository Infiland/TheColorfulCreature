/// @description Click to start

if locked = 1 { exit }

instance_destroy()
instance_destroy(o_classiccalendarbutton)
instance_create(x,y,o_newcalendarbuttonmaker)
instance_create(x,y,o_newcalendarinfo)
instance_create(x,y,o_newcalendarreward)

var easy = instance_create(334,530,o_newcalendardifficulty)
var normal = instance_create(458,530,o_newcalendardifficulty)
var hard = instance_create(582,530,o_newcalendardifficulty)
with easy {
	image_xscale = 21.6 difficulty = 1
	image_yscale = 10 text = "Easy"
}
with normal {
	image_xscale = 21.6 difficulty = 2
	image_yscale = 10 text = "Normal"
}
with hard {
	image_xscale = 21.6 difficulty = 3
	image_yscale = 10 text = "Hard"
}