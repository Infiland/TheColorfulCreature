if global.endless = 1 { instance_destroy() }

y = 800
image_alpha = 1
text = 0
switch(room) {
case(r_lvl21): text = global.world1time break;
case(r_lvl41): text = global.world2time break;
case(r_lvl61): text = global.world3time break;
case(r_lvl81): text = global.world4time break;
case(r_theend): text = global.world5time break;
}
alarm[0] = 1

// Cache the pre-fade sample for repeated views of one generated Draw.
hud_last_draw_frame = -1;
hud_draw_alpha = image_alpha;
