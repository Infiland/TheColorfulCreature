depth = -10

text = loc(581)
difficulty = 5
challenge = 7
diamondtime = 191.6
deaths = 999999
time = 9999
locked = 1
if global.skin017 < 1 { wincol = c_white } else { wincol = c_lime }
if global.world5 = 1 { locked = 0 }

medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1