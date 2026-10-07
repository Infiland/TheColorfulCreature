declarecustombutton();
visible = !platform_touch() || gamepad_remap_active_device() >= 0;
controls = 0;
globalvar editcontrols;
editcontrols = -1;
drawtext = "";
drawcontrols = "";
controlschoose = global.controlsmoveright;
ischanging = false;
capture_armed = false;
capture_device = -1;
capture_device_generation = 0;
depth = -1000000000;

capture_hint = "";

mobile_card_width = 464;
mobile_card_height = 108;
if (platform_mobile()) visible = false; // First Step assigns the active page and hit area.
