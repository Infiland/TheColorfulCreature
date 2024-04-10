text = loc(566)
difficulty = 1
challenge = 8
diamondtime = 45
deaths = 999999
time = 9999
locked = 1
if global.skin[19] < 1 { wincol = c_white } else { wincol = c_lime }
if global.world1 = 1 { locked = 0 }

depth = -10
medalsprite = -1
//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1