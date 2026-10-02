if (!timing_instance_step()) exit;
var _available = CER_start_availability();
islvl = _available.levels;
ismus = _available.music;
image_alpha = islvl && ismus ? 1 : 0.5;

if global.CESConfigure = 1 {
x = lerp(x,xstart,0.2 * (60 / global.maxfps))
} else {
x = lerp(x,-300,0.2 * (60 / global.maxfps))
}
