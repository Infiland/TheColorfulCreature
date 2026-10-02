// Real Animation End entry; no manual dispatch or animation advancement.
if (!timing_qa_active()) exit;
timingqa_raw_animation_count += 1;
timing_qa_native_entry("native-no-step-animation-end-entry", id);
if (!timing_is_tick()) exit;
timingqa_animation_count += 1;
timing_qa_event("animation-end", id);
