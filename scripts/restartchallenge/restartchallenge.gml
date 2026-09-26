function restartchallenge() {
    if (global.challenges != 1 || global.workshop != 0) return;
    var _id = global.currentchallenge;
    resetgeneral();
    scr_challenge_start(_id);
    audio_group_set_gain(Music, global.musicvolume, 1000);
}
