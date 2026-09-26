if (privacy_open && tcc_privacy_options_state() != 1) {
    privacy_open = false;
    next_load = current_time + 1000;
    consent_finished();
}
if (current_time >= next_load) {
    if (global.ad_reward_unsaved) global.ad_reward_unsaved = !scr_savestats();
    next_load = current_time + 60000;
    if (!ready && consent_done && !privacy_open) consent_finished();
    if (ready) load_ads();
}
