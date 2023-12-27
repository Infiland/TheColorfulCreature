image_yscale = 1.7
image_xscale = 1.7
if room = r_leveleditor {
x = mouse_x
y = mouse_y

if x > room_width {x = room_width}
if x > room_height {x = room_height}
if x < 0 {x = 0}
if y < 0 {y = 0}

if global.LEMode = 1 {if image_alpha > 0.5{image_alpha -= 0.01}}
else { if image_alpha < 1.01 { image_alpha += 0.01 }}
}

if instance_exists(o_player) {
if o_player.x < room_width {
if o_player.y < room_height {
if o_player.x > 0 {
if o_player.y > 0 {
x = o_player.x + 16
y = o_player.y
quickmaths = lerp(quickmaths,1.7 + 11.5 * o_player.torchcount,0.03)
image_xscale = lerp(image_xscale,quickmaths,0.1)
image_yscale = lerp(image_yscale,quickmaths,0.1)
if instance_exists(o_playerdead) {
x = o_playerdead.x + 16
y = o_playerdead.y
image_xscale = lerp(image_xscale,1.7,0.1)
image_yscale = lerp(image_yscale,1.7,0.1)
}}}}}}

if global.visiblethings = 1 { image_alpha = 0 }