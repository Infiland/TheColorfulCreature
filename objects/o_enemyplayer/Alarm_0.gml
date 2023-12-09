if state != 2 {
instance_create(random_range(x-15,x+15),y,o_boredomblock)
}
dontxrayfix = 0
alarm[0] = 300 * (60 / global.maxfps)