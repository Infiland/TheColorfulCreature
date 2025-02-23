/// @description Variables
declarecustombutton()
text = loc(317)

lockedtext = "???????"
if global.calendar2022unlock = 0 {
locked = 1
} else { locked = 0 }

lockedxscale = 0.8
lockedyscale = 0.8

if global.calendarcurrentyear  < 2022 {
timeleft = 366 - (((global.calendarcurrentmonth - 1) * 30.41666666666667) + global.calendarcurrentday)
} else { timeleft = 0 }

calendarcost = 100
if os_type = os_android || os_type = os_gxgames {
calendarcost = 250	
}

/*if global.calendarcurrentyear = 2022 {
calendarcost = 1000 - ((((global.calendarcurrentmonth - 1) * 30.41666666666667) + global.calendarcurrentday) * 1.366120218579235) + 1.366120218579235
} else if global.calendarcurrentyear = 2023 { calendarcost = 500 - ((((global.calendarcurrentmonth - 1) * 30.41666666666667) + global.calendarcurrentday) * 0.6830601092896175) + 0.6830601092896175 }
else if global.calendarcurrentyear > 2023 { calendarcost = 250 }*/

global.deaths = 0
global.special = 0
global.pickup = 0
global.LES = 0;
global.xplayerLEpos = 0
global.yplayerLEpos = 0
global.talelistened = 0
image_speed = 0;