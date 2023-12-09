if global.pause = 0 {
firedeath -= 1
}
if global.easy = 0 {
if firedeath < 0 { deathMU() }
}