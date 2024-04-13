depth = -10

text = loc(569)
difficulty = 2
challenge = 14
diamondtime = 57.1
deaths = 999999
time = 9999
locked = 1
if global.skin[37] < 1 { wincol = c_white } else { wincol = c_lime }
if global.world2 = 1 { locked = 0 }


medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1