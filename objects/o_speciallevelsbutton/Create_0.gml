/// @description Variables

//Will always get destroyed until I add special levels
instance_destroy()

declarecustombutton()
text = loc("SPECIAL_LEVELS");
if global.donatedmoney = 0 {
locked = 1
} else { locked = 0 }