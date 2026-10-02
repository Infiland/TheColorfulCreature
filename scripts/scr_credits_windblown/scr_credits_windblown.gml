/// Credits-only windblown effect updated by the fixed gameplay clock.
/// Adapted from installed GameMaker LTS prefab
/// io.gamemaker.gm_effect_windblown_particles-1.0.0:
/// scripts/_effect_windblown_particles_script/_effect_windblown_particles_script.gml
/// Original SHA256: b422ff8abe4b69ea884cda1cad810dbf6d6f6cc38391e8224d53dce3e900f30b
/// Existing60 equations/render order retained; local RNG changes noise samples.
/// No effect assets/vendor scripts are modified. Root owns registration/hooks.

function credits_windblown_value(_record, _key, _fallback) {
    return is_struct(_record) && variable_struct_exists(_record, _key)
        ? variable_struct_get(_record, _key) : _fallback;
}
function credits_windblown_error(_error) {
    return credits_windblown_value(_error, "message", string(_error));
}
function credits_windblown_integer(_value, _low, _high) {
    return is_real(_value) && !is_bool(_value) && !is_nan(_value) && !is_infinity(_value)
        && _value == floor(_value) && _value >= _low && _value <= _high;
}

// Accept only the existing credits parameter surface, with safe native types.
// Values remain authored values; validation never clamps/normalizes them.
function credits_windblown_parameters(_source) {
    if (!is_struct(_source)) throw "Credits FX parameters are not a struct";
    var _out = {};
    if (!variable_struct_exists(_source, "param_sprite")) throw "Credits FX missing param_sprite";
    var _v_param_sprite = variable_struct_get(_source, "param_sprite");
    if (!sprite_exists(_v_param_sprite) || _v_param_sprite != s_playerred) throw "Credits FX sprite must be the authored s_playerred reference";
    variable_struct_set(_out, "param_sprite", _v_param_sprite);
    if (!variable_struct_exists(_source, "param_num_particles")) throw "Credits FX missing param_num_particles";
    var _v_param_num_particles = variable_struct_get(_source, "param_num_particles");
    if (!is_real(_v_param_num_particles) || is_bool(_v_param_num_particles) || is_nan(_v_param_num_particles) || is_infinity(_v_param_num_particles) || _v_param_num_particles < 0.0 || _v_param_num_particles > 1000.0) throw "Credits FX invalid param_num_particles";
    variable_struct_set(_out, "param_num_particles", _v_param_num_particles);
    if (!variable_struct_exists(_source, "param_particle_spawn_time")) throw "Credits FX missing param_particle_spawn_time";
    var _v_param_particle_spawn_time = variable_struct_get(_source, "param_particle_spawn_time");
    if (!is_real(_v_param_particle_spawn_time) || is_bool(_v_param_particle_spawn_time) || is_nan(_v_param_particle_spawn_time) || is_infinity(_v_param_particle_spawn_time) || _v_param_particle_spawn_time < 0.0 || _v_param_particle_spawn_time > 10000.0) throw "Credits FX invalid param_particle_spawn_time";
    variable_struct_set(_out, "param_particle_spawn_time", _v_param_particle_spawn_time);
    if (!variable_struct_exists(_source, "param_particle_spawn_all_at_start")) throw "Credits FX missing param_particle_spawn_all_at_start";
    var _v_param_particle_spawn_all_at_start = variable_struct_get(_source, "param_particle_spawn_all_at_start");
    if (!is_real(_v_param_particle_spawn_all_at_start) || is_bool(_v_param_particle_spawn_all_at_start) || is_nan(_v_param_particle_spawn_all_at_start) || is_infinity(_v_param_particle_spawn_all_at_start) || _v_param_particle_spawn_all_at_start < 0.0 || _v_param_particle_spawn_all_at_start > 1.0) throw "Credits FX invalid param_particle_spawn_all_at_start";
    variable_struct_set(_out, "param_particle_spawn_all_at_start", _v_param_particle_spawn_all_at_start);
    if (!variable_struct_exists(_source, "param_warmup_frames")) throw "Credits FX missing param_warmup_frames";
    var _v_param_warmup_frames = variable_struct_get(_source, "param_warmup_frames");
    if (!is_real(_v_param_warmup_frames) || is_bool(_v_param_warmup_frames) || is_nan(_v_param_warmup_frames) || is_infinity(_v_param_warmup_frames) || _v_param_warmup_frames < 0.0 || _v_param_warmup_frames > 100.0) throw "Credits FX invalid param_warmup_frames";
    variable_struct_set(_out, "param_warmup_frames", _v_param_warmup_frames);
    if (!variable_struct_exists(_source, "param_particle_mass_min")) throw "Credits FX missing param_particle_mass_min";
    var _v_param_particle_mass_min = variable_struct_get(_source, "param_particle_mass_min");
    if (!is_real(_v_param_particle_mass_min) || is_bool(_v_param_particle_mass_min) || is_nan(_v_param_particle_mass_min) || is_infinity(_v_param_particle_mass_min) || _v_param_particle_mass_min < 0.0 || _v_param_particle_mass_min > 5.0) throw "Credits FX invalid param_particle_mass_min";
    variable_struct_set(_out, "param_particle_mass_min", _v_param_particle_mass_min);
    if (!variable_struct_exists(_source, "param_particle_mass_max")) throw "Credits FX missing param_particle_mass_max";
    var _v_param_particle_mass_max = variable_struct_get(_source, "param_particle_mass_max");
    if (!is_real(_v_param_particle_mass_max) || is_bool(_v_param_particle_mass_max) || is_nan(_v_param_particle_mass_max) || is_infinity(_v_param_particle_mass_max) || _v_param_particle_mass_max < 0.0 || _v_param_particle_mass_max > 5.0) throw "Credits FX invalid param_particle_mass_max";
    variable_struct_set(_out, "param_particle_mass_max", _v_param_particle_mass_max);
    if (!variable_struct_exists(_source, "param_particle_start_sprite_scale")) throw "Credits FX missing param_particle_start_sprite_scale";
    var _v_param_particle_start_sprite_scale = variable_struct_get(_source, "param_particle_start_sprite_scale");
    if (!is_real(_v_param_particle_start_sprite_scale) || is_bool(_v_param_particle_start_sprite_scale) || is_nan(_v_param_particle_start_sprite_scale) || is_infinity(_v_param_particle_start_sprite_scale) || _v_param_particle_start_sprite_scale < 0.0 || _v_param_particle_start_sprite_scale > 10.0) throw "Credits FX invalid param_particle_start_sprite_scale";
    variable_struct_set(_out, "param_particle_start_sprite_scale", _v_param_particle_start_sprite_scale);
    if (!variable_struct_exists(_source, "param_particle_end_sprite_scale")) throw "Credits FX missing param_particle_end_sprite_scale";
    var _v_param_particle_end_sprite_scale = variable_struct_get(_source, "param_particle_end_sprite_scale");
    if (!is_real(_v_param_particle_end_sprite_scale) || is_bool(_v_param_particle_end_sprite_scale) || is_nan(_v_param_particle_end_sprite_scale) || is_infinity(_v_param_particle_end_sprite_scale) || _v_param_particle_end_sprite_scale < 0.0 || _v_param_particle_end_sprite_scale > 10.0) throw "Credits FX invalid param_particle_end_sprite_scale";
    variable_struct_set(_out, "param_particle_end_sprite_scale", _v_param_particle_end_sprite_scale);
    if (!variable_struct_exists(_source, "param_particle_col_1")) throw "Credits FX missing param_particle_col_1";
    var _v_param_particle_col_1 = variable_struct_get(_source, "param_particle_col_1");
    if (!is_array(_v_param_particle_col_1) || array_length(_v_param_particle_col_1) != 4) throw "Credits FX invalid param_particle_col_1 vector";
    var _copy_param_particle_col_1 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_1[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_1 channel";
        array_push(_copy_param_particle_col_1, _part);
    }
    _v_param_particle_col_1 = _copy_param_particle_col_1;
    variable_struct_set(_out, "param_particle_col_1", _v_param_particle_col_1);
    if (!variable_struct_exists(_source, "param_particle_col_alt_1")) throw "Credits FX missing param_particle_col_alt_1";
    var _v_param_particle_col_alt_1 = variable_struct_get(_source, "param_particle_col_alt_1");
    if (!is_array(_v_param_particle_col_alt_1) || array_length(_v_param_particle_col_alt_1) != 4) throw "Credits FX invalid param_particle_col_alt_1 vector";
    var _copy_param_particle_col_alt_1 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_alt_1[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_alt_1 channel";
        array_push(_copy_param_particle_col_alt_1, _part);
    }
    _v_param_particle_col_alt_1 = _copy_param_particle_col_alt_1;
    variable_struct_set(_out, "param_particle_col_alt_1", _v_param_particle_col_alt_1);
    if (!variable_struct_exists(_source, "param_particle_col_2")) throw "Credits FX missing param_particle_col_2";
    var _v_param_particle_col_2 = variable_struct_get(_source, "param_particle_col_2");
    if (!is_array(_v_param_particle_col_2) || array_length(_v_param_particle_col_2) != 4) throw "Credits FX invalid param_particle_col_2 vector";
    var _copy_param_particle_col_2 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_2[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_2 channel";
        array_push(_copy_param_particle_col_2, _part);
    }
    _v_param_particle_col_2 = _copy_param_particle_col_2;
    variable_struct_set(_out, "param_particle_col_2", _v_param_particle_col_2);
    if (!variable_struct_exists(_source, "param_particle_col_alt_2")) throw "Credits FX missing param_particle_col_alt_2";
    var _v_param_particle_col_alt_2 = variable_struct_get(_source, "param_particle_col_alt_2");
    if (!is_array(_v_param_particle_col_alt_2) || array_length(_v_param_particle_col_alt_2) != 4) throw "Credits FX invalid param_particle_col_alt_2 vector";
    var _copy_param_particle_col_alt_2 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_alt_2[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_alt_2 channel";
        array_push(_copy_param_particle_col_alt_2, _part);
    }
    _v_param_particle_col_alt_2 = _copy_param_particle_col_alt_2;
    variable_struct_set(_out, "param_particle_col_alt_2", _v_param_particle_col_alt_2);
    if (!variable_struct_exists(_source, "param_particle_col_2_pos")) throw "Credits FX missing param_particle_col_2_pos";
    var _v_param_particle_col_2_pos = variable_struct_get(_source, "param_particle_col_2_pos");
    if (!is_real(_v_param_particle_col_2_pos) || is_bool(_v_param_particle_col_2_pos) || is_nan(_v_param_particle_col_2_pos) || is_infinity(_v_param_particle_col_2_pos) || _v_param_particle_col_2_pos < 0.0 || _v_param_particle_col_2_pos > 1.0) throw "Credits FX invalid param_particle_col_2_pos";
    variable_struct_set(_out, "param_particle_col_2_pos", _v_param_particle_col_2_pos);
    if (!variable_struct_exists(_source, "param_particle_col_enabled_2")) throw "Credits FX missing param_particle_col_enabled_2";
    var _v_param_particle_col_enabled_2 = variable_struct_get(_source, "param_particle_col_enabled_2");
    if (!is_real(_v_param_particle_col_enabled_2) || is_bool(_v_param_particle_col_enabled_2) || is_nan(_v_param_particle_col_enabled_2) || is_infinity(_v_param_particle_col_enabled_2) || _v_param_particle_col_enabled_2 < 0.0 || _v_param_particle_col_enabled_2 > 1.0) throw "Credits FX invalid param_particle_col_enabled_2";
    variable_struct_set(_out, "param_particle_col_enabled_2", _v_param_particle_col_enabled_2);
    if (!variable_struct_exists(_source, "param_particle_col_3")) throw "Credits FX missing param_particle_col_3";
    var _v_param_particle_col_3 = variable_struct_get(_source, "param_particle_col_3");
    if (!is_array(_v_param_particle_col_3) || array_length(_v_param_particle_col_3) != 4) throw "Credits FX invalid param_particle_col_3 vector";
    var _copy_param_particle_col_3 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_3[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_3 channel";
        array_push(_copy_param_particle_col_3, _part);
    }
    _v_param_particle_col_3 = _copy_param_particle_col_3;
    variable_struct_set(_out, "param_particle_col_3", _v_param_particle_col_3);
    if (!variable_struct_exists(_source, "param_particle_col_alt_3")) throw "Credits FX missing param_particle_col_alt_3";
    var _v_param_particle_col_alt_3 = variable_struct_get(_source, "param_particle_col_alt_3");
    if (!is_array(_v_param_particle_col_alt_3) || array_length(_v_param_particle_col_alt_3) != 4) throw "Credits FX invalid param_particle_col_alt_3 vector";
    var _copy_param_particle_col_alt_3 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_alt_3[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_alt_3 channel";
        array_push(_copy_param_particle_col_alt_3, _part);
    }
    _v_param_particle_col_alt_3 = _copy_param_particle_col_alt_3;
    variable_struct_set(_out, "param_particle_col_alt_3", _v_param_particle_col_alt_3);
    if (!variable_struct_exists(_source, "param_particle_col_3_pos")) throw "Credits FX missing param_particle_col_3_pos";
    var _v_param_particle_col_3_pos = variable_struct_get(_source, "param_particle_col_3_pos");
    if (!is_real(_v_param_particle_col_3_pos) || is_bool(_v_param_particle_col_3_pos) || is_nan(_v_param_particle_col_3_pos) || is_infinity(_v_param_particle_col_3_pos) || _v_param_particle_col_3_pos < 0.0 || _v_param_particle_col_3_pos > 1.0) throw "Credits FX invalid param_particle_col_3_pos";
    variable_struct_set(_out, "param_particle_col_3_pos", _v_param_particle_col_3_pos);
    if (!variable_struct_exists(_source, "param_particle_col_enabled_3")) throw "Credits FX missing param_particle_col_enabled_3";
    var _v_param_particle_col_enabled_3 = variable_struct_get(_source, "param_particle_col_enabled_3");
    if (!is_real(_v_param_particle_col_enabled_3) || is_bool(_v_param_particle_col_enabled_3) || is_nan(_v_param_particle_col_enabled_3) || is_infinity(_v_param_particle_col_enabled_3) || _v_param_particle_col_enabled_3 < 0.0 || _v_param_particle_col_enabled_3 > 1.0) throw "Credits FX invalid param_particle_col_enabled_3";
    variable_struct_set(_out, "param_particle_col_enabled_3", _v_param_particle_col_enabled_3);
    if (!variable_struct_exists(_source, "param_particle_col_4")) throw "Credits FX missing param_particle_col_4";
    var _v_param_particle_col_4 = variable_struct_get(_source, "param_particle_col_4");
    if (!is_array(_v_param_particle_col_4) || array_length(_v_param_particle_col_4) != 4) throw "Credits FX invalid param_particle_col_4 vector";
    var _copy_param_particle_col_4 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_4[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_4 channel";
        array_push(_copy_param_particle_col_4, _part);
    }
    _v_param_particle_col_4 = _copy_param_particle_col_4;
    variable_struct_set(_out, "param_particle_col_4", _v_param_particle_col_4);
    if (!variable_struct_exists(_source, "param_particle_col_alt_4")) throw "Credits FX missing param_particle_col_alt_4";
    var _v_param_particle_col_alt_4 = variable_struct_get(_source, "param_particle_col_alt_4");
    if (!is_array(_v_param_particle_col_alt_4) || array_length(_v_param_particle_col_alt_4) != 4) throw "Credits FX invalid param_particle_col_alt_4 vector";
    var _copy_param_particle_col_alt_4 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_particle_col_alt_4[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_particle_col_alt_4 channel";
        array_push(_copy_param_particle_col_alt_4, _part);
    }
    _v_param_particle_col_alt_4 = _copy_param_particle_col_alt_4;
    variable_struct_set(_out, "param_particle_col_alt_4", _v_param_particle_col_alt_4);
    if (!variable_struct_exists(_source, "param_particle_initial_velocity_range_x_min")) throw "Credits FX missing param_particle_initial_velocity_range_x_min";
    var _v_param_particle_initial_velocity_range_x_min = variable_struct_get(_source, "param_particle_initial_velocity_range_x_min");
    if (!is_real(_v_param_particle_initial_velocity_range_x_min) || is_bool(_v_param_particle_initial_velocity_range_x_min) || is_nan(_v_param_particle_initial_velocity_range_x_min) || is_infinity(_v_param_particle_initial_velocity_range_x_min) || _v_param_particle_initial_velocity_range_x_min < -10000.0 || _v_param_particle_initial_velocity_range_x_min > 10000.0) throw "Credits FX invalid param_particle_initial_velocity_range_x_min";
    variable_struct_set(_out, "param_particle_initial_velocity_range_x_min", _v_param_particle_initial_velocity_range_x_min);
    if (!variable_struct_exists(_source, "param_particle_initial_velocity_range_x_max")) throw "Credits FX missing param_particle_initial_velocity_range_x_max";
    var _v_param_particle_initial_velocity_range_x_max = variable_struct_get(_source, "param_particle_initial_velocity_range_x_max");
    if (!is_real(_v_param_particle_initial_velocity_range_x_max) || is_bool(_v_param_particle_initial_velocity_range_x_max) || is_nan(_v_param_particle_initial_velocity_range_x_max) || is_infinity(_v_param_particle_initial_velocity_range_x_max) || _v_param_particle_initial_velocity_range_x_max < -10000.0 || _v_param_particle_initial_velocity_range_x_max > 10000.0) throw "Credits FX invalid param_particle_initial_velocity_range_x_max";
    variable_struct_set(_out, "param_particle_initial_velocity_range_x_max", _v_param_particle_initial_velocity_range_x_max);
    if (!variable_struct_exists(_source, "param_particle_initial_velocity_range_y_min")) throw "Credits FX missing param_particle_initial_velocity_range_y_min";
    var _v_param_particle_initial_velocity_range_y_min = variable_struct_get(_source, "param_particle_initial_velocity_range_y_min");
    if (!is_real(_v_param_particle_initial_velocity_range_y_min) || is_bool(_v_param_particle_initial_velocity_range_y_min) || is_nan(_v_param_particle_initial_velocity_range_y_min) || is_infinity(_v_param_particle_initial_velocity_range_y_min) || _v_param_particle_initial_velocity_range_y_min < -10000.0 || _v_param_particle_initial_velocity_range_y_min > 10000.0) throw "Credits FX invalid param_particle_initial_velocity_range_y_min";
    variable_struct_set(_out, "param_particle_initial_velocity_range_y_min", _v_param_particle_initial_velocity_range_y_min);
    if (!variable_struct_exists(_source, "param_particle_initial_velocity_range_y_max")) throw "Credits FX missing param_particle_initial_velocity_range_y_max";
    var _v_param_particle_initial_velocity_range_y_max = variable_struct_get(_source, "param_particle_initial_velocity_range_y_max");
    if (!is_real(_v_param_particle_initial_velocity_range_y_max) || is_bool(_v_param_particle_initial_velocity_range_y_max) || is_nan(_v_param_particle_initial_velocity_range_y_max) || is_infinity(_v_param_particle_initial_velocity_range_y_max) || _v_param_particle_initial_velocity_range_y_max < -10000.0 || _v_param_particle_initial_velocity_range_y_max > 10000.0) throw "Credits FX invalid param_particle_initial_velocity_range_y_max";
    variable_struct_set(_out, "param_particle_initial_velocity_range_y_max", _v_param_particle_initial_velocity_range_y_max);
    if (!variable_struct_exists(_source, "param_particle_initial_rotation_min")) throw "Credits FX missing param_particle_initial_rotation_min";
    var _v_param_particle_initial_rotation_min = variable_struct_get(_source, "param_particle_initial_rotation_min");
    if (!is_real(_v_param_particle_initial_rotation_min) || is_bool(_v_param_particle_initial_rotation_min) || is_nan(_v_param_particle_initial_rotation_min) || is_infinity(_v_param_particle_initial_rotation_min) || _v_param_particle_initial_rotation_min < 0.0 || _v_param_particle_initial_rotation_min > 360.0) throw "Credits FX invalid param_particle_initial_rotation_min";
    variable_struct_set(_out, "param_particle_initial_rotation_min", _v_param_particle_initial_rotation_min);
    if (!variable_struct_exists(_source, "param_particle_initial_rotation_max")) throw "Credits FX missing param_particle_initial_rotation_max";
    var _v_param_particle_initial_rotation_max = variable_struct_get(_source, "param_particle_initial_rotation_max");
    if (!is_real(_v_param_particle_initial_rotation_max) || is_bool(_v_param_particle_initial_rotation_max) || is_nan(_v_param_particle_initial_rotation_max) || is_infinity(_v_param_particle_initial_rotation_max) || _v_param_particle_initial_rotation_max < 0.0 || _v_param_particle_initial_rotation_max > 360.0) throw "Credits FX invalid param_particle_initial_rotation_max";
    variable_struct_set(_out, "param_particle_initial_rotation_max", _v_param_particle_initial_rotation_max);
    if (!variable_struct_exists(_source, "param_particle_rot_speed_min")) throw "Credits FX missing param_particle_rot_speed_min";
    var _v_param_particle_rot_speed_min = variable_struct_get(_source, "param_particle_rot_speed_min");
    if (!is_real(_v_param_particle_rot_speed_min) || is_bool(_v_param_particle_rot_speed_min) || is_nan(_v_param_particle_rot_speed_min) || is_infinity(_v_param_particle_rot_speed_min) || _v_param_particle_rot_speed_min < -3600.0 || _v_param_particle_rot_speed_min > 3600.0) throw "Credits FX invalid param_particle_rot_speed_min";
    variable_struct_set(_out, "param_particle_rot_speed_min", _v_param_particle_rot_speed_min);
    if (!variable_struct_exists(_source, "param_particle_rot_speed_max")) throw "Credits FX missing param_particle_rot_speed_max";
    var _v_param_particle_rot_speed_max = variable_struct_get(_source, "param_particle_rot_speed_max");
    if (!is_real(_v_param_particle_rot_speed_max) || is_bool(_v_param_particle_rot_speed_max) || is_nan(_v_param_particle_rot_speed_max) || is_infinity(_v_param_particle_rot_speed_max) || _v_param_particle_rot_speed_max < -3600.0 || _v_param_particle_rot_speed_max > 3600.0) throw "Credits FX invalid param_particle_rot_speed_max";
    variable_struct_set(_out, "param_particle_rot_speed_max", _v_param_particle_rot_speed_max);
    if (!variable_struct_exists(_source, "param_particle_align_vel")) throw "Credits FX missing param_particle_align_vel";
    var _v_param_particle_align_vel = variable_struct_get(_source, "param_particle_align_vel");
    if (!is_real(_v_param_particle_align_vel) || is_bool(_v_param_particle_align_vel) || is_nan(_v_param_particle_align_vel) || is_infinity(_v_param_particle_align_vel) || _v_param_particle_align_vel < 0.0 || _v_param_particle_align_vel > 1.0) throw "Credits FX invalid param_particle_align_vel";
    variable_struct_set(_out, "param_particle_align_vel", _v_param_particle_align_vel);
    if (!variable_struct_exists(_source, "param_particle_lifetime_min")) throw "Credits FX missing param_particle_lifetime_min";
    var _v_param_particle_lifetime_min = variable_struct_get(_source, "param_particle_lifetime_min");
    if (!is_real(_v_param_particle_lifetime_min) || is_bool(_v_param_particle_lifetime_min) || is_nan(_v_param_particle_lifetime_min) || is_infinity(_v_param_particle_lifetime_min) || _v_param_particle_lifetime_min < 0.0 || _v_param_particle_lifetime_min > 1000.0) throw "Credits FX invalid param_particle_lifetime_min";
    variable_struct_set(_out, "param_particle_lifetime_min", _v_param_particle_lifetime_min);
    if (!variable_struct_exists(_source, "param_particle_lifetime_max")) throw "Credits FX missing param_particle_lifetime_max";
    var _v_param_particle_lifetime_max = variable_struct_get(_source, "param_particle_lifetime_max");
    if (!is_real(_v_param_particle_lifetime_max) || is_bool(_v_param_particle_lifetime_max) || is_nan(_v_param_particle_lifetime_max) || is_infinity(_v_param_particle_lifetime_max) || _v_param_particle_lifetime_max < 0.0 || _v_param_particle_lifetime_max > 1000.0) throw "Credits FX invalid param_particle_lifetime_max";
    variable_struct_set(_out, "param_particle_lifetime_max", _v_param_particle_lifetime_max);
    if (!variable_struct_exists(_source, "param_particle_update_skip")) throw "Credits FX missing param_particle_update_skip";
    var _v_param_particle_update_skip = variable_struct_get(_source, "param_particle_update_skip");
    if (!is_real(_v_param_particle_update_skip) || is_bool(_v_param_particle_update_skip) || is_nan(_v_param_particle_update_skip) || is_infinity(_v_param_particle_update_skip) || _v_param_particle_update_skip < 0.0 || _v_param_particle_update_skip > 10.0) throw "Credits FX invalid param_particle_update_skip";
    variable_struct_set(_out, "param_particle_update_skip", _v_param_particle_update_skip);
    if (!variable_struct_exists(_source, "param_particle_spawn_border_prop")) throw "Credits FX missing param_particle_spawn_border_prop";
    var _v_param_particle_spawn_border_prop = variable_struct_get(_source, "param_particle_spawn_border_prop");
    if (!is_real(_v_param_particle_spawn_border_prop) || is_bool(_v_param_particle_spawn_border_prop) || is_nan(_v_param_particle_spawn_border_prop) || is_infinity(_v_param_particle_spawn_border_prop) || _v_param_particle_spawn_border_prop < 0.0 || _v_param_particle_spawn_border_prop > 1.0) throw "Credits FX invalid param_particle_spawn_border_prop";
    variable_struct_set(_out, "param_particle_spawn_border_prop", _v_param_particle_spawn_border_prop);
    if (!variable_struct_exists(_source, "param_particle_src_blend")) throw "Credits FX missing param_particle_src_blend";
    var _v_param_particle_src_blend = variable_struct_get(_source, "param_particle_src_blend");
    if (!is_real(_v_param_particle_src_blend) || is_bool(_v_param_particle_src_blend) || is_nan(_v_param_particle_src_blend) || is_infinity(_v_param_particle_src_blend) || _v_param_particle_src_blend < 1.0 || _v_param_particle_src_blend > 11.0) throw "Credits FX invalid param_particle_src_blend";
    variable_struct_set(_out, "param_particle_src_blend", _v_param_particle_src_blend);
    if (!variable_struct_exists(_source, "param_particle_dest_blend")) throw "Credits FX missing param_particle_dest_blend";
    var _v_param_particle_dest_blend = variable_struct_get(_source, "param_particle_dest_blend");
    if (!is_real(_v_param_particle_dest_blend) || is_bool(_v_param_particle_dest_blend) || is_nan(_v_param_particle_dest_blend) || is_infinity(_v_param_particle_dest_blend) || _v_param_particle_dest_blend < 1.0 || _v_param_particle_dest_blend > 11.0) throw "Credits FX invalid param_particle_dest_blend";
    variable_struct_set(_out, "param_particle_dest_blend", _v_param_particle_dest_blend);
    if (!variable_struct_exists(_source, "param_trails_only")) throw "Credits FX missing param_trails_only";
    var _v_param_trails_only = variable_struct_get(_source, "param_trails_only");
    if (!is_real(_v_param_trails_only) || is_bool(_v_param_trails_only) || is_nan(_v_param_trails_only) || is_infinity(_v_param_trails_only) || _v_param_trails_only < 0.0 || _v_param_trails_only > 1.0) throw "Credits FX invalid param_trails_only";
    variable_struct_set(_out, "param_trails_only", _v_param_trails_only);
    if (!variable_struct_exists(_source, "param_trail_chance")) throw "Credits FX missing param_trail_chance";
    var _v_param_trail_chance = variable_struct_get(_source, "param_trail_chance");
    if (!is_real(_v_param_trail_chance) || is_bool(_v_param_trail_chance) || is_nan(_v_param_trail_chance) || is_infinity(_v_param_trail_chance) || _v_param_trail_chance < 0.0 || _v_param_trail_chance > 100.0) throw "Credits FX invalid param_trail_chance";
    variable_struct_set(_out, "param_trail_chance", _v_param_trail_chance);
    if (!variable_struct_exists(_source, "param_trail_lifetime_min")) throw "Credits FX missing param_trail_lifetime_min";
    var _v_param_trail_lifetime_min = variable_struct_get(_source, "param_trail_lifetime_min");
    if (!is_real(_v_param_trail_lifetime_min) || is_bool(_v_param_trail_lifetime_min) || is_nan(_v_param_trail_lifetime_min) || is_infinity(_v_param_trail_lifetime_min) || _v_param_trail_lifetime_min < 0.0 || _v_param_trail_lifetime_min > 5.0) throw "Credits FX invalid param_trail_lifetime_min";
    variable_struct_set(_out, "param_trail_lifetime_min", _v_param_trail_lifetime_min);
    if (!variable_struct_exists(_source, "param_trail_lifetime_max")) throw "Credits FX missing param_trail_lifetime_max";
    var _v_param_trail_lifetime_max = variable_struct_get(_source, "param_trail_lifetime_max");
    if (!is_real(_v_param_trail_lifetime_max) || is_bool(_v_param_trail_lifetime_max) || is_nan(_v_param_trail_lifetime_max) || is_infinity(_v_param_trail_lifetime_max) || _v_param_trail_lifetime_max < 0.0 || _v_param_trail_lifetime_max > 5.0) throw "Credits FX invalid param_trail_lifetime_max";
    variable_struct_set(_out, "param_trail_lifetime_max", _v_param_trail_lifetime_max);
    if (!variable_struct_exists(_source, "param_trail_thickness_min")) throw "Credits FX missing param_trail_thickness_min";
    var _v_param_trail_thickness_min = variable_struct_get(_source, "param_trail_thickness_min");
    if (!is_real(_v_param_trail_thickness_min) || is_bool(_v_param_trail_thickness_min) || is_nan(_v_param_trail_thickness_min) || is_infinity(_v_param_trail_thickness_min) || _v_param_trail_thickness_min < 0.0 || _v_param_trail_thickness_min > 2.0) throw "Credits FX invalid param_trail_thickness_min";
    variable_struct_set(_out, "param_trail_thickness_min", _v_param_trail_thickness_min);
    if (!variable_struct_exists(_source, "param_trail_thickness_max")) throw "Credits FX missing param_trail_thickness_max";
    var _v_param_trail_thickness_max = variable_struct_get(_source, "param_trail_thickness_max");
    if (!is_real(_v_param_trail_thickness_max) || is_bool(_v_param_trail_thickness_max) || is_nan(_v_param_trail_thickness_max) || is_infinity(_v_param_trail_thickness_max) || _v_param_trail_thickness_max < 0.0 || _v_param_trail_thickness_max > 2.0) throw "Credits FX invalid param_trail_thickness_max";
    variable_struct_set(_out, "param_trail_thickness_max", _v_param_trail_thickness_max);
    if (!variable_struct_exists(_source, "param_trail_col_1")) throw "Credits FX missing param_trail_col_1";
    var _v_param_trail_col_1 = variable_struct_get(_source, "param_trail_col_1");
    if (!is_array(_v_param_trail_col_1) || array_length(_v_param_trail_col_1) != 4) throw "Credits FX invalid param_trail_col_1 vector";
    var _copy_param_trail_col_1 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_1[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_1 channel";
        array_push(_copy_param_trail_col_1, _part);
    }
    _v_param_trail_col_1 = _copy_param_trail_col_1;
    variable_struct_set(_out, "param_trail_col_1", _v_param_trail_col_1);
    if (!variable_struct_exists(_source, "param_trail_col_alt_1")) throw "Credits FX missing param_trail_col_alt_1";
    var _v_param_trail_col_alt_1 = variable_struct_get(_source, "param_trail_col_alt_1");
    if (!is_array(_v_param_trail_col_alt_1) || array_length(_v_param_trail_col_alt_1) != 4) throw "Credits FX invalid param_trail_col_alt_1 vector";
    var _copy_param_trail_col_alt_1 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_alt_1[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_alt_1 channel";
        array_push(_copy_param_trail_col_alt_1, _part);
    }
    _v_param_trail_col_alt_1 = _copy_param_trail_col_alt_1;
    variable_struct_set(_out, "param_trail_col_alt_1", _v_param_trail_col_alt_1);
    if (!variable_struct_exists(_source, "param_trail_col_2")) throw "Credits FX missing param_trail_col_2";
    var _v_param_trail_col_2 = variable_struct_get(_source, "param_trail_col_2");
    if (!is_array(_v_param_trail_col_2) || array_length(_v_param_trail_col_2) != 4) throw "Credits FX invalid param_trail_col_2 vector";
    var _copy_param_trail_col_2 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_2[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_2 channel";
        array_push(_copy_param_trail_col_2, _part);
    }
    _v_param_trail_col_2 = _copy_param_trail_col_2;
    variable_struct_set(_out, "param_trail_col_2", _v_param_trail_col_2);
    if (!variable_struct_exists(_source, "param_trail_col_alt_2")) throw "Credits FX missing param_trail_col_alt_2";
    var _v_param_trail_col_alt_2 = variable_struct_get(_source, "param_trail_col_alt_2");
    if (!is_array(_v_param_trail_col_alt_2) || array_length(_v_param_trail_col_alt_2) != 4) throw "Credits FX invalid param_trail_col_alt_2 vector";
    var _copy_param_trail_col_alt_2 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_alt_2[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_alt_2 channel";
        array_push(_copy_param_trail_col_alt_2, _part);
    }
    _v_param_trail_col_alt_2 = _copy_param_trail_col_alt_2;
    variable_struct_set(_out, "param_trail_col_alt_2", _v_param_trail_col_alt_2);
    if (!variable_struct_exists(_source, "param_trail_col_2_pos")) throw "Credits FX missing param_trail_col_2_pos";
    var _v_param_trail_col_2_pos = variable_struct_get(_source, "param_trail_col_2_pos");
    if (!is_real(_v_param_trail_col_2_pos) || is_bool(_v_param_trail_col_2_pos) || is_nan(_v_param_trail_col_2_pos) || is_infinity(_v_param_trail_col_2_pos) || _v_param_trail_col_2_pos < 0.0 || _v_param_trail_col_2_pos > 1.0) throw "Credits FX invalid param_trail_col_2_pos";
    variable_struct_set(_out, "param_trail_col_2_pos", _v_param_trail_col_2_pos);
    if (!variable_struct_exists(_source, "param_trail_col_enabled_2")) throw "Credits FX missing param_trail_col_enabled_2";
    var _v_param_trail_col_enabled_2 = variable_struct_get(_source, "param_trail_col_enabled_2");
    if (!is_real(_v_param_trail_col_enabled_2) || is_bool(_v_param_trail_col_enabled_2) || is_nan(_v_param_trail_col_enabled_2) || is_infinity(_v_param_trail_col_enabled_2) || _v_param_trail_col_enabled_2 < 0.0 || _v_param_trail_col_enabled_2 > 1.0) throw "Credits FX invalid param_trail_col_enabled_2";
    variable_struct_set(_out, "param_trail_col_enabled_2", _v_param_trail_col_enabled_2);
    if (!variable_struct_exists(_source, "param_trail_col_3")) throw "Credits FX missing param_trail_col_3";
    var _v_param_trail_col_3 = variable_struct_get(_source, "param_trail_col_3");
    if (!is_array(_v_param_trail_col_3) || array_length(_v_param_trail_col_3) != 4) throw "Credits FX invalid param_trail_col_3 vector";
    var _copy_param_trail_col_3 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_3[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_3 channel";
        array_push(_copy_param_trail_col_3, _part);
    }
    _v_param_trail_col_3 = _copy_param_trail_col_3;
    variable_struct_set(_out, "param_trail_col_3", _v_param_trail_col_3);
    if (!variable_struct_exists(_source, "param_trail_col_alt_3")) throw "Credits FX missing param_trail_col_alt_3";
    var _v_param_trail_col_alt_3 = variable_struct_get(_source, "param_trail_col_alt_3");
    if (!is_array(_v_param_trail_col_alt_3) || array_length(_v_param_trail_col_alt_3) != 4) throw "Credits FX invalid param_trail_col_alt_3 vector";
    var _copy_param_trail_col_alt_3 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_alt_3[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_alt_3 channel";
        array_push(_copy_param_trail_col_alt_3, _part);
    }
    _v_param_trail_col_alt_3 = _copy_param_trail_col_alt_3;
    variable_struct_set(_out, "param_trail_col_alt_3", _v_param_trail_col_alt_3);
    if (!variable_struct_exists(_source, "param_trail_col_3_pos")) throw "Credits FX missing param_trail_col_3_pos";
    var _v_param_trail_col_3_pos = variable_struct_get(_source, "param_trail_col_3_pos");
    if (!is_real(_v_param_trail_col_3_pos) || is_bool(_v_param_trail_col_3_pos) || is_nan(_v_param_trail_col_3_pos) || is_infinity(_v_param_trail_col_3_pos) || _v_param_trail_col_3_pos < 0.0 || _v_param_trail_col_3_pos > 1.0) throw "Credits FX invalid param_trail_col_3_pos";
    variable_struct_set(_out, "param_trail_col_3_pos", _v_param_trail_col_3_pos);
    if (!variable_struct_exists(_source, "param_trail_col_enabled_3")) throw "Credits FX missing param_trail_col_enabled_3";
    var _v_param_trail_col_enabled_3 = variable_struct_get(_source, "param_trail_col_enabled_3");
    if (!is_real(_v_param_trail_col_enabled_3) || is_bool(_v_param_trail_col_enabled_3) || is_nan(_v_param_trail_col_enabled_3) || is_infinity(_v_param_trail_col_enabled_3) || _v_param_trail_col_enabled_3 < 0.0 || _v_param_trail_col_enabled_3 > 1.0) throw "Credits FX invalid param_trail_col_enabled_3";
    variable_struct_set(_out, "param_trail_col_enabled_3", _v_param_trail_col_enabled_3);
    if (!variable_struct_exists(_source, "param_trail_col_4")) throw "Credits FX missing param_trail_col_4";
    var _v_param_trail_col_4 = variable_struct_get(_source, "param_trail_col_4");
    if (!is_array(_v_param_trail_col_4) || array_length(_v_param_trail_col_4) != 4) throw "Credits FX invalid param_trail_col_4 vector";
    var _copy_param_trail_col_4 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_4[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_4 channel";
        array_push(_copy_param_trail_col_4, _part);
    }
    _v_param_trail_col_4 = _copy_param_trail_col_4;
    variable_struct_set(_out, "param_trail_col_4", _v_param_trail_col_4);
    if (!variable_struct_exists(_source, "param_trail_col_alt_4")) throw "Credits FX missing param_trail_col_alt_4";
    var _v_param_trail_col_alt_4 = variable_struct_get(_source, "param_trail_col_alt_4");
    if (!is_array(_v_param_trail_col_alt_4) || array_length(_v_param_trail_col_alt_4) != 4) throw "Credits FX invalid param_trail_col_alt_4 vector";
    var _copy_param_trail_col_alt_4 = [];
    for (var _c = 0; _c < 4; ++_c) {
        var _part = _v_param_trail_col_alt_4[_c];
        if (!is_real(_part) || is_bool(_part) || is_nan(_part) || is_infinity(_part) || _part < 0 || _part > 1) throw "Credits FX invalid param_trail_col_alt_4 channel";
        array_push(_copy_param_trail_col_alt_4, _part);
    }
    _v_param_trail_col_alt_4 = _copy_param_trail_col_alt_4;
    variable_struct_set(_out, "param_trail_col_alt_4", _v_param_trail_col_alt_4);
    if (!variable_struct_exists(_source, "param_trail_min_segment_length")) throw "Credits FX missing param_trail_min_segment_length";
    var _v_param_trail_min_segment_length = variable_struct_get(_source, "param_trail_min_segment_length");
    if (!is_real(_v_param_trail_min_segment_length) || is_bool(_v_param_trail_min_segment_length) || is_nan(_v_param_trail_min_segment_length) || is_infinity(_v_param_trail_min_segment_length) || _v_param_trail_min_segment_length < 0.0 || _v_param_trail_min_segment_length > 100.0) throw "Credits FX invalid param_trail_min_segment_length";
    variable_struct_set(_out, "param_trail_min_segment_length", _v_param_trail_min_segment_length);
    if (!variable_struct_exists(_source, "param_trail_src_blend")) throw "Credits FX missing param_trail_src_blend";
    var _v_param_trail_src_blend = variable_struct_get(_source, "param_trail_src_blend");
    if (!is_real(_v_param_trail_src_blend) || is_bool(_v_param_trail_src_blend) || is_nan(_v_param_trail_src_blend) || is_infinity(_v_param_trail_src_blend) || _v_param_trail_src_blend < 1.0 || _v_param_trail_src_blend > 11.0) throw "Credits FX invalid param_trail_src_blend";
    variable_struct_set(_out, "param_trail_src_blend", _v_param_trail_src_blend);
    if (!variable_struct_exists(_source, "param_trail_dest_blend")) throw "Credits FX missing param_trail_dest_blend";
    var _v_param_trail_dest_blend = variable_struct_get(_source, "param_trail_dest_blend");
    if (!is_real(_v_param_trail_dest_blend) || is_bool(_v_param_trail_dest_blend) || is_nan(_v_param_trail_dest_blend) || is_infinity(_v_param_trail_dest_blend) || _v_param_trail_dest_blend < 1.0 || _v_param_trail_dest_blend > 11.0) throw "Credits FX invalid param_trail_dest_blend";
    variable_struct_set(_out, "param_trail_dest_blend", _v_param_trail_dest_blend);
    if (!variable_struct_exists(_source, "param_num_blowers")) throw "Credits FX missing param_num_blowers";
    var _v_param_num_blowers = variable_struct_get(_source, "param_num_blowers");
    if (!is_real(_v_param_num_blowers) || is_bool(_v_param_num_blowers) || is_nan(_v_param_num_blowers) || is_infinity(_v_param_num_blowers) || _v_param_num_blowers < 0.0 || _v_param_num_blowers > 10.0) throw "Credits FX invalid param_num_blowers";
    variable_struct_set(_out, "param_num_blowers", _v_param_num_blowers);
    if (!variable_struct_exists(_source, "param_blower_size_min")) throw "Credits FX missing param_blower_size_min";
    var _v_param_blower_size_min = variable_struct_get(_source, "param_blower_size_min");
    if (!is_real(_v_param_blower_size_min) || is_bool(_v_param_blower_size_min) || is_nan(_v_param_blower_size_min) || is_infinity(_v_param_blower_size_min) || _v_param_blower_size_min < 0.0 || _v_param_blower_size_min > 2.0) throw "Credits FX invalid param_blower_size_min";
    variable_struct_set(_out, "param_blower_size_min", _v_param_blower_size_min);
    if (!variable_struct_exists(_source, "param_blower_size_max")) throw "Credits FX missing param_blower_size_max";
    var _v_param_blower_size_max = variable_struct_get(_source, "param_blower_size_max");
    if (!is_real(_v_param_blower_size_max) || is_bool(_v_param_blower_size_max) || is_nan(_v_param_blower_size_max) || is_infinity(_v_param_blower_size_max) || _v_param_blower_size_max < 0.0 || _v_param_blower_size_max > 2.0) throw "Credits FX invalid param_blower_size_max";
    variable_struct_set(_out, "param_blower_size_max", _v_param_blower_size_max);
    if (!variable_struct_exists(_source, "param_blower_speed_min")) throw "Credits FX missing param_blower_speed_min";
    var _v_param_blower_speed_min = variable_struct_get(_source, "param_blower_speed_min");
    if (!is_real(_v_param_blower_speed_min) || is_bool(_v_param_blower_speed_min) || is_nan(_v_param_blower_speed_min) || is_infinity(_v_param_blower_speed_min) || _v_param_blower_speed_min < 0.01 || _v_param_blower_speed_min > 5.0) throw "Credits FX invalid param_blower_speed_min";
    variable_struct_set(_out, "param_blower_speed_min", _v_param_blower_speed_min);
    if (!variable_struct_exists(_source, "param_blower_speed_max")) throw "Credits FX missing param_blower_speed_max";
    var _v_param_blower_speed_max = variable_struct_get(_source, "param_blower_speed_max");
    if (!is_real(_v_param_blower_speed_max) || is_bool(_v_param_blower_speed_max) || is_nan(_v_param_blower_speed_max) || is_infinity(_v_param_blower_speed_max) || _v_param_blower_speed_max < 0.01 || _v_param_blower_speed_max > 5.0) throw "Credits FX invalid param_blower_speed_max";
    variable_struct_set(_out, "param_blower_speed_max", _v_param_blower_speed_max);
    if (!variable_struct_exists(_source, "param_blower_rot_speed_min")) throw "Credits FX missing param_blower_rot_speed_min";
    var _v_param_blower_rot_speed_min = variable_struct_get(_source, "param_blower_rot_speed_min");
    if (!is_real(_v_param_blower_rot_speed_min) || is_bool(_v_param_blower_rot_speed_min) || is_nan(_v_param_blower_rot_speed_min) || is_infinity(_v_param_blower_rot_speed_min) || _v_param_blower_rot_speed_min < -1080.0 || _v_param_blower_rot_speed_min > 1080.0) throw "Credits FX invalid param_blower_rot_speed_min";
    variable_struct_set(_out, "param_blower_rot_speed_min", _v_param_blower_rot_speed_min);
    if (!variable_struct_exists(_source, "param_blower_rot_speed_max")) throw "Credits FX missing param_blower_rot_speed_max";
    var _v_param_blower_rot_speed_max = variable_struct_get(_source, "param_blower_rot_speed_max");
    if (!is_real(_v_param_blower_rot_speed_max) || is_bool(_v_param_blower_rot_speed_max) || is_nan(_v_param_blower_rot_speed_max) || is_infinity(_v_param_blower_rot_speed_max) || _v_param_blower_rot_speed_max < -1080.0 || _v_param_blower_rot_speed_max > 1080.0) throw "Credits FX invalid param_blower_rot_speed_max";
    variable_struct_set(_out, "param_blower_rot_speed_max", _v_param_blower_rot_speed_max);
    if (!variable_struct_exists(_source, "param_blower_force_min")) throw "Credits FX missing param_blower_force_min";
    var _v_param_blower_force_min = variable_struct_get(_source, "param_blower_force_min");
    if (!is_real(_v_param_blower_force_min) || is_bool(_v_param_blower_force_min) || is_nan(_v_param_blower_force_min) || is_infinity(_v_param_blower_force_min) || _v_param_blower_force_min < 0.0 || _v_param_blower_force_min > 100.0) throw "Credits FX invalid param_blower_force_min";
    variable_struct_set(_out, "param_blower_force_min", _v_param_blower_force_min);
    if (!variable_struct_exists(_source, "param_blower_force_max")) throw "Credits FX missing param_blower_force_max";
    var _v_param_blower_force_max = variable_struct_get(_source, "param_blower_force_max");
    if (!is_real(_v_param_blower_force_max) || is_bool(_v_param_blower_force_max) || is_nan(_v_param_blower_force_max) || is_infinity(_v_param_blower_force_max) || _v_param_blower_force_max < 0.0 || _v_param_blower_force_max > 100.0) throw "Credits FX invalid param_blower_force_max";
    variable_struct_set(_out, "param_blower_force_max", _v_param_blower_force_max);
    if (!variable_struct_exists(_source, "param_blower_camvec_scale")) throw "Credits FX missing param_blower_camvec_scale";
    var _v_param_blower_camvec_scale = variable_struct_get(_source, "param_blower_camvec_scale");
    if (!is_real(_v_param_blower_camvec_scale) || is_bool(_v_param_blower_camvec_scale) || is_nan(_v_param_blower_camvec_scale) || is_infinity(_v_param_blower_camvec_scale) || _v_param_blower_camvec_scale < -1.0 || _v_param_blower_camvec_scale > 1.0) throw "Credits FX invalid param_blower_camvec_scale";
    variable_struct_set(_out, "param_blower_camvec_scale", _v_param_blower_camvec_scale);
    if (!variable_struct_exists(_source, "param_force_grid_sizex")) throw "Credits FX missing param_force_grid_sizex";
    var _v_param_force_grid_sizex = variable_struct_get(_source, "param_force_grid_sizex");
    if (!is_real(_v_param_force_grid_sizex) || is_bool(_v_param_force_grid_sizex) || is_nan(_v_param_force_grid_sizex) || is_infinity(_v_param_force_grid_sizex) || _v_param_force_grid_sizex < 3.0 || _v_param_force_grid_sizex > 32.0) throw "Credits FX invalid param_force_grid_sizex";
    variable_struct_set(_out, "param_force_grid_sizex", _v_param_force_grid_sizex);
    if (!variable_struct_exists(_source, "param_force_grid_sizey")) throw "Credits FX missing param_force_grid_sizey";
    var _v_param_force_grid_sizey = variable_struct_get(_source, "param_force_grid_sizey");
    if (!is_real(_v_param_force_grid_sizey) || is_bool(_v_param_force_grid_sizey) || is_nan(_v_param_force_grid_sizey) || is_infinity(_v_param_force_grid_sizey) || _v_param_force_grid_sizey < 3.0 || _v_param_force_grid_sizey > 32.0) throw "Credits FX invalid param_force_grid_sizey";
    variable_struct_set(_out, "param_force_grid_sizey", _v_param_force_grid_sizey);
    if (!variable_struct_exists(_source, "param_wind_vector_x")) throw "Credits FX missing param_wind_vector_x";
    var _v_param_wind_vector_x = variable_struct_get(_source, "param_wind_vector_x");
    if (!is_real(_v_param_wind_vector_x) || is_bool(_v_param_wind_vector_x) || is_nan(_v_param_wind_vector_x) || is_infinity(_v_param_wind_vector_x) || _v_param_wind_vector_x < -100.0 || _v_param_wind_vector_x > 100.0) throw "Credits FX invalid param_wind_vector_x";
    variable_struct_set(_out, "param_wind_vector_x", _v_param_wind_vector_x);
    if (!variable_struct_exists(_source, "param_wind_vector_y")) throw "Credits FX missing param_wind_vector_y";
    var _v_param_wind_vector_y = variable_struct_get(_source, "param_wind_vector_y");
    if (!is_real(_v_param_wind_vector_y) || is_bool(_v_param_wind_vector_y) || is_nan(_v_param_wind_vector_y) || is_infinity(_v_param_wind_vector_y) || _v_param_wind_vector_y < -100.0 || _v_param_wind_vector_y > 100.0) throw "Credits FX invalid param_wind_vector_y";
    variable_struct_set(_out, "param_wind_vector_y", _v_param_wind_vector_y);
    if (!variable_struct_exists(_source, "param_dragcoeff")) throw "Credits FX missing param_dragcoeff";
    var _v_param_dragcoeff = variable_struct_get(_source, "param_dragcoeff");
    if (!is_real(_v_param_dragcoeff) || is_bool(_v_param_dragcoeff) || is_nan(_v_param_dragcoeff) || is_infinity(_v_param_dragcoeff) || _v_param_dragcoeff < 0.0 || _v_param_dragcoeff > 10.0) throw "Credits FX invalid param_dragcoeff";
    variable_struct_set(_out, "param_dragcoeff", _v_param_dragcoeff);
    if (!variable_struct_exists(_source, "param_grav_accel")) throw "Credits FX missing param_grav_accel";
    var _v_param_grav_accel = variable_struct_get(_source, "param_grav_accel");
    if (!is_real(_v_param_grav_accel) || is_bool(_v_param_grav_accel) || is_nan(_v_param_grav_accel) || is_infinity(_v_param_grav_accel) || _v_param_grav_accel < -10000.0 || _v_param_grav_accel > 10000.0) throw "Credits FX invalid param_grav_accel";
    variable_struct_set(_out, "param_grav_accel", _v_param_grav_accel);
    if (!variable_struct_exists(_source, "param_debug_grid")) throw "Credits FX missing param_debug_grid";
    var _v_param_debug_grid = variable_struct_get(_source, "param_debug_grid");
    if (!is_real(_v_param_debug_grid) || is_bool(_v_param_debug_grid) || is_nan(_v_param_debug_grid) || is_infinity(_v_param_debug_grid) || _v_param_debug_grid < 0.0 || _v_param_debug_grid > 1.0) throw "Credits FX invalid param_debug_grid";
    variable_struct_set(_out, "param_debug_grid", _v_param_debug_grid);
    if (_out.param_force_grid_sizex <= 2 || _out.param_force_grid_sizey <= 2
        || _out.param_force_grid_sizex != floor(_out.param_force_grid_sizex)
        || _out.param_force_grid_sizey != floor(_out.param_force_grid_sizey))
        throw "Credits FX force grid must have integral dimensions greater than2";
    if (_out.param_particle_lifetime_min <= 0 || _out.param_particle_lifetime_max <= 0
        || _out.param_trail_lifetime_min <= 0 || _out.param_trail_lifetime_max <= 0)
        throw "Credits FX lifetimes must be positive";
    if (_out.param_force_grid_sizex > 8 || _out.param_force_grid_sizey > 8
        || _out.param_trail_lifetime_min > 0.5 || _out.param_trail_lifetime_max > 0.5)
        throw "Credits FX proposal bounds the authored8x8 grid/half-second trails";
    if (_out.param_warmup_frames != 0 || _out.param_num_particles > 40 || _out.param_num_blowers > 3)
        throw "Credits FX proposal is bounded to the authored40 particles/3 blowers/no warmup";
    return _out;
}

// Simple particle system with blowing wind effect
// Note that this is *not* supposed to be an even vaguely accurate simulation
// There are also still a lot of optimisations possible
function tcc_credits_windblown(_parameters, _private_seed) constructor
{
	param_num_particles = 100;
	param_particle_spawn_time = 100;			// measured in milliseconds
	param_particle_spawn_all_at_start = 0;
	param_warmup_frames = 0;
	param_sprite = s_playerred;

	param_particle_mass_min = 0.005;
	param_particle_mass_max = 0.01;
	param_particle_start_sprite_scale = 0.25;
	param_particle_end_sprite_scale = 0.25;
	param_particle_col_1 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_alt_1 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_2 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_alt_2 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_3 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_alt_3 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_4 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_alt_4 = [1.0, 1.0, 1.0, 1.0];
	param_particle_col_enabled_2 = 0;
	param_particle_col_enabled_3 = 0;
	param_particle_col_2_pos = 0.33;
	param_particle_col_3_pos = 0.66;
	param_particle_initial_velocity_range_x_min = -100;
	param_particle_initial_velocity_range_x_max = 100;
	param_particle_initial_velocity_range_y_min = -100;
	param_particle_initial_velocity_range_y_max = 100;
	param_particle_initial_rotation_min = 0;
	param_particle_initial_rotation_max = 360;
	param_particle_rot_speed_min = -360;
	param_particle_rot_speed_max = 360;
	param_particle_lifetime_min = 100;
	param_particle_lifetime_max = 100;
	param_particle_update_skip = 1;
	param_particle_spawn_border_prop = 0.25;
	param_particle_src_blend = bm_src_alpha;
	param_particle_dest_blend = bm_inv_src_alpha;
	param_particle_align_vel = 1;

	param_trails_only = 0;
	param_trail_chance = 20;				// percentage chance a particle will have a trail
	param_trail_lifetime_min = 0.1;			// trail lifetime in seconds
	param_trail_lifetime_max = 0.5;			// trail lifetime in seconds
	param_trail_thickness_min = 0.25;
	param_trail_thickness_max = 1.0;
	param_trail_col_1 = [1.0, 1.0, 1.0, 0.1];
	param_trail_col_alt_1 = [1.0, 1.0, 1.0, 0.25];
	param_trail_col_2 = [1.0, 1.0, 1.0, 0.1];
	param_trail_col_alt_2 = [1.0, 1.0, 1.0, 0.25];
	param_trail_col_3 = [1.0, 1.0, 1.0, 0.1];
	param_trail_col_alt_3 = [1.0, 1.0, 1.0, 0.25];
	param_trail_col_4 = [1.0, 1.0, 1.0, 0.0];
	param_trail_col_alt_4 = [1.0, 1.0, 1.0, 0.0];
	param_trail_col_enabled_2 = 1;
	param_trail_col_enabled_3 = 0;
	param_trail_col_2_pos = 0.5;
	param_trail_col_3_pos = 0.66;
	param_trail_min_segment_length = 20;
	param_trail_src_blend = bm_src_alpha;
	param_trail_dest_blend = bm_inv_src_alpha;

	param_force_grid_sizex = 8;
	param_force_grid_sizey = 8;
	param_wind_vector_x = -4;
	param_wind_vector_y = -1;

	param_num_blowers = 3;
	param_blower_size_min = 0.2;
	param_blower_size_max = 0.6;
	param_blower_speed_min = 0.2;	// proportion of screen crossed in a second
	param_blower_speed_max = 0.5;	// proportion of the screen crossed in a second
	param_blower_rot_speed_min = -180;
	param_blower_rot_speed_max = 180;
	param_blower_force_min = 5;
	param_blower_force_max = 15;
	param_blower_camvec_scale = -1.0;

	air_density = 0.01;
	param_dragcoeff = 1.0;

	param_grav_accel = 100.0;

	param_debug_grid = 0;
	debug_grid_alpha = 0.25;
	debug_force_scale = 10.0;

	particle_scale_compensation = 1.0;
	time_since_last_particle = 0.0;

	trails_use_trilists = 0;

	particle_col = array_create(4);
	particle_alpha = array_create(4);
	particle_col_alt = array_create(4);
	particle_alpha_alt = array_create(4);
	particle_col_pos = array_create(4);
	particle_col_dist = array_create(3);

	trail_col = array_create(4);
	trail_alpha = array_create(4);
	trail_col_alt = array_create(4);
	trail_alpha_alt = array_create(4);
	trail_col_pos = array_create(4);
	trail_col_dist = array_create(3);

	update_colours = function()
	{
		// Particle colours
		particle_col[0] = make_colour_rgb(param_particle_col_1[0] * 255, param_particle_col_1[1] * 255, param_particle_col_1[2] * 255);
		particle_col[1] = make_colour_rgb(param_particle_col_2[0] * 255, param_particle_col_2[1] * 255, param_particle_col_2[2] * 255);
		particle_col[2] = make_colour_rgb(param_particle_col_3[0] * 255, param_particle_col_3[1] * 255, param_particle_col_3[2] * 255);
		particle_col[3] = make_colour_rgb(param_particle_col_4[0] * 255, param_particle_col_4[1] * 255, param_particle_col_4[2] * 255);

		particle_col_alt[0] = make_colour_rgb(param_particle_col_alt_1[0] * 255, param_particle_col_alt_1[1] * 255, param_particle_col_alt_1[2] * 255);
		particle_col_alt[1] = make_colour_rgb(param_particle_col_alt_2[0] * 255, param_particle_col_alt_2[1] * 255, param_particle_col_alt_2[2] * 255);
		particle_col_alt[2] = make_colour_rgb(param_particle_col_alt_3[0] * 255, param_particle_col_alt_3[1] * 255, param_particle_col_alt_3[2] * 255);
		particle_col_alt[3] = make_colour_rgb(param_particle_col_alt_4[0] * 255, param_particle_col_alt_4[1] * 255, param_particle_col_alt_4[2] * 255);

		particle_alpha[0] = param_particle_col_1[3];
		particle_alpha[1] = param_particle_col_2[3];
		particle_alpha[2] = param_particle_col_3[3];
		particle_alpha[3] = param_particle_col_4[3];

		particle_alpha_alt[0] = param_particle_col_alt_1[3];
		particle_alpha_alt[1] = param_particle_col_alt_2[3];
		particle_alpha_alt[2] = param_particle_col_alt_3[3];
		particle_alpha_alt[3] = param_particle_col_alt_4[3];

		particle_col_pos[0] = 0.0;
		particle_col_pos[1] = param_particle_col_2_pos;
		particle_col_pos[2] = param_particle_col_3_pos;
		particle_col_pos[3] = 1.0;

		if (param_particle_col_enabled_3 == 0)
		{
			particle_col[2] = particle_col[3];
			particle_col_alt[2] = particle_col_alt[3];
			particle_alpha[2] = particle_alpha[3];
			particle_alpha_alt[2] = particle_alpha_alt[3];
			particle_col_pos[2] = 1.0;
		}

		if (param_particle_col_enabled_2 == 0)
		{
			particle_col[1] = particle_col[2];
			particle_col_alt[1] = particle_col_alt[2];
			particle_alpha[1] = particle_alpha[2];
			particle_alpha_alt[1] = particle_alpha_alt[2];
			particle_col_pos[1] = particle_col_pos[2];
		}

		particle_col_dist[0] = particle_col_pos[1] - particle_col_pos[0];
		particle_col_dist[1] = particle_col_pos[2] - particle_col_pos[1];
		particle_col_dist[2] = particle_col_pos[3] - particle_col_pos[2];


		// Trail colours
		trail_col[0] = make_colour_rgb(param_trail_col_1[0] * 255, param_trail_col_1[1] * 255, param_trail_col_1[2] * 255);
		trail_col[1] = make_colour_rgb(param_trail_col_2[0] * 255, param_trail_col_2[1] * 255, param_trail_col_2[2] * 255);
		trail_col[2] = make_colour_rgb(param_trail_col_3[0] * 255, param_trail_col_3[1] * 255, param_trail_col_3[2] * 255);
		trail_col[3] = make_colour_rgb(param_trail_col_4[0] * 255, param_trail_col_4[1] * 255, param_trail_col_4[2] * 255);

		trail_col_alt[0] = make_colour_rgb(param_trail_col_alt_1[0] * 255, param_trail_col_alt_1[1] * 255, param_trail_col_alt_1[2] * 255);
		trail_col_alt[1] = make_colour_rgb(param_trail_col_alt_2[0] * 255, param_trail_col_alt_2[1] * 255, param_trail_col_alt_2[2] * 255);
		trail_col_alt[2] = make_colour_rgb(param_trail_col_alt_3[0] * 255, param_trail_col_alt_3[1] * 255, param_trail_col_alt_3[2] * 255);
		trail_col_alt[3] = make_colour_rgb(param_trail_col_alt_4[0] * 255, param_trail_col_alt_4[1] * 255, param_trail_col_alt_4[2] * 255);

		trail_alpha[0] = param_trail_col_1[3];
		trail_alpha[1] = param_trail_col_2[3];
		trail_alpha[2] = param_trail_col_3[3];
		trail_alpha[3] = param_trail_col_4[3];

		trail_alpha_alt[0] = param_trail_col_alt_1[3];
		trail_alpha_alt[1] = param_trail_col_alt_2[3];
		trail_alpha_alt[2] = param_trail_col_alt_3[3];
		trail_alpha_alt[3] = param_trail_col_alt_4[3];

		trail_col_pos[0] = 0.0;
		trail_col_pos[1] = param_trail_col_2_pos;
		trail_col_pos[2] = param_trail_col_3_pos;
		trail_col_pos[3] = 1.0;

		if (param_trail_col_enabled_3 == 0)
		{
			trail_col[2] = trail_col[3];
			trail_col_alt[2] = trail_col_alt[3];
			trail_alpha[2] = trail_alpha[3];
			trail_alpha_alt[2] = trail_alpha_alt[3];
			trail_col_pos[2] = 1.0;
		}

		if (param_trail_col_enabled_2 == 0)
		{
			trail_col[1] = trail_col[2];
			trail_col_alt[1] = trail_col_alt[2];
			trail_alpha[1] = trail_alpha[2];
			trail_alpha_alt[1] = trail_alpha_alt[2];
			trail_col_pos[1] = trail_col_pos[2];
		}

		trail_col_dist[0] = trail_col_pos[1] - trail_col_pos[0];
		trail_col_dist[1] = trail_col_pos[2] - trail_col_pos[1];
		trail_col_dist[2] = trail_col_pos[3] - trail_col_pos[2];
	}

	reset = function()
	{
		frame = 0;

		particles = array_create(0);
		num_particles = 0;

		trail_min_segment_length_sq = param_trail_min_segment_length * param_trail_min_segment_length;

		force_grid_sizex = -1;
		force_grid_sizey = -1;

		force_grid = -1;
		force_grid_centrex = 0;		// this is the room position the force grid is based at
		force_grid_centrey = 0;

		force_grid_offsetx = 0;		// this is the position in the grid array we start at (circular buffer style)
		force_grid_offsety = 0;

		grid_margin = 1;			// this is amount we want the force grid to overhang on each side

		last_view_centrex = 0;
		last_view_centrey = 0;

		blowers = array_create(0);
		num_blowers = 0;

		trails = array_create(0);
		num_trails = 0;

		views_minx = 0;
		views_maxx = 0;
		views_miny = 0;
		views_maxx = 0;
		views_centrex = 0;
		views_centrey = 0;

		update_colours();

		sprwidth = sprite_get_width(param_sprite);
		sprheight = sprite_get_height(param_sprite);

		particle_scale_compensation = 1.0;
	}

	cleanup = function()
	{

	}

	spawn_blower = function(_minx, _maxx, _miny, _maxy)
	{
        blower_birth_count += 1;
		var blower =
		{
			velx:((_maxx - _minx) * local_random_range(param_blower_speed_min, param_blower_speed_max)),
			posy:local_random_range(_miny, _maxy),
			size:(local_random_range(param_blower_size_min, param_blower_size_max) * (_maxx - _minx)),
			rotspeed:local_random_range((param_blower_rot_speed_min / 180.0) * pi, (param_blower_rot_speed_max / 180.0) * pi),
			rot:local_random_range(0, pi * 2.0),
			force:local_random_range(param_blower_force_min, param_blower_force_max)
		};

		if (local_random(100) < 50.0)
			blower.velx = -blower.velx;

		if (blower.velx < 0)
			blower.posx = _maxx + blower.size;
		else
			blower.posx = _minx - blower.size;

		return blower;
	}

	spawn_trail = function(_lifetime, _spritesize)
	{
        trail_birth_count += 1;
		if (array_length(trails) <= num_trails)
		{
			array_resize(trails, num_trails + 1);
		}

		var lifetime_in_frames = _lifetime * TCC_SIM_HZ;
		var num_segs = ceil(lifetime_in_frames) + 1;	// currently just assume one segment per frame (add on an extra segment so we get a full alpha fade-out of the last segment)
		var trail =
		{
			tail_segment:0,
			head_segment:0,
			lifetime:lifetime_in_frames,
			total_num_segs:num_segs,
			halfwidth:local_random_range(param_trail_thickness_min, param_trail_thickness_max) * _spritesize * 0.5,
			num_segs:0
		};

		trail.posx = array_create(num_segs);
		trail.posy = array_create(num_segs);
		trail.pt1_posx = array_create(num_segs);
		trail.pt1_posy = array_create(num_segs);
		trail.pt2_posx = array_create(num_segs);
		trail.pt2_posy = array_create(num_segs);
		trail.frame = array_create(num_segs);		// only really need this if we're not adding a segment every frame

		trail.alphascale = 1.0;
		trail.render_alphascale = 1.0;			// can be modified by the particle that drives this trail in order to fade it out

		var colblend = local_random_range(0.0, 1.0);
		trail.cols = array_create(4);
		trail.alphas = array_create(4);

		trail.cols[0] = merge_colour(trail_col[0], trail_col_alt[0], colblend);
		trail.cols[1] = merge_colour(trail_col[1], trail_col_alt[1], colblend);
		trail.cols[2] = merge_colour(trail_col[2], trail_col_alt[2], colblend);
		trail.cols[3] = merge_colour(trail_col[3], trail_col_alt[3], colblend);

		trail.alphas[0] = lerp(trail_alpha[0], trail_alpha_alt[0], colblend);
		trail.alphas[1] = lerp(trail_alpha[1], trail_alpha_alt[1], colblend);
		trail.alphas[2] = lerp(trail_alpha[2], trail_alpha_alt[2], colblend);
		trail.alphas[3] = lerp(trail_alpha[3], trail_alpha_alt[3], colblend);

		trails[num_trails] = trail;
		num_trails++;

		return trail;
	}

	add_trail_segment = function(_trail, _posx, _posy)
	{
		var totalnumsegs = _trail.total_num_segs;
		if (totalnumsegs < 2)
		{
			show_debug_message("Trail has less than two segments and is unusable.");
			return;
		}

		if (_trail.num_segs == 0)
		{
			var headseg = _trail.head_segment;

			// Duplicate first segment
			_trail.posx[headseg] = _posx;
			_trail.posy[headseg] = _posy;
			_trail.frame[headseg] = frame;
			_trail.pt1_posx[headseg] = 0.0;
			_trail.pt1_posy[headseg] = 0.0;
			_trail.pt2_posx[headseg] = 0.0;
			_trail.pt2_posy[headseg] = 0.0;

			headseg = (headseg + 1) % totalnumsegs;

			_trail.posx[headseg] = _posx;
			_trail.posy[headseg] = _posy;
			_trail.frame[headseg] = frame;
			_trail.pt1_posx[headseg] = 0.0;
			_trail.pt1_posy[headseg] = 0.0;
			_trail.pt2_posx[headseg] = 0.0;
			_trail.pt2_posy[headseg] = 0.0;

			headseg = (headseg + 1) % totalnumsegs;

			_trail.head_segment = headseg;
			_trail.num_segs = 2;
		}
		else
		{
			var headseg = (_trail.head_segment + (totalnumsegs - 1)) % totalnumsegs;	// update previous segment

			_trail.posx[headseg] = _posx;
			_trail.posy[headseg] = _posy;
			_trail.frame[headseg] = frame;

			var totalnumsegs = _trail.total_num_segs;
			var sqlength = 0.0;

			var prevseg = (headseg + (totalnumsegs - 1)) % totalnumsegs;
			var diffx = _posx - _trail.posx[prevseg];
			var diffy = _posy - _trail.posy[prevseg];

			var perpvecx, perpvecy;
			sqlength = (diffx * diffx) + (diffy * diffy);
			if (sqlength > 0.0)
			{
				var length = sqrt(sqlength);

				perpvecx = -(diffy / length) * _trail.halfwidth;
				perpvecy = (diffx / length) * _trail.halfwidth;
			}
			else
			{
				perpvecx = _trail.halfwidth;
				perpvecy = 0.0;
			}

			var pt1_posx = _posx - perpvecx;
			var pt1_posy = _posy - perpvecy;
			var pt2_posx = _posx + perpvecx;
			var pt2_posy = _posy + perpvecy;

			_trail.pt1_posx[headseg] = pt1_posx;
			_trail.pt1_posy[headseg] = pt1_posy;
			_trail.pt2_posx[headseg] = pt2_posx;
			_trail.pt2_posy[headseg] = pt2_posy;

			if (_trail.num_segs == 2)
			{
				// If we only have two points in the trail, set the first points perpendicular vectors to the same as the second point
				_trail.pt1_posx[prevseg] = _trail.posx[prevseg] - perpvecx;
				_trail.pt1_posy[prevseg] = _trail.posy[prevseg] - perpvecy;
				_trail.pt2_posx[prevseg] = _trail.posx[prevseg] + perpvecx;
				_trail.pt2_posy[prevseg] = _trail.posy[prevseg] + perpvecy;
			}

			// Ideally we would adjust the offset vectors of the previous point to be perpendicular to the average of the segment vectors
			// on either side of it but that's probably not noticeable in most cases

			if (sqlength >= trail_min_segment_length_sq)
			{
				// Only move the head along if the difference between this point and the last is bigger than our threshold
				var currheadseg = _trail.head_segment;

				// Copy segment info to current head
				_trail.posx[currheadseg] = _posx;
				_trail.posy[currheadseg] = _posy;
				_trail.frame[currheadseg] = frame;
				_trail.pt1_posx[currheadseg] = pt1_posx;
				_trail.pt1_posy[currheadseg] = pt1_posy;
				_trail.pt2_posx[currheadseg] = pt2_posx;
				_trail.pt2_posy[currheadseg] = pt2_posy;

				var nextheadseg = (currheadseg + 1) % totalnumsegs;
				_trail.head_segment = nextheadseg;

				if (nextheadseg == _trail.tail_segment)
				{
					// Could resize here, but for the moment just drop the last segment
					_trail.tail_segment = (_trail.tail_segment + 1) % totalnumsegs;
				}
				else
				{
					_trail.num_segs++;
				}
			}
		}
	}

	update_trails = function()
	{
		var i;
		for (i = 0; i < num_trails;)
		{
			var trail = trails[i];
			var oldestvalidframe = frame - trail.lifetime;

			var totalnumsegs = trail.total_num_segs;
			var trailseg = trail.tail_segment;

			if (trail.head_segment == trailseg)
			{
				// trail has no segments so bin it
				trails[i] = trails[num_trails - 1];
				num_trails--;
			}
			else
			{
				// We only want to remove a segment if the *next* one is too old
				// This preserves segments that are transition points between being alive and dead
				// so we get a smooth alpha fade-out
				var nexttrailseg = (trailseg + 1) % totalnumsegs;
				while((trail.head_segment != nexttrailseg) && (trail.frame[nexttrailseg] < oldestvalidframe))
				{
					trailseg = nexttrailseg;
					nexttrailseg = (nexttrailseg + 1) % totalnumsegs;
					trail.num_segs--;
				}

				var latesttrailseg = (trail.head_segment + (totalnumsegs - 1)) % totalnumsegs;
				if ((trail.frame[latesttrailseg] < oldestvalidframe))		// if the latest segment is older than the threshold, bin the trail
				{
					// trail has run out of segments so bin it
					trails[i] = trails[num_trails - 1];
					num_trails--;
				}
				else
				{
					trail.tail_segment = trailseg;
					i++;
				}
			}
		}
	}

	draw_trails = function()
	{
		var i;

		gpu_set_blendmode_ext(param_trail_src_blend, param_trail_dest_blend);

		for (i = 0; i < num_trails; i++)
		{
			var trail = trails[i];

			var totalnumsegs = trail.total_num_segs;
			if (trail.num_segs < 2)
				continue;			// we need at least two active segments

			var oldestvalidframe = trail.lifetime + frame;

			var cols = trail.cols;
			var alphas = trail.alphas;
			var alphascale = trail.render_alphascale;

			var lifetime = trail.lifetime;

			if (trails_use_trilists)
			{
				// In tests this was considerably slower, despite using less draw calls
				// The GML overhead outways any benefit - still various optimisations possible here though
				draw_primitive_begin(pr_trianglelist);
				var trailseg = trail.tail_segment;
				var headseg = trail.head_segment;
				var col = cols[3];

				var last_pt1_posx = trail.pt1_posx[trailseg];
				var last_pt1_posy = trail.pt1_posy[trailseg];
				var last_pt2_posx = trail.pt2_posx[trailseg];
				var last_pt2_posy = trail.pt2_posy[trailseg];
				var lastcol = col;
				var lastalpha = alphas[3];

				// This could be optimised
				var lifeprop = (frame - trail.frame[trailseg]) / lifetime;
				lifeprop = clamp(lifeprop, 0.0, 1.0);
				var colprop = lifeprop;
				var colzone = 0;
				colprop -= trail_col_dist[0];
				while((colprop > 0.0) && (colzone < 2))
				{
					colzone++
					colprop -= trail_col_dist[colzone];
				}
				var col_dist = trail_col_dist[colzone];
				if (col_dist <= 0.0)
					colprop = 0.0;
				else
					colprop = (lifeprop - trail_col_pos[colzone]) / col_dist;

				lastcol = merge_colour(cols[colzone], cols[colzone+1], colprop);
				lastalpha = lerp(alphas[colzone], alphas[colzone+1], colprop) * alphascale;

				trailseg = (trailseg + 1) % totalnumsegs;

				while(headseg != trailseg)
				{
					// This could be optimised
					lifeprop = (frame - trail.frame[trailseg]) / lifetime;
					lifeprop = clamp(lifeprop, 0.0, 1.0);
					colprop = lifeprop;
					colzone = 0;
					colprop -= trail_col_dist[0];
					while((colprop > 0.0) && (colzone < 2))
					{
						colzone++
						colprop -= trail_col_dist[colzone];
					}
					col_dist = trail_col_dist[colzone];
					if (col_dist <= 0.0)
						colprop = 0.0;
					else
						colprop = (lifeprop - trail_col_pos[colzone]) / col_dist;

					var col = merge_colour(cols[colzone], cols[colzone+1], colprop);
					var alpha = lerp(alphas[colzone], alphas[colzone+1], colprop) * alphascale;

					draw_vertex_colour(last_pt1_posx, last_pt1_posy, lastcol, lastalpha);
					draw_vertex_colour(last_pt2_posx, last_pt2_posy, lastcol, lastalpha);
					draw_vertex_colour(trail.pt1_posx[trailseg], trail.pt1_posy[trailseg], col, alpha);
					draw_vertex_colour(trail.pt1_posx[trailseg], trail.pt1_posy[trailseg], col, alpha);
					draw_vertex_colour(last_pt2_posx, last_pt2_posy, lastcol, lastalpha);
					draw_vertex_colour(trail.pt2_posx[trailseg], trail.pt2_posy[trailseg], col, alpha);

					last_pt1_posx = trail.pt1_posx[trailseg];
					last_pt1_posy = trail.pt1_posy[trailseg];
					last_pt2_posx = trail.pt2_posx[trailseg];
					last_pt2_posy = trail.pt2_posy[trailseg];
					lastcol = col;
					lastalpha = alpha;

					trailseg = (trailseg + 1) % totalnumsegs;
				}
				draw_primitive_end();
			}
			else
			{
				// TODO: Look at joining strips with degenerate tris to reduce draw calls
				draw_primitive_begin(pr_trianglestrip);
				var trailseg = trail.tail_segment;
				var headseg = trail.head_segment;
				while(headseg != trailseg)
				{
					var lifeprop = (frame - trail.frame[trailseg]) / lifetime;
					lifeprop = clamp(lifeprop, 0.0, 1.0);
					var colprop = lifeprop;
					var colzone = 0;
					colprop -= trail_col_dist[0];
					while((colprop > 0.0) && (colzone < 2))
					{
						colzone++
						colprop -= trail_col_dist[colzone];
					}
					var col_dist = trail_col_dist[colzone];
					if (col_dist <= 0.0)
						colprop = 0.0;
					else
						colprop = (lifeprop - trail_col_pos[colzone]) / col_dist;

					var col = merge_colour(cols[colzone], cols[colzone+1], colprop);
					var alpha = lerp(alphas[colzone], alphas[colzone+1], colprop) * alphascale;

					draw_vertex_colour(trail.pt1_posx[trailseg], trail.pt1_posy[trailseg], col, alpha);
					draw_vertex_colour(trail.pt2_posx[trailseg], trail.pt2_posy[trailseg], col, alpha);

					trailseg = (trailseg + 1) % totalnumsegs;
				}
				draw_primitive_end();
			}
		}
	}

	setup_particle = function(_spawnxmin, _spawnxmax, _spawnymin, _spawnymax, _spawnweights, _centrex, _centrey, _view_velx, _view_vely, _gamespeed, _spawn_in_one_zone)
	{
        particle_birth_count += 1;
		var particle =
		{
			velx:local_random_range(param_particle_initial_velocity_range_x_min, param_particle_initial_velocity_range_x_max),
			vely:local_random_range(param_particle_initial_velocity_range_y_min, param_particle_initial_velocity_range_y_max),
			rot:local_random_range(param_particle_initial_rotation_min, param_particle_initial_rotation_max),
			rotspeed:local_random_range(param_particle_rot_speed_min, param_particle_rot_speed_max),
			subimage:local_irandom_range(0, sprite_get_number(param_sprite) - 1),
			mass:max(local_random_range(param_particle_mass_min, param_particle_mass_max), 0.00001),
			lifetime:(local_random_range(param_particle_lifetime_min, param_particle_lifetime_max) * _gamespeed),		// lifetime in frames
			spawnframe:frame, birth_id:particle_birth_count
		};

		if (_spawn_in_one_zone)
		{
			// In this mode, _spawnxmin etc are single values rather than an array
			particle.posx = local_random_range(_spawnxmin, _spawnxmax);
			particle.posy = local_random_range(_spawnymin, _spawnymax);
			particle.lastposx = particle.posx;
			particle.lastposy = particle.posy;
		}
		else
		{
			// Use weighted zone selection so we don't spawn the same amount of particles in smaller zones as larger ones
			// The order of the zones is:
			// +---+---+---+
			// | 0 | 1 | 2 |
			// +---+---+---+
			// | 3 |   | 4 |
			// +---+---+---+
			// | 5 | 6 | 7 |
			// +---+---+---+
			var zonerand = local_random_range(0, 0.9999);
			var zone = 0;
			zonerand -= _spawnweights[zone];
			while((zonerand > 0) && (zone < 7))
			{
				zone++;
				zonerand -= _spawnweights[zone];
			}
			particle.posx = local_random_range(_spawnxmin[zone], _spawnxmax[zone]);
			particle.posy = local_random_range(_spawnymin[zone], _spawnymax[zone]);
			particle.lastposx = particle.posx;
			particle.lastposy = particle.posy;

			var view_rel_velx = particle.velx - _view_velx;
			var view_rel_vely = particle.vely - _view_vely;

			// Make sure the particles are actually on a trajectory that will move then into view
			// If they are moving in the wrong direction, mirror their position across the centre point
			// We could select the correct zone in the first place but that is probably slower as the zones
			// aren't arranged in a regular order
			// See above for zone indicies
			if ((((particle.posx - _spawnxmax[0]) < 0) && (view_rel_velx < 0)) || (((particle.posx - _spawnxmin[2]) > 0) && (view_rel_velx > 0)))
				particle.posx = _centrex + (_centrex - particle.posx);	// flip particle position around centre
			if ((((particle.posy - _spawnymax[0]) < 0) && (view_rel_vely < 0)) || (((particle.posy - _spawnymin[5]) > 0) && (view_rel_vely > 0)))
				particle.posy = _centrey + (_centrey - particle.posy);	// flip particle position around centre
		}

		var colblend = local_random_range(0.0, 1.0);
		particle.cols = array_create(4);
		particle.alphas = array_create(4);

		particle.cols[0] = merge_colour(particle_col[0], particle_col_alt[0], colblend);
		particle.cols[1] = merge_colour(particle_col[1], particle_col_alt[1], colblend);
		particle.cols[2] = merge_colour(particle_col[2], particle_col_alt[2], colblend);
		particle.cols[3] = merge_colour(particle_col[3], particle_col_alt[3], colblend);

		particle.alphas[0] = lerp(particle_alpha[0], particle_alpha_alt[0], colblend);
		particle.alphas[1] = lerp(particle_alpha[1], particle_alpha_alt[1], colblend);
		particle.alphas[2] = lerp(particle_alpha[2], particle_alpha_alt[2], colblend);
		particle.alphas[3] = lerp(particle_alpha[3], particle_alpha_alt[3], colblend);

		if (local_random(100) < param_trail_chance)
		{
			var spritesize = min(sprwidth, sprheight) * particle.mass * param_particle_start_sprite_scale * particle_scale_compensation;
			particle.trail = spawn_trail(local_random_range(param_trail_lifetime_min, param_trail_lifetime_max), spritesize);
			add_trail_segment(particle.trail, particle.posx, particle.posy);
		}
		else
		{
			particle.trail = undefined;
		}

		return particle;
	}

	draw_particles = function()
	{
		gpu_set_blendmode_ext(param_particle_src_blend, param_particle_dest_blend);

		var i;
		for(i = 0; i < num_particles; i++)
		{
			var particle = particles[i];

			var lifeprop = (frame - particle.spawnframe) / particle.lifetime;
			lifeprop = clamp(lifeprop, 0.0, 1.0);

			// Get the interpolated colour and alpha values from our piecewise-linear curve
			// It may be worth converting this to a regularly spaced list of points
			// which would be quicker to evaluate at the cost of some inaccuracy
			var colprop = lifeprop;
			var colzone = 0;
			colprop -= particle_col_dist[0];
			while((colprop > 0.0) && (colzone < 2))
			{
				colzone++
				colprop -= particle_col_dist[colzone];
			}
			var col_dist = particle_col_dist[colzone];
			if (col_dist <= 0.0)
				colprop = 0.0;
			else
				colprop = (lifeprop - particle_col_pos[colzone]) / col_dist;

			var cols = particle.cols;
			var alphas = particle.alphas;

			var spritecol = merge_colour(cols[colzone], cols[colzone+1], colprop);
			var spritealpha = lerp(alphas[colzone], alphas[colzone+1], colprop);

			if (particle.trail != undefined)
			{
				// Logical step commits trail alpha; rendering never writes it.
			}

			if (param_trails_only == 0)
			{
				var rot = 0.0;
				if ((param_particle_align_vel > 0) && (particle.lastposx != particle.posx) && (particle.lastposy != particle.posy))
				{
					var diffx = particle.posx - particle.lastposx;
					var diffy = particle.posy - particle.lastposy;
					var length = sqrt((diffx * diffx) + (diffy * diffy));
					diffy /= length;
					rot = (arccos(-diffy) / pi) * 180.0;
					if (diffx > 0)
						rot = -rot;
				}

				var spritescale = particle.mass * particle_scale_compensation * lerp(param_particle_start_sprite_scale, param_particle_end_sprite_scale, lifeprop);

				draw_sprite_ext(param_sprite, particle.subimage, particle.posx, particle.posy, spritescale, spritescale, particle.rot + rot, spritecol, spritealpha);
			}
		}
	}

	step = function()
	{
		var i, j, k;
		var gamespeed = TCC_SIM_HZ;
		var timedelta = 1.0 / gamespeed;

		// update colour values
		update_colours();

		var minx = 0, maxx = 0, miny = 0, maxy = 0;
		if (view_enabled)
		{
			// Get maximal bounding box of current views
			// Ideally we'd do this based on the actual matrices so we'd handle perspective cameras too
			// But that requires that we know what depth we're drawing at, which isn't practical from Step
			var first = true;
			for(i = 0; i < 8; i++)
			{
				if (view_visible[i])
				{
					var cam = view_camera[i];
					var cam_minx = camera_get_view_x(cam);
					var cam_miny = camera_get_view_y(cam);
					var cam_maxx = cam_minx + camera_get_view_width(cam);
					var cam_maxy = cam_miny + camera_get_view_height(cam);

					if (first)
					{
						first = false;
						minx = cam_minx;
						miny = cam_miny;
						maxx = cam_maxx;
						maxy = cam_maxy;
					}
					else
					{
						minx = min(minx, cam_minx);
						miny = min(miny, cam_miny);
						maxx = max(maxx, cam_maxx);
						maxy = max(maxy, cam_maxy);
					}
				}
			}

		}
		else
		{
			minx = 0;
			miny = 0;
			maxx = room_width;
			maxy = room_height;
		}

		var centrex = (minx + maxx) / 2.0;
		var centrey = (miny + maxy) / 2.0;

		views_minx = minx;
		views_maxx = maxx;
		views_miny = miny;
		views_maxy = maxy;
		views_centrex = centrex;
		views_centrey = centrey;

		if (frame == 0)
		{
			last_view_centrex = centrex;
			last_view_centrey = centrey;
		}

		// Get view movement speed in pixels-per-second
		var view_velx = centrex - last_view_centrex;
		var view_vely = centrey - last_view_centrey;

		if (timedelta != 0)
		{
			view_velx /= timedelta;
			view_vely /= timedelta;
		}

		last_view_centrex = centrex;
		last_view_centrey = centrey;

		var floored_param_force_grid_size_x = floor(param_force_grid_sizex);
		var floored_param_force_grid_size_y = floor(param_force_grid_sizey);

		var cellsizex = (maxx - minx) / (floored_param_force_grid_size_x - (grid_margin * 2));
		var cellsizey = (maxy - miny) / (floored_param_force_grid_size_y - (grid_margin * 2));

		if ((force_grid_sizex != floored_param_force_grid_size_x) ||
			(force_grid_sizey != floored_param_force_grid_size_y))
		{
			force_grid_sizex = floored_param_force_grid_size_x;
			force_grid_sizey = floored_param_force_grid_size_y;

			force_grid = array_create(force_grid_sizey * force_grid_sizex * 2);

			force_grid_centrex = centrex;
			force_grid_centrey = centrey;
		}

		var celldiffx = floor((centrex - force_grid_centrex) / cellsizex);
		var celldiffy = floor((centrey - force_grid_centrey) / cellsizey);

		if (celldiffx > 0)
		{
			force_grid_offsetx += celldiffx;
			force_grid_offsetx = force_grid_offsetx % force_grid_sizex;
			force_grid_centrex += celldiffx * cellsizex;
		}
		else if (celldiffx < 0)
		{
			var celldiff = -celldiffx;
			celldiff = celldiff % force_grid_sizex;

			force_grid_offsetx += (force_grid_sizex - celldiff);
			force_grid_offsetx = force_grid_offsetx % force_grid_sizex;
			force_grid_centrex += celldiffx * cellsizex;
		}

		if (celldiffy > 0)
		{
			force_grid_offsety += celldiffy;
			force_grid_offsety = force_grid_offsety % force_grid_sizey;
			force_grid_centrey += celldiffy * cellsizey;
		}
		else if (celldiffy < 0)
		{
			var celldiff = -celldiffy;
			celldiff = celldiff % force_grid_sizey;

			force_grid_offsety += (force_grid_sizey - celldiff);
			force_grid_offsety = force_grid_offsety % force_grid_sizey;
			force_grid_centrey += celldiffy * cellsizey;
		}

		var grid_basex = force_grid_centrex - ((force_grid_sizex * cellsizex) * 0.5);
		var grid_basey = force_grid_centrey - ((force_grid_sizey * cellsizey) * 0.5);

		var floored_param_num_blowers = floor(param_num_blowers);
		if (num_blowers < floored_param_num_blowers)
		{
			if (array_length(blowers) < floored_param_num_blowers)
			{
				array_resize(blowers, floored_param_num_blowers);
			}

			for(i = num_blowers; i < floored_param_num_blowers; i++)
			{
				blowers[i] = spawn_blower(minx, maxx, miny, maxy);
			}

			num_blowers = floored_param_num_blowers;
		}

		for(i = 0; i < num_blowers;)
		{
			var blower = blowers[i];
			blower.posx += (blower.velx - (view_velx * param_blower_camvec_scale)) * timedelta;
			blower.rot += (blower.rotspeed * timedelta);

			var respawn = false;
			if (((blower.velx < 0) && ((blower.posx + blower.size) < minx)) ||
				((blower.velx > 0) && ((blower.posx - blower.size) > maxx)) ||
				((blower.posy + blower.size) < miny) ||
				((blower.posy - blower.size) > maxy))
			{
				respawn = true;
			}

			if (respawn && (num_blowers > floored_param_num_blowers))
			{
				// remove blower
				blowers[i] = blowers[num_blowers - 1];
				num_blowers--;
			}
			else if (respawn)
			{
				blowers[i] = spawn_blower(minx, maxx, miny, maxy);

				i++;
			}
			else
			{
				i++;
			}
		}

		for(i = 0; i < num_blowers; i++)
		{
			var blower = blowers[i];
			blower.vecx = sin(blower.rot) * blower.force;
			blower.vecy = cos(blower.rot) * blower.force;
		}

		// Fill force grid
		for(i = (force_grid_sizey - 1); i >= 0; i--)
		{
			var gridy = (i + force_grid_offsety) % force_grid_sizey;
			var gridposy = grid_basey + (i * cellsizey);

			for(j = 0; j < force_grid_sizex; j++)
			{
				var gridx = (j + force_grid_offsetx) % force_grid_sizex;
				var gridposx = grid_basex + (j * cellsizex);

				var vecx = param_wind_vector_x;
				var vecy = param_wind_vector_y;

				for(k = 0; k < num_blowers; k++)
				{
					var blower = blowers[k];
					var diffx = blower.posx - gridposx;
					var diffy = blower.posy - gridposy;

					var sqdist = (diffx * diffx) + (diffy * diffy);

					var blowersize = blower.size;
					if (sqdist < (blowersize * blowersize))
					{
						var dist = sqrt(sqdist);
						var weight = 1.0 - (dist / blowersize);

						vecx += blower.vecx * weight;
						vecy += blower.vecy * weight;
					}

				}

				var index = ((gridy * force_grid_sizex) + gridx) * 2;
				force_grid[index] = vecx;
				force_grid[index + 1] = vecy;
			}
		}

		trail_min_segment_length_sq = param_trail_min_segment_length * param_trail_min_segment_length;

		sprwidth = sprite_get_width(param_sprite);
		sprheight = sprite_get_height(param_sprite);

		var max_mass = max(param_particle_mass_min, param_particle_mass_max);
		if (max_mass != 0.0)
		{
			particle_scale_compensation = 1.0 / max_mass;
		}
		else
		{
			particle_scale_compensation = 1.0;
		}

		var sprsize = max(sprwidth, sprheight) * max(param_particle_start_sprite_scale, param_particle_end_sprite_scale);

		var border_prop = max(0.001, param_particle_spawn_border_prop);
		var spawnxmargin = (maxx - minx) * border_prop;
		var spawnymargin = (maxy - miny) * border_prop;

		// Work out off-screen bounds
		var os_spawnboundsx = [ (minx - spawnxmargin) - sprsize, minx - sprsize, maxx + sprsize, maxx + spawnxmargin + sprsize];
		var os_spawnboundsy = [ (miny - spawnymargin) - sprsize, miny - sprsize, maxy + sprsize, maxy + spawnymargin + sprsize];

		var os_spawnxmin = [os_spawnboundsx[0], os_spawnboundsx[1], os_spawnboundsx[2], os_spawnboundsx[0], os_spawnboundsx[2], os_spawnboundsx[0], os_spawnboundsx[1], os_spawnboundsx[2]];
		var os_spawnxmax = [os_spawnboundsx[1], os_spawnboundsx[2], os_spawnboundsx[3], os_spawnboundsx[1], os_spawnboundsx[3], os_spawnboundsx[1], os_spawnboundsx[2], os_spawnboundsx[3]];
		var os_spawnymin = [os_spawnboundsy[0], os_spawnboundsy[0], os_spawnboundsy[0], os_spawnboundsy[1], os_spawnboundsy[1], os_spawnboundsy[2], os_spawnboundsy[2], os_spawnboundsy[2]];
		var os_spawnymax = [os_spawnboundsy[1], os_spawnboundsy[1], os_spawnboundsy[1], os_spawnboundsy[2], os_spawnboundsy[2], os_spawnboundsy[3], os_spawnboundsy[3], os_spawnboundsy[3]];

		var os_spawnweights = [];
		var os_weighttotal = 0.0;
		for(i = 0; i < 7; i++)
		{
			os_spawnweights[i] = (os_spawnxmax[i] - os_spawnxmin[i]) * (os_spawnymax[i] - os_spawnymin[i]);
			os_weighttotal += os_spawnweights[i];
		}

		for(i = 0; i < 7; i++)
		{
			os_spawnweights[i] /= os_weighttotal;
		}

		do
		{
			update_trails();

			var spawnxmin;
			var spawnxmax;
			var spawnymin;
			var spawnymax;
			var spawnweights;
			var spawn_all_now;
			var spawn_in_one_zone;

			if ((frame == 0) && (param_particle_spawn_all_at_start != 0))
			{
				// Spawn particles on-screen
				spawnxmin = (minx - spawnxmargin) - sprsize;
				spawnxmax = maxx + spawnxmargin + sprsize;
				spawnymin = (miny - spawnymargin) - sprsize;
				spawnymax = maxy + spawnymargin + sprsize;
				spawnweights = 0;

				spawn_all_now = true;
				spawn_in_one_zone = true;
			}
			else
			{
				// Spawn particles off-screen
				spawnxmin = os_spawnxmin;
				spawnxmax = os_spawnxmax;
				spawnymin = os_spawnymin;
				spawnymax = os_spawnymax;

				spawnweights = os_spawnweights;

				spawn_all_now = false;
				spawn_in_one_zone = false;
			}

			var floored_param_num_particles = floor(param_num_particles);
			if (num_particles < floored_param_num_particles)
			{
				var new_num_particles = floored_param_num_particles;
				if ((param_particle_spawn_time > 0.0) && (spawn_all_now == false))
				{
					time_since_last_particle += timedelta;

					var spawn_time_seconds = param_particle_spawn_time / 1000.0;

					new_num_particles = min(new_num_particles, num_particles + floor(time_since_last_particle / spawn_time_seconds));
					time_since_last_particle = time_since_last_particle % spawn_time_seconds;
				}

				if (array_length(particles) < new_num_particles)
				{
					array_resize(particles, new_num_particles);
				}

				for(i = num_particles; i < new_num_particles; i++)
				{
					particles[i] = setup_particle(spawnxmin, spawnxmax, spawnymin, spawnymax, spawnweights, centrex, centrey, view_velx, view_vely, gamespeed, spawn_in_one_zone);
				}

				num_particles = new_num_particles;
			}

			var dragcoeffs = air_density * param_dragcoeff * 0.5;

			var update_skip = floor(param_particle_update_skip + 1);
			for(i = 0; i < num_particles;)
			{
				var respawn = false;
				var particle = particles[i];

				if ((particle.spawnframe + particle.lifetime) <= frame)
				{
                    lifetime_respawns += 1;
					respawn = true;
				}

				if (!respawn)
				{
					if (((frame + i) % update_skip) != 0)
					{
						particle.lastposx = particle.posx;
						particle.lastposy = particle.posy;

						particle.posx += particle.velx * timedelta;
						particle.posy += particle.vely * timedelta;

						if (particle.trail != undefined)
						{
							add_trail_segment(particle.trail, particle.posx, particle.posy);
						}

						particle.rot += particle.rotspeed * timedelta;
						i++;

						continue;
					}

					// look up force grid
					var gridx = (particle.posx - grid_basex) / cellsizex;
					var gridy = (particle.posy - grid_basey) / cellsizey;
					var blendx = frac(gridx);
					var blendy = frac(gridy);
					gridx = floor(gridx);
					gridy = floor(gridy);
					gridx = (gridx + force_grid_offsetx) % force_grid_sizex;
					gridy = (gridy + force_grid_offsety) % force_grid_sizey;

					if (gridx < 0)
						gridx = force_grid_sizex + gridx;
					if (gridy < 0)
						gridy = force_grid_sizey + gridy;

					var force1x, force1y, force2x, force2y, force3x, force3y, force4x, force4y;
					var gridtempx1 = gridx;
					var gridtempx2 = ((gridx + 1) % force_grid_sizex);
					var gridtempy1 = gridy * force_grid_sizex;
					var gridtempy2 = ((gridy + 1) % force_grid_sizey) * force_grid_sizex;

					var index1 = (gridtempy1 + gridtempx1) * 2;
					var index2 = (gridtempy1 + gridtempx2) * 2;
					var index3 = (gridtempy2 + gridtempx1) * 2;
					var index4 = (gridtempy2 + gridtempx2) * 2;

					var gridforcex;
					var gridforcey;

					// Sample grid
					force1x = force_grid[index1];
					force1y = force_grid[index1 + 1];

					force2x = force_grid[index2];
					force2y = force_grid[index2 + 1];

					force3x = force_grid[index3];
					force3y = force_grid[index3 + 1];

					force4x = force_grid[index4];
					force4y = force_grid[index4 + 1];

					// Bilinear filter
					// (could precalculate force differences between adjacent cells to avoid having to do subtractions here)
					var topval = ((force2x - force1x) * blendx) + force1x;
					var bottomval = ((force4x - force3x) * blendx) + force3x;
					gridforcex = ((bottomval - topval) * blendy) + topval;

					topval = ((force2y - force1y) * blendx) + force1y;
					bottomval = ((force4y - force3y) * blendx) + force3y;
					gridforcey = ((bottomval - topval) * blendy) + topval;

					var thisparticlemass = particle.mass;

					var particle_velx = particle.velx;
					var particle_vely = particle.vely;

					particle_velx += (gridforcex / thisparticlemass) * timedelta;
					particle_vely += (gridforcey / thisparticlemass) * timedelta;

					// Apply gravity
					particle_vely += param_grav_accel * timedelta;

					// Apply drag
					var forcex = dragcoeffs * particle.mass * (particle_velx * particle_velx);
					var forcey = dragcoeffs * particle.mass * (particle_vely * particle_vely);

					if (particle_velx > 0)
						forcex = -forcex;
					if (particle_vely > 0)
						forcey = -forcey;

					particle_velx += ((forcex / thisparticlemass) * timedelta);
					particle_vely += ((forcey / thisparticlemass) * timedelta);

					particle.velx = particle_velx;
					particle.vely = particle_vely;

					particle.lastposx = particle.posx;
					particle.lastposy = particle.posy;

					particle.posx += particle_velx * timedelta;
					particle.posy += particle_vely * timedelta;

					var view_rel_velx = particle_velx - view_velx;
					var view_rel_vely = particle_vely - view_vely;

					if (((view_rel_velx < 0) && ((particle.posx + sprsize) < minx)) ||
						((view_rel_velx > 0) && ((particle.posx - sprsize) > maxx)) ||
						((view_rel_vely < 0) && ((particle.posy + sprsize) < miny)) ||
						((view_rel_vely > 0) && ((particle.posy - sprsize) > maxy)))
					{
						respawn = true;
                        bounds_respawns += 1;
					}
				}

				if (respawn && (num_particles > floored_param_num_particles))
				{
					// remove particle
					particles[i] = particles[num_particles - 1];
					num_particles--;
				}
				else if (respawn)
				{
					particles[i] = setup_particle(spawnxmin, spawnxmax, spawnymin, spawnymax, spawnweights, centrex, centrey, view_velx, view_vely, gamespeed, spawn_in_one_zone);

					i++;
				}
				else
				{
					if (particle.trail != undefined)
					{
						add_trail_segment(particle.trail, particle.posx, particle.posy);
					}

					particle.rot += particle.rotspeed * timedelta;
					i++;
				}
			}

			frame++;
		} until (frame > param_warmup_frames);
	}

	room_start = function()
	{

	}

	room_end = function()
	{
		reset();
	}

	layer_begin = function()
	{

	}

	layer_end = function()
	{
		if ((event_type != ev_draw) || (event_number != 0))
			return;	// wrong event

		gpu_push_state();

		var oldcol = draw_get_colour();
		var oldalpha = draw_get_alpha();

		draw_trails();
		draw_particles();

		if (param_debug_grid > 0)
		{
			draw_set_colour(c_white);
			draw_set_alpha(debug_grid_alpha);
			var cellsizex = (views_maxx - views_minx) / (force_grid_sizex - (grid_margin * 2));
			var cellsizey = (views_maxy - views_miny) / (force_grid_sizey - (grid_margin * 2));

			var grid_basex = force_grid_centrex - ((force_grid_sizex * cellsizex) * 0.5);
			var grid_basey = force_grid_centrey - ((force_grid_sizey * cellsizey) * 0.5);

			var i, j;

			for(i = 0; i < force_grid_sizey; i++)
			{
				for(j = 0; j < force_grid_sizex; j++)
				{
					var gridx = (j + force_grid_offsetx) % force_grid_sizex;
					var gridy = (i + force_grid_offsety) % force_grid_sizey;

					var index = ((gridy * force_grid_sizex) + gridx) * 2;
					var forcevecx = force_grid[index];
					var forcevecy = force_grid[index + 1];
					forcevecx *= debug_force_scale;
					forcevecy *= debug_force_scale;

					var startx = (grid_basex + (cellsizex * (j + 0.5))) - (forcevecx * 0.5);
					var starty = (grid_basey + (cellsizey * (i + 0.5))) - (forcevecy * 0.5);

					draw_arrow(startx, starty, startx + forcevecx, starty + forcevecy, 10);

				}
			}

			if (param_debug_grid > 1)
			{
				draw_set_colour(c_yellow);
				for(i = 0; i < num_blowers; i++)
				{
					draw_circle(blowers[i].posx, blowers[i].posy, blowers[i].size, true);

					var halfforcevecx = blowers[i].vecx * debug_force_scale * 0.5;
					var halfforcevecy = blowers[i].vecy * debug_force_scale * 0.5;
					draw_arrow(blowers[i].posx - halfforcevecx, blowers[i].posy - halfforcevecy, blowers[i].posx + halfforcevecx, blowers[i].posy + halfforcevecy, 10);
				}
			}
		}

		draw_set_colour(oldcol);
		draw_set_alpha(oldalpha);

		gpu_pop_state();
	}


    // Local Park-Miller stream. Every multiplication is below exact-real2^53.
    // This never reads/reseeds/advances the engine or shared Draw visual RNG.
    if (!credits_windblown_integer(_private_seed, 1, 2147483646)) throw "Credits FX invalid private seed";
    rng_initial_seed = _private_seed;
    rng_state = _private_seed;
    rng_draws = 0;
    particle_birth_count = 0; blower_birth_count = 0; trail_birth_count = 0;
    lifetime_respawns = 0; bounds_respawns = 0;
    local_random = function(_upper) {
        rng_state = (rng_state * 48271) mod 2147483647;
        rng_draws += 1;
        return (rng_state / 2147483647) * _upper;
    };
    local_random_range = function(_low, _high) {
        return _low + local_random(_high - _low);
    };
    local_irandom_range = function(_low, _high) {
        var _min = ceil(min(_low, _high)), _max = floor(max(_low, _high));
        return _min + floor(local_random(_max - _min + 1));
    };

    // Called only after the original complete60Hz model step. This preserves
    // old60 trails-before-particles alpha sample order even if a Draw is skipped
    // or repeated. Current authored particle alpha is1 throughout.
    commit_render_alpha = function() {
        for (var _t = 0; _t < num_trails; ++_t)
            trails[_t].render_alphascale = trails[_t].alphascale;
        for (var _p = 0; _p < num_particles; ++_p) {
            var _particle = particles[_p];
            if (is_undefined(_particle.trail)) continue;
            var _life = clamp((frame - _particle.spawnframe) / _particle.lifetime, 0, 1);
            var _prop = _life, _zone = 0;
            _prop -= particle_col_dist[0];
            while (_prop > 0 && _zone < 2) { _zone += 1; _prop -= particle_col_dist[_zone]; }
            var _dist = particle_col_dist[_zone];
            _prop = _dist <= 0 ? 0 : (_life - particle_col_pos[_zone]) / _dist;
            _particle.trail.alphascale = lerp(_particle.alphas[_zone], _particle.alphas[_zone + 1], _prop);
        }
    };
    render = function() {
        if (event_type != ev_draw || event_number != 0) return;
        if (!credits_windblown_active()
            || !array_equals([self], [global.tcc_credits_windblown_state.model])) return;
        credits_windblown_qa_observe("layer-before", true);
        // Ordinary bound layer callback, not manual event dispatch.
        layer_end();
        credits_windblown_qa_observe("layer-after", true);
    };
    // Final caller parameters precede all sprite/color/force initialization.
    var _names = variable_struct_get_names(_parameters);
    for (var _n = 0; _n < array_length(_names); ++_n)
        variable_struct_set(self, _names[_n], variable_struct_get(_parameters, _names[_n]));
	reset();
}

function credits_windblown_active() {
    if (!variable_global_exists("tcc_credits_windblown_state")
        || !is_struct(global.tcc_credits_windblown_state)
        || !variable_global_exists("tcc_timing")) return false;
    var _w = global.tcc_credits_windblown_state;
    return _w.ready && _w.invalid == "" && _w.room_ref == room
        && _w.generation == global.tcc_timing.room_generation;
}

// Call only at Room End/Cleanup, or forget_only after the root has advanced the
// real Room Start generation. Never clear a reused layer ID in a later room.
function credits_windblown_teardown(_forget_only = false) {
    if (!variable_global_exists("tcc_credits_windblown_state")
        || !is_struct(global.tcc_credits_windblown_state)) return;
    var _w = global.tcc_credits_windblown_state;
    credits_windblown_qa_observe("teardown");
    var _same = variable_global_exists("tcc_timing") && room == _w.room_ref
        && global.tcc_timing.room_generation == _w.generation;
    if (_forget_only && _same) throw "Credits FX cannot forget a live same-generation callback";
    if (!_forget_only && _same && layer_exists(_w.layer_ref) && is_struct(_w.model)) {
        if (array_equals([layer_get_script_end(_w.layer_ref)], [_w.model.render]))
            layer_script_end(_w.layer_ref, -1);
    }
    _w.ready = false;
    global.tcc_credits_windblown_state = undefined;
    // No owned native buffers/surfaces/maps. Array/method ownership is managed.
}

function credits_windblown_init() {
    // Root calls once after generation advances. Stale old-room layers are
    // already engine-owned teardown; only drop their managed state here.
    if (credits_windblown_active()) return true;
    if (variable_global_exists("tcc_credits_windblown_state")
        && is_struct(global.tcc_credits_windblown_state)) {
        var _previous = global.tcc_credits_windblown_state;
        if (_previous.room_ref == room && _previous.generation == global.tcc_timing.room_generation)
            return _previous.ready; // repeated failed setup remains fail-closed
    }
    credits_windblown_teardown(true);
    if (room != r_credits) return false;
    var _t = global.tcc_timing;
    credits_windblown_qa_setup();
    var _w = {ready:false, invalid:"", room_ref:room, generation:_t.room_generation,
        layer_ref:noone, model:undefined, last_tick:-1, ticks:0,
        private_seed:246813579, diagnostic_disabled:false,
        stock_removed:false, renderer_attached:false, setup:undefined};
    global.tcc_credits_windblown_state = _w;
    var _stock = undefined;
    var _removed = false;
    try {
        if (TCC_GAMEPLAY_QA && qa_active()) {
            var _option = credits_windblown_value(global.tcc_qa.spec, "creditsWindblownObservation", undefined);
            if (is_struct(_option)) {
                _w.private_seed = credits_windblown_value(_option, "privateSeed", _w.private_seed);
                var _enabled = credits_windblown_value(_option, "enabled", true);
                if (!is_bool(_enabled)) throw "Credits FX diagnostic enabled must be boolean";
                _w.diagnostic_disabled = !_enabled;
            }
        }
        _w.layer_ref = layer_get_id("Effect_1");
        if (!layer_exists(_w.layer_ref)) throw "Credits FX authored Effect_1 missing";
        if (layer_get_depth(_w.layer_ref) != 100) throw "Credits FX authored depth changed";
        if (layer_get_script_end(_w.layer_ref) != -1)
            throw "Credits FX will not overwrite an existing public layer-end callback";
        _stock = layer_get_fx(_w.layer_ref);
        if (is_undefined(_stock) || _stock == -1 || fx_get_name(_stock) != "_effect_windblown_particles")
            throw "Credits FX expected authored windblown effect";
        var _parameters = credits_windblown_parameters(fx_get_parameters(_stock));
        _w.model = new tcc_credits_windblown(_parameters, _w.private_seed);
        layer_clear_fx(_w.layer_ref);
        _removed = true;
        if (layer_get_fx(_w.layer_ref) != -1) throw "Credits FX stock removal was not observed";
        _w.stock_removed = true;
        layer_script_end(_w.layer_ref, _w.model.render);
        if (!array_equals([layer_get_script_end(_w.layer_ref)], [_w.model.render]))
            throw "Credits FX native layer-end attachment was not observed";
        _w.renderer_attached = true;
        _w.ready = true;
        _w.setup = {room:room_get_name(room), generation:_w.generation,
            outerId:timing_render_id(), tickId:timing_tick_id(), layerRef:_w.layer_ref,
            depth:layer_get_depth(_w.layer_ref), effectName:"_effect_windblown_particles",
            parameters:_parameters, privateSeed:_w.private_seed,
            stockRemoved:_w.stock_removed, rendererAttached:_w.renderer_attached,
            diagnosticDisabled:_w.diagnostic_disabled};
    } catch (_error) {
        _w.invalid = credits_windblown_error(_error);
        _w.ready = false;
        // Restore the original FX only on failed setup, without retaining its
        // opaque reference globally or overwriting a later/unowned callback.
        try {
            if (layer_exists(_w.layer_ref)) {
                if (is_struct(_w.model)
                    && array_equals([layer_get_script_end(_w.layer_ref)], [_w.model.render]))
                    layer_script_end(_w.layer_ref, -1);
                if (_removed && !is_undefined(_stock) && _stock != -1
                    && layer_get_fx(_w.layer_ref) == -1) layer_set_fx(_w.layer_ref, _stock);
            }
        } catch (_rollback_error) {
            _w.invalid += "; setup rollback: " + credits_windblown_error(_rollback_error);
        }
    }
    credits_windblown_qa_observe("setup");
    return _w.ready;
}

// Root End, before Begin is marked pending. Stock native FX is no longer on the
// layer; this ordinary script call is the only model update, not an event call.
function credits_windblown_tick() {
    if (!credits_windblown_active() || !timing_is_tick()) return false;
    var _t = global.tcc_timing, _w = global.tcc_credits_windblown_state;
    if (_t.begin_pending || _w.last_tick == timing_tick_id()) return false;
    _w.last_tick = timing_tick_id();
    if (_w.diagnostic_disabled) return false;
    try {
        _w.model.step();
        _w.model.commit_render_alpha();
        _w.ticks += 1;
    } catch (_error) {
        _w.invalid = credits_windblown_error(_error);
        _w.ready = false;
    }
    return _w.ready;
}

// Optional native diagnostic reads. This has no QA-clock/player/input/room
// mutation. Root must provide an explicit no-player diagnostic clock adapter.
function credits_windblown_qa_setup() {
    if (!TCC_GAMEPLAY_QA || !qa_active()) return;
    var _option = credits_windblown_value(global.tcc_qa.spec, "creditsWindblownObservation", undefined);
    if (is_undefined(_option) || (variable_struct_exists(global.tcc_qa, "credits_windblown_observation")
        && is_struct(global.tcc_qa.credits_windblown_observation))) return;
    var _d = {schemaVersion:1, fixture:"credits-windblown-native-v1", spec:_option,
        invalid:"", start_tick:-1, start_outer:-1, serial:0, samples:[], lifecycle:[],
        max_samples:8192, first_ticks:240, stride:1, max_trails:512,
        truncated:false, dropped:0, lifecycle_truncated:false, phase_counts:{},
        last_end_outer:-1, last_end_draw_scheduled:false, last_post_outer:-1};
    global.tcc_qa.credits_windblown_observation = _d;
    if (!is_struct(_option) || credits_windblown_value(_option, "kind", "") != "credits-native-v1") {
        _d.invalid = "Credits FX diagnostic options require credits-native-v1"; return;
    }
    _d.max_samples = credits_windblown_value(_option, "maxSamples", 8192);
    _d.first_ticks = credits_windblown_value(_option, "firstTicks", 240);
    _d.stride = credits_windblown_value(_option, "traceEveryTicks", 1);
    if (!credits_windblown_integer(_d.max_samples, 128, 12000)
        || !credits_windblown_integer(_d.first_ticks, 0, 240)
        || !credits_windblown_integer(_d.stride, 1, 120)) _d.invalid = "Credits FX invalid diagnostic bounds";
}

function credits_windblown_qa_copy(_value, _depth = 0, _budget = undefined) {
    if (is_undefined(_budget)) _budget = {nodes:0};
    _budget.nodes += 1;
    if (_depth > 8 || _budget.nodes > 100000) throw "Credits FX raw copy exceeded diagnostic budget";
    if (is_undefined(_value) || is_bool(_value) || is_string(_value)) return _value;
    if (is_real(_value)) {
        if (is_nan(_value) || is_infinity(_value)) throw "Credits FX raw model contains nonfinite number";
        return _value;
    }
    if (is_array(_value)) {
        if (array_length(_value) > 512) throw "Credits FX raw array exceeds diagnostic budget";
        var _array = [];
        for (var _a = 0; _a < array_length(_value); ++_a)
            array_push(_array, credits_windblown_qa_copy(_value[_a], _depth + 1, _budget));
        return _array;
    }
    if (is_struct(_value)) {
        var _copy = {}, _names = variable_struct_get_names(_value);
        if (array_length(_names) > 64) throw "Credits FX raw struct exceeds diagnostic budget";
        for (var _n = 0; _n < array_length(_names); ++_n)
            variable_struct_set(_copy, _names[_n], credits_windblown_qa_copy(variable_struct_get(_value, _names[_n]), _depth + 1, _budget));
        return _copy;
    }
    throw "Credits FX raw model has unsupported native value";
}

function credits_windblown_qa_snapshot(_w) {
    var _same = _w.room_ref == room && _w.generation == global.tcc_timing.room_generation;
    var _s = {ready:_w.ready, invalid:_w.invalid, ownerRoom:room_get_name(_w.room_ref),
        ownerGeneration:_w.generation, sameGeneration:_same, layerRef:_w.layer_ref,
        nativeLayerQueried:_same, nativeLayerPresent:undefined,
        stockFxPresent:undefined, ownRendererPresent:undefined,
        stockRemoved:_w.stock_removed, rendererAttached:_w.renderer_attached,
        diagnosticDisabled:_w.diagnostic_disabled, lastTick:_w.last_tick, ticks:_w.ticks};
    if (_same) {
        _s.nativeLayerPresent = layer_exists(_w.layer_ref);
        if (_s.nativeLayerPresent != 0) {
            _s.stockFxPresent = layer_get_fx(_w.layer_ref) != -1;
            if (is_struct(_w.model))
                _s.ownRendererPresent = array_equals([layer_get_script_end(_w.layer_ref)], [_w.model.render]);
        }
    }
    if (!is_struct(_w.model)) return _s;
    var _m = _w.model;
    if (!is_array(_m.particles) || _m.num_particles < 0 || _m.num_particles > 40
        || !is_array(_m.blowers) || _m.num_blowers < 0 || _m.num_blowers > 3
        || !is_array(_m.trails) || _m.num_trails < 0 || _m.num_trails > 512)
        throw "Credits FX raw arrays exceed declared bounds";
    _s.model = {frame:_m.frame, rngInitialSeed:_m.rng_initial_seed,
        rngState:_m.rng_state, rngDraws:_m.rng_draws,
        particleBirths:_m.particle_birth_count, blowerBirths:_m.blower_birth_count,
        trailBirths:_m.trail_birth_count, lifetimeRespawns:_m.lifetime_respawns,
        boundsRespawns:_m.bounds_respawns, numParticles:_m.num_particles,
        numBlowers:_m.num_blowers, numTrails:_m.num_trails,
        spawnElapsed:_m.time_since_last_particle,
        views:{minx:_m.views_minx, maxx:_m.views_maxx, miny:_m.views_miny, maxy:credits_windblown_value(_m, "views_maxy", undefined)},
        grid:{sizex:_m.force_grid_sizex, sizey:_m.force_grid_sizey,
            centrex:_m.force_grid_centrex, centrey:_m.force_grid_centrey,
            offsetx:_m.force_grid_offsetx, offsety:_m.force_grid_offsety, available:is_array(_m.force_grid), values:[]},
        spriteRef:_m.param_sprite, spriteOrigin:{x:sprite_get_xoffset(_m.param_sprite), y:sprite_get_yoffset(_m.param_sprite)}, particles:[], blowers:[], trails:[]};
    if (is_array(_m.force_grid)) {
        if (array_length(_m.force_grid) > 128) throw "Credits FX raw grid exceeds authored8x8 vector field";
        _s.model.grid.values = credits_windblown_qa_copy(_m.force_grid);
    }
    for (var _p = 0; _p < _m.num_particles; ++_p)
        array_push(_s.model.particles, credits_windblown_qa_copy(_m.particles[_p]));
    for (var _b = 0; _b < _m.num_blowers; ++_b)
        array_push(_s.model.blowers, credits_windblown_qa_copy(_m.blowers[_b]));
    for (var _r = 0; _r < _m.num_trails; ++_r) {
        var _trail = _m.trails[_r];
        if (!is_array(_trail.posx) || array_length(_trail.posx) > 31)
            throw "Credits FX trail exceeds authored half-second segment budget";
        array_push(_s.model.trails, credits_windblown_qa_copy(_trail));
    }
    // This getter reads a seed, not a documented complete engine RNG snapshot.
    _s.gameplaySeedRead = random_get_seed();
    return _s;
}

// Optional raw observation only, immediately outside the private renderer.
// Each public query preserves its own native type/error. No matrix, draw or
// GPU setter, playback, input, random call or model update is performed here.
function credits_windblown_qa_draw_query(_operation) {
    var _record = {operation:_operation, ok:false, returned:false,
        nativeType:undefined, nativeArrayLength:undefined, value:undefined,
        errorType:undefined, error:undefined};
    var _native = undefined, _gpu = undefined, _gpu_returned = false;
    try {
        switch (_operation) {
            case "matrix_get_world": _native = matrix_get(matrix_world); break;
            case "matrix_get_view": _native = matrix_get(matrix_view); break;
            case "matrix_get_projection": _native = matrix_get(matrix_projection); break;
            case "draw_get_colour": _native = draw_get_colour(); break;
            case "draw_get_alpha": _native = draw_get_alpha(); break;
            case "gpu_get_state_blending":
                _gpu = gpu_get_state(); _gpu_returned = true;
                _record.returned = true; _record.nativeType = typeof(_gpu);
                _record.mapPresentNative = ds_exists(_gpu, ds_type_map);
                if (_record.mapPresentNative == 0) throw "Credits Draw GPU getter did not return a map";
                // Bounded subset: the only GPU setting this renderer changes
                // is extended blending. Preserve separate-alpha intent too.
                var _keys = ["blendenable", "sepalphaenable", "srcblend", "destblend",
                    "srcblendalpha", "destblendalpha"];
                _record.value = {}; _record.nativeValueTypes = {};
                for (var _k = 0; _k < array_length(_keys); ++_k) {
                    var _key = _keys[_k];
                    if (!ds_map_exists(_gpu, _key)) throw "Credits Draw GPU map missing " + _key;
                    var _value = ds_map_find_value(_gpu, _key);
                    variable_struct_set(_record.nativeValueTypes, _key, typeof(_value));
                    var _flag = _k < 2;
                    if (_flag && is_bool(_value)) {
                        variable_struct_set(_record.value, _key, _value);
                    } else {
                        if (!is_real(_value) || is_bool(_value) || is_nan(_value) || is_infinity(_value)
                            || _value != floor(_value) || (_flag && _value != 0 && _value != 1))
                            throw "Credits Draw GPU map invalid native " + _key;
                        // Numeric native Boolean representations are retained,
                        // not cast to a synthetic Boolean/default value.
                        variable_struct_set(_record.value, _key, _value);
                    }
                }
                break;
            default: throw "Credits Draw unknown native query " + _operation;
        }
        if (_operation != "gpu_get_state_blending") {
            _record.returned = true; _record.nativeType = typeof(_native);
            if (_operation == "matrix_get_world" || _operation == "matrix_get_view"
                || _operation == "matrix_get_projection") {
                if (!is_array(_native)) throw "Credits Draw native matrix is not an array";
                _record.nativeArrayLength = array_length(_native);
                if (_record.nativeArrayLength != 16) throw "Credits Draw native matrix is not length16";
                var _copy = [];
                for (var _m = 0; _m < 16; ++_m) {
                    var _entry = _native[_m];
                    if (!is_real(_entry) || is_bool(_entry) || is_nan(_entry) || is_infinity(_entry))
                        throw "Credits Draw native matrix contains a nonfinite/nonreal value";
                    array_push(_copy, _entry);
                }
                _record.value = _copy;
            } else {
                if (!is_real(_native) || is_bool(_native) || is_nan(_native) || is_infinity(_native))
                    throw "Credits Draw native scalar is nonfinite/nonreal";
                if (_operation == "draw_get_alpha" && (_native < 0 || _native > 1))
                    throw "Credits Draw native alpha is outside0..1";
                _record.value = _native;
            }
        }
        _record.ok = true;
    } catch (_read_error) {
        _record.errorType = typeof(_read_error);
        _record.error = credits_windblown_error(_read_error);
    }
    // Destroy only the actual map returned by this getter, and only after
    // native map presence was observed. A getter failure invents no handle.
    if (_gpu_returned && !is_undefined(credits_windblown_value(_record, "mapPresentNative", undefined))
        && _record.mapPresentNative != 0) {
        _record.mapCleanupAttempted = true;
        try {
            ds_map_destroy(_gpu); _record.mapCleanupSucceeded = true;
        } catch (_cleanup_error) {
            _record.mapCleanupSucceeded = false; _record.ok = false;
            _record.mapCleanupErrorType = typeof(_cleanup_error);
            _record.mapCleanupError = credits_windblown_error(_cleanup_error);
        }
    }
    return _record;
}

function credits_windblown_qa_draw_state() {
    var _state = {schemaVersion:1, fixture:"credits-native-draw-state-v1",
        actualDrawContext:event_type == ev_draw && event_number == 0,
        nativeEventType:event_type, nativeEventNumber:event_number,
        queries:[], contextError:undefined};
    if (!_state.actualDrawContext) {
        _state.contextError = "Credits Draw getters require a genuine ordinary Draw callback";
        return _state;
    }
    var _operations = ["matrix_get_world", "matrix_get_view", "matrix_get_projection",
        "draw_get_colour", "draw_get_alpha", "gpu_get_state_blending"];
    for (var _q = 0; _q < array_length(_operations); ++_q)
        array_push(_state.queries, credits_windblown_qa_draw_query(_operations[_q]));
    return _state;
}

function credits_windblown_qa_observe(_phase, _draw_context = false) {
    if (!TCC_GAMEPLAY_QA || !qa_active()
        || !variable_struct_exists(global.tcc_qa, "credits_windblown_observation")) return;
    var _d = global.tcc_qa.credits_windblown_observation;
    if (_d.invalid != "" || global.tcc_qa.finished
        || !variable_global_exists("tcc_credits_windblown_state")
        || !is_struct(global.tcc_credits_windblown_state)) return;
    var _w = global.tcc_credits_windblown_state, _t = global.tcc_timing;
    if (!is_string(_phase) || !is_bool(_draw_context)
        || !array_contains(["setup", "teardown", "root-begin", "root-end", "pre-draw", "layer-before", "layer-after", "post-draw"], _phase)
        || ((_phase == "layer-before" || _phase == "layer-after") != _draw_context)) {
        _d.invalid = "Credits FX invalid diagnostic phase/context"; return;
    }
    if (_phase == "root-end") {
        _d.last_end_outer = timing_render_id(); _d.last_end_draw_scheduled = _t.draw_frame;
    }
    if (_phase == "post-draw") _d.last_post_outer = timing_render_id();
    if (_d.start_tick < 0 && _phase == "root-begin" && _w.ready && timing_is_tick()) {
        _d.start_tick = timing_tick_id(); _d.start_outer = timing_render_id();
    }
    var _life = _phase == "setup" || _phase == "teardown";
    if (!_life && _d.start_tick < 0) return;
    var _relative = _d.start_tick < 0 ? undefined : timing_tick_id() - _d.start_tick;
    if (!_life && _relative >= _d.first_ticks && _relative mod _d.stride != 0) return;
    if ((!_life && array_length(_d.samples) >= _d.max_samples)
        || (_life && array_length(_d.lifecycle) >= 32)) {
        if (_life) _d.lifecycle_truncated = true; else _d.truncated = true;
        _d.dropped += 1; return;
    }
    var _cost = get_timer();
    _d.serial += 1;
    var _sample = {phase:_phase, serial:_d.serial, room:room_get_name(room),
        roomGeneration:_t.room_generation, outerId:timing_render_id(), tickId:timing_tick_id(),
        relativeTick:_relative, isTick:timing_is_tick(), paused:global.pause != 0,
        generatedDrawFrames:_t.drawn_frames, drawScheduled:_t.draw_frame,
        nativeOuterHz:game_get_speed(gamespeed_fps), requestedRenderCap:global.renderfps,
        gameplayHz:global.maxfps, elapsedUs:_t.elapsed_us, debtUs:_t.accumulator_us,
        beginPending:_t.begin_pending, drawContext:_draw_context,
        nativeEventType:event_type, nativeEventNumber:event_number,
        viewIndex:_draw_context ? view_current : undefined};
    if (_draw_context) _sample.drawState = credits_windblown_qa_draw_state();
    try { _sample.state = credits_windblown_qa_snapshot(_w); }
    catch (_read_error) { _sample.readError = credits_windblown_error(_read_error); _d.invalid = _sample.readError; }
    _sample.observerCostUs = get_timer() - _cost;
    variable_struct_set(_d.phase_counts, _phase, credits_windblown_value(_d.phase_counts, _phase, 0) + 1);
    if (_life) array_push(_d.lifecycle, _sample); else array_push(_d.samples, _sample);
}

function credits_windblown_qa_summary() {
    if (!TCC_GAMEPLAY_QA || !qa_active()
        || !variable_struct_exists(global.tcc_qa, "credits_windblown_observation")) return undefined;
    var _d = global.tcc_qa.credits_windblown_observation;
    return {schemaVersion:_d.schemaVersion, fixture:_d.fixture, verdict:"unassessed", spec:_d.spec,
        invalid:_d.invalid, startTick:_d.start_tick, startOuter:_d.start_outer,
        maxSamples:_d.max_samples, firstTicks:_d.first_ticks, traceEveryTicks:_d.stride,
        samples:_d.samples, lifecycle:_d.lifecycle, phaseCounts:_d.phase_counts,
        samplesTruncated:_d.truncated, lifecycleTruncated:_d.lifecycle_truncated,
        droppedSamples:_d.dropped, lastEndOuter:_d.last_end_outer, lastPostDrawOuter:_d.last_post_outer,
        terminalEndAwaitingPostDraw:_d.last_end_outer >= 0 && _d.last_end_draw_scheduled
            && _d.last_end_outer != _d.last_post_outer};
}
