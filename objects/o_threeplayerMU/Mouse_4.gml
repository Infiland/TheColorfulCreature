if global.multiplayerplayers = 1 {
global.multiplayerplayers = 3
instance_create(x,y,o_playerskinselectionMU)
instance_create(x,y,o_playerhatselectionMU)
instance_create(x,y,o_playeritemselectionMU)
if !instance_exists(o_skinsselectbuttonMU) {instance_create(176,320,o_skinsselectbuttonMU)}
if !instance_exists(o_hatsselectbuttonMU) {instance_create(256,320,o_hatsselectbuttonMU)}
if !instance_exists(o_itemsselectbuttonMU) {instance_create(336,320,o_itemsselectbuttonMU)}
}