if instance_exists(o_placeblock) {
realx = lerp(realx,o_placeblock.x,0.5)
realy = lerp(realy,o_placeblock.y,0.5)
} else {
realx = mouse_x
realy = mouse_y
image_alpha = 0
}
x = realx
y = realy

if global.LEBuild = 3 {
sprite_index = s_redblockbackground;
}

if global.LES = 11 { shifty = -32 } else { shifty = 0 }
scr_leveleditorsprites(global.LES)

image_blend = c_white
//EPIC FX
if instance_exists(o_placeblock) {
if epicfx = 0 {image_alpha -= 0.02}
if epicfx = 1 {image_alpha += 0.02}
if image_alpha < 0.5 {epicfx = 1}
if image_alpha > 1 {epicfx = 0}
depth = -1000
if o_placeblock.sprite_index = s_cannotplace {
sprite_index = s_cannotplace
}
if global.canchange = true { sprite_index = s_canplace }
if y < 64 { image_alpha = 0 }
if global.LEBuild = 3 { image_alpha = 0 }
}

if global.LEMode = 2 { image_alpha = 0 }