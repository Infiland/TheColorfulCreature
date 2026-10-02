// Compatibility adapter for older editor callers. New browser input runs in Step.
function selectlevelCUSTOM(_index, _name) {
    var _xcam = camera_get_view_x(view_camera[0]) + 512;
    var _top = 85 + (_index mod 15) * 40;
    if (timing_mouse_released(mb_left) && point_in_rectangle(mouse_x, mouse_y, _xcam - 300, _top, _xcam + 300, _top + 30)) return level_editor_open(_name);
    return false;
}
