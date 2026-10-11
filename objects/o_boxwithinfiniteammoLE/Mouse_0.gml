// Only while building: a play-test or another room must not convert boxes.
if (room != r_leveleditor || global.LEBuild != 1 || global.LEMode != 1) exit;
if !place_meeting(x,y,o_boxLE) {
if global.LES = 56 { instance_change(o_boxLE,1) }
}
if !place_meeting(x,y,o_boxwithammoLE) {
if global.LES = 57 { instance_change(o_boxwithammoLE,1) }
}