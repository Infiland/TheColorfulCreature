depth = -10

text = loc(578)
difficulty = 4
challenge = 13
diamondtime = 183.2
deaths = 999999
time = 9999
locked = 1
if global.skin031 < 1 { wincol = c_white } else { wincol = c_lime }
if global.world4 = 1 { locked = 0 }

medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1