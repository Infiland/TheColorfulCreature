if (!timing_qa_active() || !variable_instance_exists(id, "timingqa_role")) {
    instance_destroy();
    exit;
}
timing_qa_actor_initialize();
