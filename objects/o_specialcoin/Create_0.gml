if global.infinitelivessettings = 1 {
if global.hardmode = 1 {
instance_destroy();	
}}
depth = 0;
if room = r_leveleditor {
if x = 0 {
if y = 0 {
instance_destroy()	
}}}

chanceofdissapear = 0
if global.hardmode = 1 {
randomize();
switch(global.hardmodedifficulty) {
case(2):
chanceofdissapear = irandom_range(1,8)
if chanceofdissapear = 1 { instance_destroy() }
break;
case(3):
chanceofdissapear = irandom_range(1,6)
if chanceofdissapear = 1 { instance_destroy() }
break;
case(4):
chanceofdissapear = irandom_range(1,4)
if chanceofdissapear = 1 { instance_destroy() }
break;
case(5):
chanceofdissapear = irandom_range(1,3)
if chanceofdissapear < 3 { instance_destroy() }
break;
case(6):
chanceofdissapear = irandom_range(1,6)
if chanceofdissapear < 5 { instance_destroy() }
break;
case(7):
instance_destroy()
break;
}
}

if global.endless = 1 { instance_destroy() }
if global.nostalgia = 1 { sprite_index = s_oldcoin }