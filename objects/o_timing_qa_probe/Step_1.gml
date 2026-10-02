// Raw native Begin observer; intentionally exempt from logical event guards.
if (!timing_qa_active()) exit;
++timingqa_begin_count;
timing_qa_sample_instance("instance-begin", id);
