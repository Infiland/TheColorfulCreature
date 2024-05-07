function scr_blockbreaksound(){
	if instance_exists(o_player) {
		if distance_to_object(o_player) < 1000 {
			var i = irandom(1)
			switch(i) {
				case(0): audio_play_sound(snd_blockbreak2,10,0) break;
				case(1): audio_play_sound(snd_blockbreak3,10,0) break;
			}
		}
	}
}