if (!timing_instance_step()) exit;
if timing_keyboard_down(vk_enter) || timing_keyboard_released(vk_escape) {
instance_destroy(o_itemmenuselectLE)
instance_destroy(o_itemmenuLE)
}