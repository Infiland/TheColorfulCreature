if (!timing_instance_step()) exit;
if global.chooseminigameMU = true { x = lerp(x,420,0.2 * (60 / global.maxfps)) } else { x = lerp(x,originalx,0.2 * (60 / global.maxfps)) }
mouseon = image_index