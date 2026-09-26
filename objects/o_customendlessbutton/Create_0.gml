declarecustombutton()
text = loc("CUSTOM_ENDLESS_RUN")
if global.customERunlock = 0 {
locked = 1
}
cost = 500
if !platform_mobile() {
cost = 200
}
