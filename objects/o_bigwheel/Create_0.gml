randomize()
wheelspeed = 0
spinned = 0
rewarded = 0
image_xscale = 2
image_yscale = 2

image_speed = 0
if global.totaltime >= global.wheelskincooldown {
image_index = 1	
}

multi = global.creditsmultiplier * global.wheelmultiplier

direction = random_range(0,360)

text = "You'll be able to spin again when you reach "
text2 = " minutes of PLAYTIME."