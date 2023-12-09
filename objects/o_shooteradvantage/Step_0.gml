if instance_exists(o_bulletright) {
image_index = 1	
}
else
{ image_index = 0 }

if hp < 0 {
image_index = 2
image_speed = 0.1
if image_index = 0 {
image_index = 2	
}
}