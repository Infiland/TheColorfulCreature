// All room instance creation scripts have finished before this event. Keep the
// desktop artwork, links and actions, with reachable targets on mobile screens.
if (!platform_mobile() || room != r_mainmenu) exit;

var _cards = [o_start, o_load, o_stats, o_support, o_news, o_githubbutton];
var _previous_font = draw_get_font();
for (var _i = 0; _i < array_length(_cards); ++_i) {
    with (_cards[_i]) {
        x = 32 + (_i mod 3) * 320;
        y = 472 + floor(_i / 3) * 120;
        image_xscale = 60;
        image_yscale = 21.6;
        width = 3;
        draw_set_font(font);
        // Preserve translated text, including intentional line breaks.
        xscale = min(0.8, 272 / max(1, string_width(text)), 84 / max(1, string_height(text)));
        yscale = xscale;
        ox = 0; oy = 0;
    }
}
draw_set_font(_previous_font);

// Leave the central mascot and the quest illustration visible above the grid.
with (o_questsbutton) y = 300;
with (o_settings) {
    x = 960; y = 242;
    vx = 0; vy = y - 610; // The gear animation returns to this mobile position.
}
with (o_achievementbutton) { x = 796; y = 286; }

// Social links retain their artwork and confirmation dialogs. The 108-unit
// sprites give even the shorter Discord/YouTube masks usable secondary targets.
var _socials = [o_github, o_discord, o_youtube];
for (var _s = 0; _s < array_length(_socials); ++_s) {
    with (_socials[_s]) {
        x = 664 + _s * 116;
        y = 350;
        image_xscale = 108 / sprite_get_width(sprite_index);
        image_yscale = image_xscale;
    }
}

with (o_controllertutormenu) { x = 192; y = 184; }
// Mobile users leave the app through the operating system.
instance_destroy(o_quitgamebutton);
