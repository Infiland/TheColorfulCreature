// While Steam owns an outstanding request, keep its handler alive. Completed
// publication can return directly to the editor; no restart is necessary.
if (state == "finished") instance_destroy();
