declarecustombutton()
depth = -10001
x = 32
y = 224
image_xscale = 36
image_yscale = 18
yscale = 0.5
xscale = 0.5
width = 3
wide = 500

multi = global.creditsmultiplier * global.wheelmultiplier

var cost = floor((global.wheeltimeleft/30) * (0.5 + (multi / 2)))
var maxcost = floor(120 * (0.5 + (multi / 2)))
text = "Skip Cooldown\nCost: " + string(cost)

alarm[0] = 1