if (!timing_instance_step()) exit;
if (state != "finished") {
    wait_seconds += 1 / max(1, global.maxfps);
    if (wait_seconds > 120) { result = 4; state = "finished"; }
} else {
    timer = max(0, timer - 60 / max(1, global.maxfps));
    if (timing_keyboard_pressed(vk_enter) || timing_keyboard_pressed(vk_escape)) instance_destroy();
}
