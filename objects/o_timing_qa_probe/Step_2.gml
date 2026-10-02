// Raw native End observer; root-after-native is the acceptance snapshot.
if (!timing_qa_active()) exit;
++timingqa_end_count;
timing_qa_sample_instance("instance-end", id);
