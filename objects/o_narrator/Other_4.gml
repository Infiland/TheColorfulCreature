controls_key_display(global.controlsinteract)
strings[48] = "W2-L16 Press "+ string(keyd) +" on this weird particle thingy."
controls_key_display(global.controlsrestart)
strings[56] = "W3-L2 If you are stuck, press "+ string(keyd) +" to restart."
controls_key_display(global.controlsinteract)
strings[130] = "SLIPPERY-L6 You can press "+ string(keyd) +" to shoot with your gun."
switch(global.deaths) {
default: strings[94] = "W4-L19 Oh, maybe you don't feel anything, since you've died like " + string(global.deaths) + " times." break;
case(0): strings[94] = "W4-L19 Wow! You haven't died a single time!" break;
case(1): strings[94] = "W4-L19 One" break;
case(2): strings[94] = "W4-L19 Two" break;
case(3): strings[94] = "W4-L19 Three" break;
case(4): strings[94] = "W4-L19 Four" break;
case(5): strings[94] = "W4-L19 How many chocolate bars are in the store?" break;
}
strings[136] = "W5-L10 You got a gun! Press "+ string(keyd) + " to shoot, they can dodge bullets so beware."
strings[262] = string(global.leveleditorstring)

if global.hardmode = 1 {
strings[80] = "W4-L5 Timing is the key!"
strings[81] = "W4-L6 This is why you need chocolate bars"
}

strings[269] = "Year: " + string(global.calendaryear) + " | Month: " + string(global.calendarmonth) + " | Day: " + string(global.calendarday) //+ "     " + string(global.calendarday1required)+string(global.calendarday2required)+string(global.calendarday3required)+string(global.calendarday4required)+string(global.calendarday5required)+string(global.calendarday6required)+ string(global.calendarday7required)