draw_set_halign(fa_center)
if global.hardmodeunlock <= 1 {
if global.hardmodeunlock > 0 {
draw_text(room_width/2,(room_height/2)-200,"That was subtle.\nAre you dissapointed in what you got?\nWell you have to work harder for A TRUE CONCLUSION\n\nBeat the game in hardmode again...")
} else {
draw_text(room_width/2,(room_height/2)-200,"You are not ready to know the truth yet.")
}}

if keyboard_check_pressed(vk_escape) {
game_restart();
}