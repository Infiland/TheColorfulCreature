if global.berserk = 0 {
instance_create(x,y,o_enemydead);
if instance_exists(o_player) {
audio_play_sound(snd_troopdead,1,0)
}
if hasammo = 1 { 
var ammo = instance_create(x,y,o_ammo)
with ammo {
containsammo = 12	
}
}

}