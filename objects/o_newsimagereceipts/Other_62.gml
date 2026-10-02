// Never tick-guard asynchronous receipts. The download may finish between logical ticks.
if (!ds_map_exists(async_load, "id") || !ds_map_exists(async_load, "status")) exit;
news_images_http_orphan(async_load[? "id"], async_load[? "status"]);
