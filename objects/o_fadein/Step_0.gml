if (!timing_instance_step()) exit;
yUp = lerp(yUp,390,0.12 * (60 /global.maxfps))
if yUp > 387 { instance_destroy() }