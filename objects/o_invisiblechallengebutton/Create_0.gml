depth = -10

text = loc(602)
difficulty = 1
challenge = 17
diamondtime = 60
deaths = 999999
time = 9999
locked = 1
if global.skin043 < 1 { wincol = c_white } else { wincol = c_lime }
if global.world1 = 1 { locked = 0 }


medalsprite = -1

//Language
loadstatschallenge()
loadgradechallenge()
BESTTIME = loc(544) + ": "
LEASTDEATHS = loc(543) + ": "

alarm[0] = 1