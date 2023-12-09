if global.multiplayerplayers = 1 {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
} else { x = lerp(x,-400,0.2 * (60 / global.maxfps)) }