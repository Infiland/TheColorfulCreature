if (!timing_is_tick()) exit;
// The other side of a genuine native collision; guarded by main's policy.
if (!timing_qa_active()) exit;
++timingqa_collision_count;
timing_qa_event("collision-partner", id, {otherId:other.id, otherRole:other.timingqa_role});
