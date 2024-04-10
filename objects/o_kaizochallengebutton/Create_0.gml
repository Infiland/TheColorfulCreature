depth = -10

text = loc(580)
difficulty = 5
challenge = 1
diamondtime = 444
deaths = 999999
time = 9999
locked = 1
if global.skin[2] < 1 { wincol = c_white } else { wincol = c_lime }
if global.world5 = 1 { locked = 0 }

medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1