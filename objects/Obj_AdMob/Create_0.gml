if (!platform_admob()) { instance_destroy(); exit; }
ready = false;
initializing = false;
consent_done = false;
privacy_open = false;
reward_handle = -1;
interstitial_handle = -1;
reward_loading = false;
interstitial_loading = false;
showing = false;
banner_created = false;
banner_wanted = false;
next_load = 0;
next_interstitial = current_time + 180000;
reward_session = undefined;
ad_generation = 0;
global.ad_reward_unsaved = false;

load_ads = function() {
    if (!ready || showing || privacy_open || !tcc_consent_can_request_ads()) return;
    next_load = current_time + 60000;
    if (reward_handle == -1 && !reward_loading) {
        reward_loading = true;
        var _result = admob_rewarded_video_load(method({controller:id, generation:ad_generation}, function(_result, _handle = -1) {
            if (!instance_exists(controller)) { if (_result.success) admob_rewarded_video_dispose(_handle); return; }
            if (generation == controller.ad_generation) controller.reward_loading = false;
            if (!_result.success) return;
            if (generation != controller.ad_generation || controller.privacy_open || !tcc_consent_can_request_ads())
                admob_rewarded_video_dispose(_handle);
            else controller.reward_handle = _handle;
        }), undefined);
        if (_result != AdMobError.Ok) reward_loading = false;
    }
    if (platform_google_play() && interstitial_handle == -1 && !interstitial_loading) {
        interstitial_loading = true;
        var _result = admob_interstitial_load(method({controller:id, generation:ad_generation}, function(_result, _handle = -1) {
            if (!instance_exists(controller)) { if (_result.success) admob_interstitial_dispose(_handle); return; }
            if (generation == controller.ad_generation) controller.interstitial_loading = false;
            if (!_result.success) return;
            if (generation != controller.ad_generation || controller.privacy_open || !tcc_consent_can_request_ads())
                admob_interstitial_dispose(_handle);
            else controller.interstitial_handle = _handle;
        }), undefined);
        if (_result != AdMobError.Ok) interstitial_loading = false;
    }
};

consent_finished = function() {
    consent_done = true;
    if (!tcc_consent_can_request_ads() || ready || initializing) return;
    initializing = true;
    var _result = admob_initialize(function(_result) {
        initializing = false;
        ready = _result.success;
        if (ready) load_ads();
    });
    if (_result != AdMobError.Ok) initializing = false;
};

show_reward = function() {
    if (!ready || showing || privacy_open || reward_handle == -1 || !tcc_consent_can_request_ads()) return false;
    var _handle = reward_handle;
    reward_handle = -1;
    showing = true;
    reward_session = {granted:false};
    platform_interrupt();
    // Bind a unique session to this callback, so a late callback cannot reward a subsequent ad.
    var _callback = method({controller:id, session:reward_session}, function(_result, _event = -1, _reward = undefined) {
        if (!instance_exists(controller)) return;
        if (_result.success && _event == AdMobRewardedVideoShowEvent.Reward) {
            ads_grant_reward(session);
        }
        if (!_result.success || _event == AdMobRewardedVideoShowEvent.Dismissed) {
            controller.showing = false;
            controller.next_load = current_time + 1000;
        }
    });
    var _result = admob_rewarded_video_show(_handle, _callback);
    if (_result != AdMobError.Ok) { showing = false; next_load = current_time + 60000; }
    return _result == AdMobError.Ok;
};

show_interstitial = function() {
    if (!platform_google_play() || room != r_mainmenu || !ready || showing || privacy_open
        || current_time < next_interstitial || interstitial_handle == -1 || !tcc_consent_can_request_ads()) return;
    var _handle = interstitial_handle;
    interstitial_handle = -1;
    showing = true;
    next_interstitial = current_time + 180000;
    platform_interrupt();
    var _result = admob_interstitial_show(_handle, function(_result, _event = -1) {
        if (!_result.success || _event == AdMobInterstitialShowEvent.Dismissed) {
            showing = false;
            next_load = current_time + 1000;
        }
    });
    if (_result != AdMobError.Ok) showing = false;
};

admob_targeting_max_ad_content_rating(AdMobMaxAdContentRating.General);
// UMP first. A failed request never implies permission to load an ad.
var _request = admob_consent_request_info_update(AdMobConsentDebugGeography.Disabled, function(_result) {
    if (_result.success && admob_consent_get_status() == AdMobConsentStatus.Required) {
        var _load = admob_consent_load(function(_result) {
            if (!_result.success) { consent_finished(); return; }
            platform_interrupt();
            var _show = admob_consent_show(function(_result) { consent_finished(); });
            if (_show != AdMobError.Ok) consent_finished();
        });
        if (_load != AdMobError.Ok) consent_finished();
    } else consent_finished();
});
if (_request != AdMobError.Ok) consent_finished();
