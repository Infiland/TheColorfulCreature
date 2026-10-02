global.tcc_timing.alarm_phase_passed = true;
timing_refresh_active(true);
timing_flush_pending();
sequence_probe_qa_step();
timing_sequence_flush();
sequence_qa_sample("root-step");
sequence_probe_qa_sample("root-step");
timing_qa_before_native("root-step-after-flush");
