if (!timing_is_tick()) exit;
hp -= 1;
if (hp <= 0) {
    scr_troop_defeat(true);
} else {
    audio_play_sound(snd_bang, 10, 0, 0.5);
}
