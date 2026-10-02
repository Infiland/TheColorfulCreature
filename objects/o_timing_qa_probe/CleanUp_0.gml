// Dynamic sprites/path belong to setup, not to an individual probe. Root calls
// timing_qa_cleanup() after collecting summary, or before the next setup.
if (timing_qa_active() && variable_instance_exists(id, "timingqa_begin_count"))
    timing_qa_event("cleanup", id);
