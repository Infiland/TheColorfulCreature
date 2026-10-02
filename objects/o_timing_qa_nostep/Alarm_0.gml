// Raw entry is observational and must remain before the explicit body guard.
if (!timing_qa_active()) exit;
timingqa_raw_alarm_count += 1;
timing_qa_native_entry("native-no-step-alarm-entry", id);
if (!timing_is_tick()) exit;
timingqa_alarm_count += 1;
timing_qa_event("alarm-0", id);
if (timingqa_alarm_count < 3) alarm[0] = 5;
