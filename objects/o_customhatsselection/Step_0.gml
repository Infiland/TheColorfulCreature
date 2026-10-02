if (!timing_instance_step()) exit;
var _labels = ["Custom Skins", "Custom Hats", "Custom Items"];
text = settings_text(_labels[clamp(global.customizeselect - 1, 0, 2)]);
