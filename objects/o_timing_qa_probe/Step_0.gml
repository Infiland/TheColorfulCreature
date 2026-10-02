if (!timing_instance_step()) exit;
// Main applies the production fixed-tick guard to this native Step body.
if (!timing_qa_active()) exit;
timing_qa_actor_step();
