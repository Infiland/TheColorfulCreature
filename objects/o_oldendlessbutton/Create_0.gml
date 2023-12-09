declarecustombutton()
text = loc(131)
if global.oldERunlock = 0 {
locked = 1
}

cost = 100
if os_type != os_android {
cost = 0
locked = 0
global.oldERunlock = 1
}