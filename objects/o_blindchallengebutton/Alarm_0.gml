time = global.blindchallengetime
deaths = global.blindchallengedeaths
medalcheck(time,diamondtime,deaths)

if medalsprite = 0 {
wincol = $2a9190
}
if medalsprite = 1 {
wincol = c_silver
}
if medalsprite = 2 {
wincol = c_yellow
}
if medalsprite = 3 {
wincol = c_aqua
}
if medalsprite = 4 {
wincol = c_red
}
if medalsprite = 5 {
wincol = $534534
}

if global.visiblethings = 1 { text = "Wait, now I see things?" }