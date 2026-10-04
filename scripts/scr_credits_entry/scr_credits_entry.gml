/// Shared normal credits entry. Ending-screen reward remains its own branch.
/// Caller uses this action; no synthetic Mouse/event dispatch is performed.
function credits_entry_action() {
    var _ending = room == r_theend;
    var _entered = false;
    if (array_contains([r_gamemode, r_support, r_theend], room)
        && !instance_exists(o_progressask)) {
        window_set_cursor(cr_default);
        sprite_set_offset(s_playerred, 16, 16);
        room_goto(r_credits);
        sprite_prefetch(s_creditsbackround);
        instance_destroy(o_star);
        scr_loadhardmode();
        _entered = true;
    }
    // Preserve reward eligibility and the prior after-load save order. This is
    // independent of the progress dialog's navigation guard, as before.
    if (_ending && global.hardmodeunlock == 0 && net_campaign_reward_allowed()) {
        global.hardmodeunlock = 1;
        scr_savehardmode();
    }
    return _entered;
}

/// Same normal support navigation used by its existing menu button.
function support_entry_action() {
    if (instance_exists(o_progressask) || instance_exists(o_quitask)) return false;
    room_goto(r_support);
    window_set_cursor(cr_default);
    audio_sound_pitch(m_mainmenu, 1);
    return true;
}
