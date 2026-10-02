#macro TCC_RELEASE_VERSION "1.3.0"

#macro TCC_MOBILE_SMOKE false
#macro iOSCheck:TCC_MOBILE_SMOKE true
#macro TCC_SELF_CHECK false
#macro Check:TCC_SELF_CHECK true
#macro TCC_GAMEPLAY_QA false
#macro QA:TCC_GAMEPLAY_QA true
#macro TCC_STEAM_ANDROID false
#macro SteamAndroid:TCC_STEAM_ANDROID true
#macro TCC_STEAM true
#macro Apple:TCC_STEAM false
#macro Mobile:TCC_STEAM false

function platform_mobile() { return os_type == os_android || os_type == os_ios; }
function platform_touch() { return platform_mobile() || os_type == os_gxgames; }
function platform_steam() { return !TCC_GAMEPLAY_QA && !TCC_MOBILE_SMOKE && TCC_STEAM && !platform_mobile() && os_type != os_gxgames; }
function platform_google_play() { return !TCC_GAMEPLAY_QA && !TCC_MOBILE_SMOKE && !TCC_STEAM_ANDROID && os_type == os_android; }
function platform_apple() { return !TCC_GAMEPLAY_QA && !TCC_MOBILE_SMOKE && !TCC_STEAM && (os_type == os_ios || os_type == os_macosx); }
function platform_admob() { return !TCC_GAMEPLAY_QA && !TCC_MOBILE_SMOKE && !TCC_STEAM_ANDROID && platform_mobile(); }

// Diagnostic builds stay silent without changing the player's stored volume.
function platform_master_gain(_gain) {
    audio_master_gain((TCC_GAMEPLAY_QA || TCC_SELF_CHECK || TCC_MOBILE_SMOKE) ? 0 : _gain);
}
