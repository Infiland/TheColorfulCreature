var givehp = hpproj
instance_destroy()

audio_play_sound(snd_bang,10,0,0.5)
var troop = instance_create(x,y-2 * (global.maxfps / 144),o_enemyplayer)
with troop {
if x > 1952 {
x = 1952
}
if x < 1088 {
x = 1088
}
if y > 608 {
y = 608
}
hp = givehp
state = 1
hasammo = 1
move = choose(1,-1)
}