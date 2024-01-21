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

if global.visiblethings = 0 {
strings[263] = "INV-L1 Oh, wait is this? Invisible Blocks? Oh no."
strings[264] = "INV-L2 Luckily this is a easy challenge so this shouldn't be a problem. Right?"
strings[265] = "INV-L3 Invisible maze. Totally a peak of level design."
strings[266] = "INV-L4 Down-Up, Down-Up."
strings[267] = "INV-L5 Make slow choices."
strings[110] = "BLIND-L1 Ummm... What happened to the lights?"
strings[111] = "BLIND-L2 Where is the light switch?"
strings[112] = "BLIND-L3 I cannot find it, let me know if that is not a problem for you."
strings[113] = "BLIND-L4 It doesn't? Well then, the developer placed some torches just in case, hope it helps."
strings[114] = "BLIND-L5 Yeah, I guess it does, just do not burn yourself."
strings[115] = "BLIND-L6 You might need torches for this one, because you will not see the flying bullets."
strings[116] = "BLIND-L7 It is time for adventure!"
} else {
strings[263] = "V-L1 Oh, wait is this? Well this looks pretty normal"
strings[264] = "V-L2 Luckily this is now an easier challenge."
strings[265] = "V-L3 It would totally be peak level design if this maze was invisible."
strings[266] = "V-L4 I mean, there are people who complain about that kind of stuff, weird right?"
strings[267] = "V-L5 So this is indeed why video games need accessibility options!"
strings[110] = "LIT-L1 Is this just World 1 but with spikes?"
strings[111] = "LIT-L2 Nope, it's not. But what is this torch for?"
strings[112] = "LIT-L3 Well, no worries about that! Let's collect some keys!"
strings[113] = "LIT-L4 Here's that torch again, weird. Am I missing something?"
strings[114] = "LIT-L5 Oooooh I get it! Don't collect torches, or you will burn yourself!"
strings[115] = "LIT-L6 But why are they there? It's like if you are supposed to use them in some way."
strings[116] = "LIT-L7 Welp, it doesn't matter, it's up to you to theorize. It is time for adventure!"
}

if gamepad_is_connected(0) {
strings[48] = "W2-L16 Press [scale,0.5][s_xboxcontrollerscheme,7][scale,1] on this weird particle thingy."
strings[56] = "W3-L2 If you are stuck, press [scale,0.5][s_xboxcontrollerscheme,50][scale,1] to restart."
strings[130] = "SLIPPERY-L6 You can press [scale,0.5][s_xboxcontrollerscheme,56][scale,1] to shoot with your gun."
strings[136] = "W5-L10 You got a gun! Press [scale,0.5][s_xboxcontrollerscheme,56][scale,1] to shoot, they can dodge bullets so beware."
}

strings[269] = "Year: " + string(global.calendaryear) + " | Month: " + string(global.calendarmonth) + " | Day: " + string(global.calendarday) //+ "     " + string(global.calendarday1required)+string(global.calendarday2required)+string(global.calendarday3required)+string(global.calendarday4required)+string(global.calendarday5required)+string(global.calendarday6required)+ string(global.calendarday7required)