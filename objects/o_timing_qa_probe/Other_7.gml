if (!timing_is_tick()) exit;
// Real native Animation End only; main applies the production event guard.
if (!timing_qa_active()) exit;
++timingqa_animation_count;
timing_qa_event("animation-end", id);
