if global.pause = 0 { image_speed = 1 } else{ image_speed = 0 }

if room = r_leveleditor {
if global.LES = 6 || 7 || 8 or 9 or 10 or 29 or 30 or 31 or 32 || 33 {
if place_meeting(x,y,o_redblock) || place_meeting(x,y,o_yellowblock) || place_meeting(x,y,o_greenblock) || place_meeting(x,y,o_blueblock) || place_meeting(x,y,o_whiteblock) || place_meeting(x,y,o_redpassblock) || place_meeting(x,y,o_yellowpassblock) || place_meeting(x,y,o_greenpassblock) || place_meeting(x,y,o_bluepassblock) {
instance_destroy()	
}}}