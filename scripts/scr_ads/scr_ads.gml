function ads_claim_reward(_session) {
    if (!is_struct(_session) || !variable_struct_exists(_session, "granted") || _session.granted) return false;
    _session.granted = true;
    return true;
}

function ads_grant_reward(_session) {
    if (!ads_claim_reward(_session)) return false;
    global.creditscurrency += choose(20,20,20,40,40,60,20,20,20,40,40,60,20,20,20,40,40,100,69);
    global.ad_reward_unsaved = !scr_savestats();
    return true;
}

function ads_show_reward() {
    if (!instance_exists(Obj_AdMob)) return false;
    return Obj_AdMob.show_reward();
}

function ads_show_banner(_bottom = true) {
    if (!platform_google_play() || !instance_exists(Obj_AdMob)) return;
    with (Obj_AdMob) {
        if (!ready || privacy_open || !tcc_consent_can_request_ads()) exit;
        banner_wanted = true;
        if (!banner_created) {
            banner_created = true;
            var _result = admob_banner_create(AdMobBannerSize.AnchoredAdaptive, _bottom, function(_result, _event = -1) {
                if (!_result.success) banner_created = false;
                else if (banner_wanted && !privacy_open && tcc_consent_can_request_ads()) admob_banner_show();
                else admob_banner_hide();
            });
            if (_result != AdMobError.Ok) banner_created = false;
        } else admob_banner_show();
    }
}

function ads_hide_banner() {
    if (!platform_google_play() || !instance_exists(Obj_AdMob)) return;
    Obj_AdMob.banner_wanted = false;
    if (Obj_AdMob.ready) admob_banner_hide();
}

function ads_privacy_options() {
    if (!platform_admob() || !instance_exists(Obj_AdMob) || !tcc_privacy_options_required()) return;
    with (Obj_AdMob) {
        if (showing || privacy_open || consent_gathering) exit;
        ad_generation += 1;
        reward_loading = false;
        interstitial_loading = false;
        ads_hide_banner();
        if (reward_handle != -1) admob_rewarded_video_dispose(reward_handle);
        if (interstitial_handle != -1) admob_interstitial_dispose(interstitial_handle);
        reward_handle = -1;
        interstitial_handle = -1;
        platform_interrupt();
        privacy_open = tcc_privacy_options_show() == 1;
    }
}
