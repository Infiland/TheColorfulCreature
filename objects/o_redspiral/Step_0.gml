if global.pause = 0 { image_speed = 1 } else{ image_speed = 0 }

if room = r_leveleditor {
if global.LES = 6 or 7 or 8 or 9 or 10 or 29 or 30 or 31 or 32 or 33 {
if place_meeting(x,y,o_redblock) or place_meeting(x,y,o_yellowblock) or place_meeting(x,y,o_greenblock) or place_meeting(x,y,o_blueblock) or place_meeting(x,y,o_whiteblock) or place_meeting(x,y,o_redpassblock) or place_meeting(x,y,o_yellowpassblock) or place_meeting(x,y,o_greenpassblock) or place_meeting(x,y,o_bluepassblock) {
instance_destroy()	
}}}