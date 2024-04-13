depth = -10

text = loc(575)
difficulty = 3
challenge = 11
diamondtime = 101.2
deaths = 999999
time = 9999
locked = 1
if global.skin[23] < 1 { wincol = c_white } else { wincol = c_lime }
if global.world3 = 1 { locked = 0 }

medalsprite = -1

loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1