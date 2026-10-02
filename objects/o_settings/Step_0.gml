if (!timing_instance_step()) exit;
if rotate = 0 {
if image_angle > 0 {
	image_angle -= 10
	if move = 1 {
	x -= 2
	}
	if image_angle < 0.1 {
	image_angle = 0

	var distance = abs(x-950)

	if distance > 1000 {
		if !achievement_earned("SPINNNNN") {
			achievement_award("SPINNNNN")
		}
	}

	if x < 950 {
		platform_submit_score("Cog Distance", distance)
	} else if x < -450 {
		platform_submit_score_ext("Cog Distance", distance, true)
	}

	move = 0
	x = 960 + vx
	if room = r_mainmenu {
	y = 610 + vy
	} else {
	y = 704 + vy
	}
	}
	}}
else
{image_angle += 1}
if room != r_mainmenu {
if player_pause_pressed() {
instance_destroy()
}}
//Controller
if rotate = 1 {
var _device = gamepad_remap_active_device(true);
if (_device >= 0 && tcc_gamepad_button_check_pressed(_device,gp_face1)) {
event_perform(ev_mouse,ev_left_press)
}}
