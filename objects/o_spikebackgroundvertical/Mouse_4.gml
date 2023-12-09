/*
if room = r_leveleditor {
if global.LEBuild = 2 {
global.LEBlockBackgroundRotation += 1
if global.LEBlockBackgroundRotation > 3 { global.LEBlockBackgroundRotation = 0 }
image_angle = 90 * global.LEBlockBackgroundRotation
if global.LEBlockBackgroundRotation = 0 { x -= 32 }
if global.LEBlockBackgroundRotation = 1 { y += 32 }
if global.LEBlockBackgroundRotation = 2 { x += 32 }
if global.LEBlockBackgroundRotation = 3 { y -= 32 }
}}