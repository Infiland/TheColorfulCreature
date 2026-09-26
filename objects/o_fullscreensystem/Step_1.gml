platform_mobile_gui();
platform_mobile_step();
if (platform_mobile()) platform_touch_step();
if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) tcc_gc_poll();
if (platform_touch() && instance_exists(global.mobile_confirmation)) {
    with (global.mobile_confirmation) mobile_confirmation_step();
}
