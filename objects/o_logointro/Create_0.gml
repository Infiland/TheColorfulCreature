if (TCC_SELF_CHECK) { scr_port_selfcheck(); exit; }
global.soundvolume = 0.5;
global.maxfps = 60;
scr_loading();
room_goto(r_loading);
