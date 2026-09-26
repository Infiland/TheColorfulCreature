scr_playercontrolsconfig()

if global.hardmode = 1 {
instance_destroy()
}

key_skip = false

skipcontrols = 0
timer = 0.7
reqcoin = 4
keyd = "";
if global.skiplevelholdsettings = 0 {
skip = "Press [" + string(keyd) + "] to skip\n a level ("+ string(reqcoin) + " Coins)"
}
if global.skiplevelholdsettings = 1 {
skip = "Hold [" + string(keyd) + "] to skip\n a level ("+ string(reqcoin) + " Coins)"
}
