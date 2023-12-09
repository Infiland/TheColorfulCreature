key_left = keyboard_check(vk_left)
key_right = keyboard_check(vk_right)
if global.pause = 1{ exit }
image_index = 0
if key_right { image_index = 1 }
if key_left { image_index = 2 }
if key_left and key_right { image_index = 3 }

y = lerp(y,544,0.03* (60 / global.maxfps))