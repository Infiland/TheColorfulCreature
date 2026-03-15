/// @description Clean up networking on destroy

show_debug_message("[NET] Network Manager destroyed - cleaning up")

if (global.net_active) {
	net_send_leave_info()
	net_cleanup()
}
