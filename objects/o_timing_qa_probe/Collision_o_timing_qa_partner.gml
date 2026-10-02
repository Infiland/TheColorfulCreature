if (!timing_is_tick()) exit;
// Real native mask collision only; main applies the production event guard.
if (!timing_qa_active()) exit;
++timingqa_collision_count;
timing_qa_event("collision-probe", id, {otherId:other.id, otherRole:other.timingqa_role});
