hp -= 1
if hp = 0 {
	if room = r_boss1 {
instance_create(834,608,o_door)
	}
if room != r_lvl100 {
audio_play_sound(m_bosswin,5,0)
}
instance_destroy()
}