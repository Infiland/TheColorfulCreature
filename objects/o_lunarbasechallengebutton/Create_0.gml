depth = -10

text = "Lunar Base Challenge"
difficulty = 4
challenge = 18
diamondtime = 500
deaths = 999999
time = 9999
locked = 1
if global.skin049 < 1 { wincol = c_white } else { wincol = c_lime }
if global.world4 = 1 { locked = 0 }

medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1