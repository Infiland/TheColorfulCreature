/// @description Workshop ER persistent controller - handles async + download waits

depth = -30000
target_file_id = -1
poll_timer = 0
max_wait = 60 * 30  // 30 seconds at 60 FPS
wait_frames = 0
state = "idle"  // "idle" (async handler only), "waiting" (download in progress)
dots = 0
dot_timer = 0
