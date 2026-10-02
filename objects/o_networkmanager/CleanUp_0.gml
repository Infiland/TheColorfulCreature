// Allocation starts before a lobby becomes active; every outcome releases it.
if (variable_global_exists("net_active") && global.net_active) net_send_leave_info();
net_cleanup();
