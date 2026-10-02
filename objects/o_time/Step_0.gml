// Challenge and authored winning-time clocks follow simulation. Session clocks
// follow actual wall time, including render-only frames, once per outer frame.
var _wall_seconds = 0;
var _render = timing_render_id();
if (!variable_instance_exists(id, "timing_time_last_render") || timing_time_last_render != _render) {
    timing_time_last_render = _render;
    _wall_seconds = timing_render_elapsed_seconds();
}
var _gameplay_seconds = 0;
if (timing_is_tick()) {
    var _tick = timing_tick_id();
    if (!variable_instance_exists(id, "timing_time_last_tick") || timing_time_last_tick != _tick) {
        timing_time_last_tick = _tick;
        _gameplay_seconds = timing_tick_seconds();
    }
}
if (global.pause == 0) {
    if (room != r_tale && !instance_exists(o_hatshopmenu)) {
        global.time += _gameplay_seconds;
        global.androidadtimer -= _wall_seconds;
    }
} else {
    pausetime += _wall_seconds;
    if (global.androidadtimer > 300) global.androidadtimer += 0.6 * _wall_seconds;
}
if (room == r_leveleditor) global.LESavedWinTime += _gameplay_seconds;
increase_stat("totaltime", "QUESTtime", _wall_seconds);
if (global.wheeltimeleft >= 0) global.wheeltimeleft -= _wall_seconds;
