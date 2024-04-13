depth = -10

text = "World Seven"
difficulty = 6
challenge = 16
diamondtime = 2097.9
deaths = 999999
time = 9999
locked = 1
if global.skin[41] < 1 { wincol = c_white } else { wincol = c_lime }
if global.skin[17] = 1 { locked = 0 }

medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1