if (!timing_is_tick()) exit;
if zerogrv = 0 {
x += 16
y += 16
zerogrv = 1
realwalk = 0
grv = 0
}
passblockcooldown = 10
if customskin != 1 { sprite_set_offset(sprite_index,16,16) }
mask_index = s_flyingcollision
