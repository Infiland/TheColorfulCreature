hpproj -= 1
if hpproj < 1 {
instance_destroy()

var ammo = instance_create(x,y,o_ammo)
with ammo {
containsammo = 12	
}
}