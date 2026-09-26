#macro TCC_MOBILE_SMOKE false
#macro iOSCheck:TCC_MOBILE_SMOKE true
#macro TCC_SELF_CHECK false
#macro Check:TCC_SELF_CHECK true
#macro TCC_STEAM true
#macro Apple:TCC_STEAM false
#macro Mobile:TCC_STEAM false

function platform_mobile() { return os_type == os_android || os_type == os_ios; }
function platform_touch() { return platform_mobile() || os_type == os_gxgames; }
function platform_steam() { return TCC_STEAM && !platform_mobile() && os_type != os_gxgames; }
function platform_google_play() { return os_type == os_android; }
function platform_apple() { return !TCC_STEAM && (os_type == os_ios || os_type == os_macosx); }
