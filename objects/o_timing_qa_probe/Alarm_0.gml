if (!timing_is_tick()) exit;
// Main applies the production fixed-tick guard to this native Alarm body.
if (!timing_qa_active()) exit;
++timingqa_alarm_count;
timing_qa_event("alarm-0", id);
if (timingqa_alarm_count < 3) alarm[0] = 5;
