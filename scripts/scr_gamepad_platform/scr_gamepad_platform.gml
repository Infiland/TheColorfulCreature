#macro TCC_APPSTORE_GAMEPAD false
#macro MacAppStore:TCC_APPSTORE_GAMEPAD true

function tcc_gamepad_button_index(_button) {
    switch (_button) {
        case gp_face1: return 0; case gp_face2: return 1;
        case gp_face3: return 2; case gp_face4: return 3;
        case gp_shoulderl: return 4; case gp_shoulderr: return 5;
        case gp_shoulderlb: return 6; case gp_shoulderrb: return 7;
        case gp_select: return 8; case gp_start: return 9;
        case gp_stickl: return 10; case gp_stickr: return 11;
        case gp_padu: return 12; case gp_padd: return 13;
        case gp_padl: return 14; case gp_padr: return 15;
    }
    return -1;
}

function tcc_gamepad_is_connected(_device) {
    if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) return tcc_gc_connected(_device) == 1;
    return gamepad_is_connected(_device);
}

function tcc_gamepad_button_held_raw(_device, _button) {
    if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) return tcc_gc_button(_device, tcc_gamepad_button_index(_button), 0) == 1;
    return gamepad_button_check(_device, _button);
}

function tcc_gamepad_button_check(_device, _button) {
    var _index = tcc_gamepad_button_index(_button);
    return tcc_gamepad_button_held_raw(_device, _button) || (variable_global_exists("tcc_timing")
        && timing_is_tick() && _device >= 0 && _device < 16 && _index >= 0
        && global.tcc_timing.pads_pressed[_device][_index]);
}

function tcc_gamepad_button_pressed_raw(_device, _button) {
    if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) return tcc_gc_button(_device, tcc_gamepad_button_index(_button), 1) == 1;
    return gamepad_button_check_pressed(_device, _button);
}

function tcc_gamepad_button_released_raw(_device, _button) {
    if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) return tcc_gc_button(_device, tcc_gamepad_button_index(_button), 2) == 1;
    return gamepad_button_check_released(_device, _button);
}

function tcc_gamepad_button_check_pressed(_device, _button) {
    return timing_pad_pressed(_device, _button);
}
function tcc_gamepad_button_check_released(_device, _button) {
    return timing_pad_released(_device, _button);
}

function tcc_gamepad_axis_value(_device, _axis) {
    if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) {
        switch (_axis) {
            case gp_axislh: return tcc_gc_axis(_device, 0);
            case gp_axislv: return tcc_gc_axis(_device, 1);
            case gp_axisrh: return tcc_gc_axis(_device, 2);
            case gp_axisrv: return tcc_gc_axis(_device, 3);
        }
        return 0;
    }
    return gamepad_axis_value(_device, _axis);
}
