timer -= 1 * (60 / global.maxfps)
if timer < 0 { 
instance_create(x,y,o_lightbeambackgroundhorizontal)
timer = originaltimer
}