if global.pause = 1 { exit }

if dontxrayfix = 1 { exit }
if amountofjumps > 0 {amountofjumps -= 1 * (60/global.maxfps)}
if place_meeting(x+hsp * move,y,o_redblock) or place_meeting(x+hsp * move,y,o_yellowblock) or place_meeting(x+hsp * move,y,o_greenblock) or place_meeting(x+hsp * move,y,o_blueblock) or place_meeting(x+hsp * move,y,o_whiteblock) or place_meeting(x+hsp * move,y,o_iceblock) or place_meeting(x+hsp * move,y,o_box) or place_meeting(x+hsp * move,y,o_boxwithammo) or place_meeting(x+hsp * move,y,o_boxwithinfiniteammo) {
horizontal = 1
} else { horizontal = 0 }

if noreaction = 1 {
reactiontime = 0	
}

if horizontal = 1 {
move = 0
x -= move
}
if place_meeting(x,y,o_water) { inwater = 2 } else { inwater = 1 }
vsp = (vsp + (grv/inwater));
var solid_collision = place_meeting(x,y+vsp,o_redblock) or place_meeting(x,y+vsp,o_yellowblock) or place_meeting(x,y+vsp,o_greenblock) or place_meeting(x,y+vsp,o_blueblock) or place_meeting(x,y+vsp,o_whiteblock) or place_meeting(x,y+vsp,o_redblockmove) or place_meeting(x,y+vsp,o_yellowblockmove) or place_meeting(x,y+vsp,o_greenblockmove) or place_meeting(x,y+vsp,o_blueblockmove) or place_meeting(x,y+vsp,o_whiteblockmove) or place_meeting(x,y+vsp,o_iceblock) or place_meeting(x,y+vsp,o_box) or place_meeting(x,y+vsp,o_boxwithammo) or place_meeting(x,y+vsp,o_boxwithinfiniteammo);

var oneway_collision = false;
if vsp > 0 {
    if place_meeting(x, y+vsp, o_onewayupblock) {
        var platform = instance_place(x, y+vsp, o_onewayupblock);
        if platform != noone {
            if bbox_bottom <= platform.bbox_top {
                oneway_collision = true;
            }
        }
    }
}

if solid_collision or oneway_collision { 
	vsp = 0 
	onground = 1
	}
y = y + vsp * (60 / global.maxfps)
if state != 2 {
if vsp > 30 * (60/global.maxfps) { vsp = 30 * (60/global.maxfps) }
if bored = 0 {
if instance_exists(o_player) {	
if cansee = 0 {
if distance_to_object(o_player) < 100 {
state = 1
if reactiontime >= 0 {
reactiontime -= 1 * (60 / global.maxfps)
}
if troopsound < 2 { scr_troopvoiceline() }
}}
if distance_to_object(o_player) > 150 {
state = 0
if reactiontime <= 30 {
reactiontime += 0.05 * (60 / global.maxfps)
}
reactiontime += 1 * (60 / global.maxfps)
if troopsound < 2 { scr_troopvoiceline() }
}}}
x += ((hsp * move) * (60/global.maxfps)) / inwater
if bored = 0 {
if state = 1 {
if instance_exists(o_player) {	
if x < o_player.x { move = 1 }
if x > o_player.x { move = -1 }

if place_meeting(x,y+1,o_redblock) or place_meeting(x,y+1,o_yellowblock) or place_meeting(x,y+1,o_greenblock) or place_meeting(x,y+1,o_blueblock) or place_meeting(x,y+1,o_whiteblock) or place_meeting(x,y+1,o_iceblock) or place_meeting(x,y+1,o_box) or place_meeting(x,y+1,o_boxwithinfiniteammo) or place_meeting(x,y+1,o_boxwithammo) or place_meeting(x,y+1,o_movingplatforms) {
if o_player.y < y + 20 {
if place_meeting(x+20,y-1,o_redblock) or place_meeting(x+20,y-1,o_yellowblock) or place_meeting(x+20,y-1,o_greenblock) or place_meeting(x+20,y-1,o_blueblock) or place_meeting(x+20,y-1,o_whiteblock) or place_meeting(x+20,y-1,o_iceblock) or place_meeting(x+20,y-1,o_box) or place_meeting(x+20,y-1,o_boxwithammo) or place_meeting(x+20,y-1,o_boxwithinfiniteammo) or place_meeting(x+20,y-1,o_movingplatforms) { jump() }
if place_meeting(x-20,y-1,o_redblock) or place_meeting(x-20,y-1,o_yellowblock) or place_meeting(x-20,y-1,o_greenblock) or place_meeting(x-20,y-1,o_blueblock) or place_meeting(x-20,y-1,o_whiteblock) or place_meeting(x-20,y-1,o_iceblock) or place_meeting(x-20,y-1,o_box) or place_meeting(x-20,y-1,o_boxwithammo) or place_meeting(x-20,y-1,o_boxwithinfiniteammo) or place_meeting(x-20,y-1,o_movingplatforms) { jump() }
}}}

if instance_exists(o_player) {
if o_player.y < y - 60 {
if place_meeting(x,y+1,o_redblock) or place_meeting(x,y+1,o_movingplatforms) or place_meeting(x,y+1,o_yellowblock) or place_meeting(x,y+1,o_greenblock) or place_meeting(x,y+1,o_blueblock) or place_meeting(x,y+1,o_whiteblock) or place_meeting(x,y+1,o_shooter) or place_meeting(x,y+1,o_shooterright) or place_meeting(x,y+1,o_iceblock) or place_meeting(x,y+1,o_box) or place_meeting(x,y+1,o_boxwithammo) or place_meeting(x,y+1,o_boxwithinfiniteammo){
if !place_meeting(x,y-32,o_redblock) or place_meeting(x,y-32,o_movingplatforms) or !place_meeting(x,y-32,o_yellowblock) or !place_meeting(x,y-32,o_greenblock) or !place_meeting(x,y-32,o_blueblock) or !place_meeting(x,y-32,o_whiteblock) or !place_meeting(x,y-32,o_shooter) or !place_meeting(x,y-32,o_shooterright) or !place_meeting(x,y-32,o_iceblock) or !place_meeting(x,y-32,o_box) or !place_meeting(x,y-32,o_boxwithinfiniteammo) or !place_meeting(x,y-32,o_boxwithammo){
if reactiontime < 0 {
	jump()
}
	}}
	}
}}}

if place_meeting(x+16,y,o_onewayleftblock) {
move = -1	
}
if place_meeting(x-16,y,o_onewayrightblock) {
move = 1	
}
if place_meeting(x+16,y,o_movingplatforms) {
move = -1	
}
if place_meeting(x-16,y,o_movingplatforms) {
move = 1	
}
if place_meeting(x-16,y,o_movingplatforms) and place_meeting(x+16,y,o_movingplatforms)  {
move = 0
}

if instance_exists(o_boredomblock) {
if state = 0 {
if move = 0 {
if place_meeting(x,y,o_boredomblock) {
if o_boredomblock.image_index = 2 {
if distance_to_object(o_boredomblock) < 50{
	
if !place_meeting(x+hsp * move+4,y,o_redblock) or !place_meeting(x+hsp * move+4,y,o_yellowblock) or !place_meeting(x+hsp * move+4,y,o_greenblock) or !place_meeting(x+hsp * move+4,y,o_greenblock) or !place_meeting(x+hsp * move+4,y,o_blueblock) or !place_meeting(x+hsp * move+4,y,o_whiteblock) or !place_meeting(x+hsp * move+4,y,o_iceblock) or !place_meeting(x+hsp * move+4,y,o_box) or !place_meeting(x+hsp * move+4,y,o_boxwithammo) or !place_meeting(x+hsp * move+4,y,o_boxwithinfiniteammo){
move = irandom_range(1,-1)
if !place_meeting(x-40,y,o_redblock) or !place_meeting(x-40,y,o_yellowblock) or !place_meeting(x-40,y,o_greenblock) or !place_meeting(x-40,y,o_blueblock) or !place_meeting(x-40,y,o_whiteblock) or !place_meeting(x-40,y,o_iceblock) or !place_meeting(x-40,y,o_box) or !place_meeting(x-40,y,o_boxwithammo) or !place_meeting(x-40,y,o_boxwithinfiniteammo) { 
move = -1 
randomize()
rngjump = irandom_range(0,2)
if rngjump = 2 {
if !place_meeting(x,y-32,o_redblock) or !place_meeting(x,y-32,o_yellowblock) or !place_meeting(x,y-32,o_greenblock) or !place_meeting(x,y-32,o_blueblock) or !place_meeting(x,y-32,o_whiteblock) or !place_meeting(x,y-32,o_iceblock) or !place_meeting(x,y-32,o_box) or !place_meeting(x,y-32,o_boxwithammo) or !place_meeting(x,y-32,o_boxwithinfiniteammo){
if place_meeting(x,y+1,o_redblock) or place_meeting(x,y+1,o_yellowblock) or place_meeting(x,y+1,o_greenblock) or place_meeting(x,y+1,o_blueblock) or place_meeting(x,y+1,o_whiteblock) or place_meeting(x,y+1,o_iceblock) or place_meeting(x,y+1,o_box) or place_meeting(x,y+1,o_boxwithammo) or place_meeting(x,y+1,o_boxwithinfiniteammo){jump()}}
}}

if place_meeting(x,y+1,o_redblock) or place_meeting(x,y+1,o_yellowblock) or place_meeting(x,y+1,o_greenblock) or place_meeting(x,y+1,o_blueblock) or place_meeting(x,y+1,o_whiteblock) or place_meeting(x,y+1,o_iceblock) or place_meeting(x,y+1,o_box) or place_meeting(x,y+1,o_boxwithinfiniteammo) or place_meeting(x,y+1,o_boxwithammo){
if !place_meeting(x,y-32,o_redblock) or !place_meeting(x,y-32,o_yellowblock) or !place_meeting(x,y-32,o_greenblock) or !place_meeting(x,y-32,o_blueblock) or !place_meeting(x,y-32,o_whiteblock) or !place_meeting(x,y-32,o_iceblock) or !place_meeting(x,y-32,o_box) or !place_meeting(x,y-32,o_boxwithammo) or !place_meeting(x,y-32,o_boxwithinfiniteammo){
if instance_exists(o_player) {
if o_player.y  < y {
if place_meeting(x+20,y-1,o_redblock) or place_meeting(x+20,y-1,o_yellowblock) or place_meeting(x+20,y-1,o_greenblock) or place_meeting(x+20,y-1,o_blueblock) or place_meeting(x+20,y-1,o_whiteblock) or place_meeting(x+20,y-1,o_iceblock) or place_meeting(x+20,y-1,o_box) or place_meeting(x+20,y-1,o_boxwithammo) or place_meeting(x+20,y-1,o_boxwithinfiniteammo) { jump() }
if place_meeting(x-20,y-1,o_redblock) or place_meeting(x-20,y-1,o_yellowblock) or place_meeting(x-20,y-1,o_greenblock) or place_meeting(x-20,y-1,o_blueblock) or place_meeting(x-20,y-1,o_whiteblock) or place_meeting(x-20,y-1,o_iceblock) or place_meeting(x-20,y-1,o_box) or place_meeting(x-20,y-1,o_boxwithammo) or place_meeting(x-20,y-1,o_boxwithinfiniteammo){ jump() }
}}}}

if !place_meeting(x+40,y,o_redblock) or !place_meeting(x+40,y,o_yellowblock) or !place_meeting(x+40,y,o_greenblock) or !place_meeting(x+40,y,o_blueblock) or !place_meeting(x+40,y,o_whiteblock) or !place_meeting(x+40,y,o_blueblock) or !place_meeting(x+40,y,o_whiteblock) or !place_meeting(x+40,y,o_iceblock) or !place_meeting(x+40,y,o_box) or !place_meeting(x+40,y,o_boxwithammo) or !place_meeting(x+40,y,o_boxwithinfiniteammo){
rngjump = irandom_range(0,2)
if rngjump = 2 {
if !place_meeting(x,y-32,o_redblock) or !place_meeting(x,y-32,o_yellowblock) or !place_meeting(x,y-32,o_greenblock) or !place_meeting(x,y-32,o_blueblock) or !place_meeting(x,y-32,o_whiteblock) or !place_meeting(x,y-32,o_iceblock) or !place_meeting(x,y-32,o_box) or !place_meeting(x,y-32,o_boxwithammo) or !place_meeting(x,y-32,o_boxwithinfiniteammo){	
if place_meeting(x,y+1,o_redblock) or place_meeting(x,y+1,o_yellowblock) or place_meeting(x,y+1,o_greenblock) or place_meeting(x,y+1,o_blueblock) or place_meeting(x,y+1,o_whiteblock) or place_meeting(x,y+1,o_iceblock) or place_meeting(x,y+1,o_box) or place_meeting(x,y+1,o_boxwithammo) or place_meeting(x,y+1,o_boxwithinfiniteammo) {jump()}	}	
	move = 1 
	}}
}

}}}
if move = 1 {
if distance_to_object(o_boredomblock) > 50 {
move = 0
}}}

if state = 1 {
if place_meeting(x,y,o_boredomblock) {
if o_boredomblock.image_index = 2 {
if distance_to_object(o_boredomblock) < 50{
	
if !place_meeting(x+hsp * move+4,y,o_redblock) or !place_meeting(x+hsp * move+4,y,o_yellowblock) or !place_meeting(x+hsp * move+4,y,o_greenblock) or !place_meeting(x+hsp * move+4,y,o_blueblock) or !place_meeting(x+hsp * move+4,y,o_whiteblock) or !place_meeting(x+hsp * move+4,y,o_iceblock) or !place_meeting(x+hsp * move+4,y,o_box) or !place_meeting(x+hsp * move+4,y,o_boxwithammo) or !place_meeting(x+hsp * move+4,y,o_boxwithinfiniteammo) {	
rngjump = irandom_range(1,2)
if rngjump = 2 {
if place_meeting(x,y+1,o_redblock) or place_meeting(x,y+1,o_yellowblock) or place_meeting(x,y+1,o_greenblock) or place_meeting(x,y+1,o_blueblock) or place_meeting(x,y+1,o_whiteblock) or place_meeting(x,y+1,o_iceblock) or place_meeting(x,y+1,o_box) or place_meeting(x,y+1,o_boxwithammo) or place_meeting(x,y+1,o_boxwithinfiniteammo) {jump()}}
}

}}}}
}}

if state = 1 {
boredchasing += 1 * (60 / global.maxfps)
}
if boredchasing > 500 * (60/global.maxfps) {
state = 0
if troopsound < 2 { scr_troopvoiceline() }
bored = 1
}
if bored = 1 {
boredchasing -= 1 * (60/global.maxfps)
if cansee =	0 {
if instance_exists(o_player) {
if y = o_player.y { boredchasing -= 4 * (60/global.maxfps)}
}}
}
if boredchasing < 0 {
if cansee =	0 {
state = 1
}
if troopsound < 2 { scr_troopvoiceline() }
bored = 0
}
}

if y > room_height {instance_destroy()}
if instance_exists(o_playerdeadLE) {instance_destroy()	}
if place_meeting(x,y,o_deathblock) {instance_destroy()	}
if state = 2 {
if cansee = 0 {
if instance_exists(o_player) {	
if distance_to_object(o_player) < 100 {
state = 1	
}}}
}
if preparedforbullet > 0 { preparedforbullet -= 1 * (60/global.maxfps) }
if state != 1 {
if bored = 0 {
if onground = 1 {
if preparedforbullet < 50 {
if place_meeting(x+70,y+1,o_playerbullet) or place_meeting(x-70,y+1,o_playerbullet) {
jump()
preparedforbullet += irandom_range(10* (60 / global.maxfps),50* (60 / global.maxfps))
state = 1
}

if deaf = 0 { //Deaf System
if distance_to_object(o_lastshotplayer) < 128 {
state = 1
if troopsound < 2 { scr_troopvoiceline() }
}}


}}}}

if troopsound > 0 { troopsound -= 1 * (60/global.maxfps) }

if global.biglevelperfsettings < 1 { exit }
instance_activate_region(x-50,y-50+vsp,x+50,y+50,true)