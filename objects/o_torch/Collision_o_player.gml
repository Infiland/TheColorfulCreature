if holding = 0 {
torchholdcooldown -= 1
}
if torchholdcooldown = 0 {
if holding = 0 { audio_play_sound(snd_torch,10,0)
if global.itempar = 1 { instance_create(x+16,y+16,o_yellowpickup) }	
}

if instance_place(x,y,o_water) { 
	o_player.torchcount = 0 
	died = 1
	}

if room != r_leveleditor { 
	}
if holding = 0 { o_player.torchcount += 1
if room = r_leveleditor { instance_change(o_torchLEfollow,1) }
if o_player.torchcount = 3 {	
instance_create(o_player.x,o_player.y,o_fire)
	}}
holding = 1
}

if holding = 0 {
	if torchholdcooldown = 1 {
	increase_stat("totaltorchpickups","QUESTtorchpickups",1)
}}