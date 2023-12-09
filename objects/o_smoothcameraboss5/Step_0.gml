if global.pause = 1 { exit }
if instance_exists(o_player) {
x = lerp(x,o_player.x,(0.04 + (0.02 * (o_player.vsp / 15)) * (60 / global.maxfps)))
y = lerp(y,o_player.y,(0.04 + (0.02 * (o_player.vsp / 15)) * (60 / global.maxfps)))
} else {
x = lerp(x,o_playerdead.x,(0.04 * (60 / global.maxfps)))
y = lerp(y,o_playerdead.y,(0.04 * (60 / global.maxfps)))
}

if x < newx {
x = newx	
} else {
newx = x
}