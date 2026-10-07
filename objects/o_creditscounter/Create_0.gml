p1 = 796
p2 = 970
p3 = 27
p4 = 67
credits = 0
creditsborder = 0
creditsx = 962
creditsy = 36
creditsiconx = 800
creditsicony = 32

// Mobile menu Return occupies the upper-right corner. Keep the balance and
// its optional ad action together on the left, away from the centered title.
var _mobile_menu = platform_mobile() && (room == r_gamemode || room == r_endlessrunmenu);
if (_mobile_menu) {
    p1 = 16;
    p2 = 190;
    creditsx = 182;
    creditsiconx = 20;
}

//Special Rainbow colors!
red = 255
green = 0
blue = 0
change = 0

//Border Color
colorB = make_color_rgb(255,255,255)
redB = 0
depth = -10001

if platform_touch() {
if !instance_exists(o_watchad) {
var _ad = instance_create(_mobile_menu ? 216 : 864, _mobile_menu ? 8 : 78, o_watchad);
if (_mobile_menu && instance_exists(_ad)) {
    // A secondary touch target of at least 28 points on a 320-point display.
    // Keep the sprite's proportions and stay above the animated menu title.
    _ad.image_xscale = 2.125;
    _ad.image_yscale = 2.125;
}
}}

if global.cheats = 0 {
if global.creditscurrency >= 100 { if !achievement_earned("A_SMALL_LOAN") { achievement_award("A_SMALL_LOAN") }}
if global.creditscurrency >= 1000 { if !achievement_earned("MONEY_SAVER") { achievement_award("MONEY_SAVER") }}
if global.creditscurrency >= 10000 { if !achievement_earned("THE_GLITTERING_RICH") { achievement_award("THE_GLITTERING_RICH") }}
}

ui_credits_border_color = c_white;
timing_ui_register_target("credits-display");
