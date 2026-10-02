if (variable_global_exists("timing_qa") && is_struct(global.timing_qa)
    && global.timing_qa.nostep_instance == id) global.timing_qa.nostep_destroyed = true;
if (timing_qa_active() && variable_instance_exists(id, "timingqa_begin_count"))
    timing_qa_event("cleanup", id);
