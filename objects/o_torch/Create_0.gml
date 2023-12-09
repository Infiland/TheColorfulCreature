if room = r_leveleditor {
if x = 0 {
if y = 0 {
instance_destroy()	
}}}
torchholdcooldown = 3
holding = 0
gotheredead = random_range(2.5,-2.5)
fall = random_range(-1,1)
rotate = random_range(-5,5)
died = 0
if instance_exists(o_player) {
o_player.torchcount = 0
}