declarecustombutton()
text = loc("OLD_SCHOOL_ENDLESS_RUN")
if global.oldERunlock = 0 {
locked = 1
}

cost = 100
if !platform_mobile() {
cost = 0
locked = 0
global.oldERunlock = 1
}
