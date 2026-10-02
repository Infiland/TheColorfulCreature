function scr_troop_nav_grids_equal(_a, _b) {
    if (ds_grid_width(_a) != ds_grid_width(_b) || ds_grid_height(_a) != ds_grid_height(_b)) return false;
    for (var _y = 0; _y < ds_grid_height(_a); ++_y) {
        for (var _x = 0; _x < ds_grid_width(_a); ++_x) {
            if (_a[# _x, _y] != _b[# _x, _y]) return false;
        }
    }
    return true;
}

// Compare every cell while the native world is unchanged within this event.
// Direct builders intentionally retain the caller's collision-query context.
function scr_troop_nav_geometry_probe(_name, _gx = -1, _gy = -1, _expected = -1) {
    var _reference = -1, _candidate = -1, _report = undefined, _failure = undefined;
    try {
        var _started = get_timer();
        _reference = scr_troop_build_grid_reference();
        var _reference_us = get_timer() - _started;
        _started = get_timer();
        _candidate = scr_troop_build_grid_instances();
        var _candidate_us = get_timer() - _started;
        var _difference = scr_troop_nav_grid_difference(_reference, _candidate);
        _report = {name:_name, reference_us:_reference_us, instance_us:_candidate_us, result:_difference};
        if (_gx >= 0 && _gy >= 0) {
            _report.cell = {gx:_gx, gy:_gy, reference:_reference[# _gx, _gy],
                candidate:_candidate[# _gx, _gy], expected:_expected};
            if (_reference[# _gx, _gy] != _expected || _candidate[# _gx, _gy] != _expected) {
                show_debug_message("TCC_NAV_GRID_FIXTURE_FAIL " + json_stringify(_report));
                throw "Navigation fixture cell has wrong occupancy: " + _name;
            }
        }
        if (!_difference.equal) {
            show_debug_message("TCC_NAV_GRID_FIXTURE_FAIL " + json_stringify(_report));
            throw "Navigation geometry fixture differs: " + _name;
        }
    } catch (_error) { _failure = _error; }
    if (ds_exists(_reference, ds_type_grid)) ds_grid_destroy(_reference);
    if (ds_exists(_candidate, ds_type_grid)) ds_grid_destroy(_candidate);
    if (!is_undefined(_failure)) throw _failure;
    return _report;
}

function scr_troop_nav_geometry_fixture() {
    if (!TCC_SELF_CHECK) return undefined;
    var _owned = [], _checks = [], _failure = undefined;
    var _saved_pause = variable_global_exists("pause") ? global.pause : undefined;
    try {
        // Fractional/negative transforms, alternate masks and a mask-only
        // instance. Bounds choose candidates; native tests decide each cell.
        array_push(_owned, timing_create_depth(40.25, 48.5, 0, o_anyblock,
            {sprite_index:s_block, mask_index:s_block, image_xscale:0.5, image_yscale:1.5}));
        array_push(_owned, timing_create_depth(128, 48, 0, o_anyblock,
            {sprite_index:s_block, mask_index:s_lockedblock, image_xscale:-2, image_yscale:0.5}));
        array_push(_owned, timing_create_depth(192, 48, 0, o_anyblock,
            {sprite_index:noone, mask_index:s_block, image_angle:33}));
        if (collision_point(48, 80, _owned[0], false, false) == noone) {
            throw "Calling-instance fixture does not cover its sampled cell";
        }
        array_push(_checks, scr_troop_nav_geometry_probe("fractional-negative-mask-rectangle", 1, 2, NAV_SOLID));
        // The reference excludes the caller from its broad any-block query.
        // Testing in a block context catches an accidental with/self change.
        var _caller_check = undefined;
        with (_owned[0]) { _caller_check = scr_troop_nav_geometry_probe("calling-block-exclusion", 1, 2, NAV_AIR); }
        array_push(_checks, _caller_check);
        for (var _i = 0; _i < array_length(_owned); ++_i) with (_owned[_i]) instance_destroy();
        _owned = [];

        // Each orientation/transform is compared separately, so a second
        // triangle cannot conceal a missed diagonal or flipped tip.
        var _transforms = [[1,1],[-2,1],[1,-2],[0.5,2],[2,0.5],[-0.5,-0.5]];
        for (var _t = 0; _t < array_length(_transforms); ++_t) {
            for (var _o = 0; _o < 4; ++_o) {
                var _slope = timing_create_depth(80, 112, 0, o_whiteblockslope,
                    {orientation:_o, image_index:_o,
                     image_xscale:_transforms[_t][0], image_yscale:_transforms[_t][1]});
                array_push(_owned, _slope);
                array_push(_checks, scr_troop_nav_geometry_probe("slope-" + string(_o) + "-transform-" + string(_t)));
                with (_slope) instance_destroy();
            }
        }
        _owned = [];

        // Solid beats ladder, ladder beats support, and one-way geometry is
        // support only in the cell above. A mask remains valid without art.
        array_push(_owned, timing_create_depth(32, 64, 0, o_onewayupblock,
            {mask_index:s_onewayupblock}));
        array_push(_owned, timing_create_depth(64, 64, 0, o_anyblock,
            {sprite_index:s_block, mask_index:s_block}));
        array_push(_owned, timing_create_depth(64, 64, 0, o_ladder));
        array_push(_owned, timing_create_depth(96, 64, 0, o_ladder));
        array_push(_owned, timing_create_depth(96, 64, 0, o_onewayupblock,
            {mask_index:s_onewayupblock}));
        array_push(_checks, scr_troop_nav_geometry_probe("oneway-ladder-solid-priority"));

        // A mixed open/closed overlap must use native selected-instance
        // semantics, not union every closed instance. Exercise both families.
        var _lock_objects = [o_lockedblock, o_unlockedblock];
        var _lock_ids = [];
        for (var _family = 0; _family < 2; ++_family) {
            for (var _order = 0; _order < 2; ++_order) {
                var _x = (5 + _family * 2 + _order) * 32;
                var _first = timing_create_depth(_x, 64, 0, _lock_objects[_family]);
                var _second = timing_create_depth(_x, 64, 0, _lock_objects[_family]);
                _first.sprite_index = (_order == 0) ? s_unlockedblock : s_lockedblock;
                _second.sprite_index = (_order == 0) ? s_lockedblock : s_unlockedblock;
                array_push(_owned, _first); array_push(_owned, _second);
                array_push(_lock_ids, _first); array_push(_lock_ids, _second);
            }
        }
        array_push(_checks, scr_troop_nav_geometry_probe("selected-overlapping-locks"));
        for (var _i = 0; _i < array_length(_lock_ids); ++_i) {
            var _lock = _lock_ids[_i];
            _lock.sprite_index = (_lock.sprite_index == s_lockedblock) ? s_unlockedblock : s_lockedblock;
        }
        array_push(_checks, scr_troop_nav_geometry_probe("toggled-overlapping-locks"));

        // The normal child Create runs while pause prevents its camera helper
        // from needing ordinary app setup. No Step or gameplay state is run.
        global.pause = 1;
        var _moving = timing_create_depth(64, 129, 0, o_redblockmove,
            {sprite_index:s_redblockplatform, mask_index:s_redblockplatform});
        array_push(_owned, _moving);
        global.pause = is_undefined(_saved_pause) ? 0 : _saved_pause;
        if (collision_point(80, 144, _moving, false, true) == noone) {
            throw "Moving descendant fixture does not cover its sampled cell";
        }
        array_push(_checks, scr_troop_nav_geometry_probe("moving-descendant-body-excluded", 2, 4, NAV_AIR));
        array_push(_checks, scr_troop_nav_geometry_probe("moving-descendant-support-excluded", 2, 3, NAV_AIR));
        _moving.x += 32;
        if (collision_point(112, 144, _moving, false, true) == noone) {
            throw "Moved descendant fixture does not cover its sampled cell";
        }
        array_push(_checks, scr_troop_nav_geometry_probe("moved-descendant-body-excluded", 3, 4, NAV_AIR));
        array_push(_checks, scr_troop_nav_geometry_probe("moved-descendant-support-excluded", 3, 3, NAV_AIR));

        instance_deactivate_object(o_anyblock);
        instance_deactivate_object(o_ladder);
        instance_deactivate_object(o_onewayupblock);
        instance_deactivate_object(o_slope);
        instance_deactivate_object(o_lockedblock);
        instance_deactivate_object(o_unlockedblock);
        array_push(_checks, scr_troop_nav_geometry_probe("same-deactivated-query-world"));
        // Same activation set as the ordinary cached rebuild. No lost culled
        // geometry, including key locks that live outside the solid parent.
        timing_activate_object(o_anyblock);
        timing_activate_object(o_ladder);
        timing_activate_object(o_onewayupblock);
        timing_activate_object(o_slope);
        timing_activate_object(o_lockedblock);
        timing_activate_object(o_unlockedblock);
        array_push(_checks, scr_troop_nav_geometry_probe("reactivated-query-world"));
    } catch (_error) { _failure = _error; }
    global.pause = is_undefined(_saved_pause) ? 0 : _saved_pause;
    for (var _i = 0; _i < array_length(_owned); ++_i) {
        timing_activate_object(_owned[_i]);
        if (instance_exists(_owned[_i])) with (_owned[_i]) instance_destroy();
    }
    if (!is_undefined(_failure)) throw _failure;
    return {passed:true, comparisons:array_length(_checks), checks:_checks};
}

// Native Check-only microbenchmark. It uses the same room geometry for every
// fresh/cached grid, verifies identical cell values, and reports measured time.
// It is not a frame-time or Lunar Base performance claim.
function scr_troop_nav_benchmark(_requests = 40) {
    if (!TCC_SELF_CHECK) return undefined;
    if (instance_exists(o_anyblock) || instance_exists(o_ladder)
        || instance_exists(o_onewayupblock) || instance_exists(o_slope)) {
        throw "Navigation benchmark requires an empty diagnostic room";
    }
    var _saved = variable_global_exists("troop_navigation") ? global.troop_navigation : undefined;
    // Do not assume ordinary loading ran before o_logointro's Check entrypoint.
    var _scratch = {room_id:room, grid:-1, generation:0, built_generation:-1,
        width:0, height:0, builds:0, cache_hits:0, build_us:0, path_requests:0,
        path_us:0, search_iterations:0, max_search_iterations:0,
        budget_time:-1, budget_used:0, budget_deferrals:0,
        geometry_reference_us:0, geometry_instance_us:0, geometry_comparisons:0, geometry_mismatches:0};
    global.troop_navigation = _scratch;
    var _owned = [];
    var _baseline = -1, _fresh = -1;
    var _failure = undefined, _report = undefined;
    try {
        var _width = max(1, ceil(room_width / 32)), _height = max(1, ceil(room_height / 32));
        if (_width < 12 || _height < 12) throw "Navigation benchmark room too small";
        // Parent geometry avoids decorative/random Create effects. The masks
        // are the same normal 32-pixel collision masks sampled by navigation.
        for (var _x = 0; _x < _width; ++_x) {
            array_push(_owned, timing_create_depth(_x * 32, (_height - 2) * 32, 0, o_anyblock,
                {sprite_index:s_block, mask_index:s_block}));
        }
        for (var _x = 4; _x < _width - 2; _x += 4) {
            for (var _y = 5; _y < _height - 2; ++_y) {
                if ((_y mod 5) == 0) continue;
                array_push(_owned, timing_create_depth(_x * 32, _y * 32, 0, o_anyblock,
                    {sprite_index:s_block, mask_index:s_block}));
            }
        }
        for (var _y = _height - 7; _y < _height - 2; ++_y) {
            array_push(_owned, timing_create_depth(32, _y * 32, 0, o_ladder));
        }
        for (var _o = 0; _o < 4; ++_o) {
            array_push(_owned, timing_create_depth((6 + _o) * 32, 3 * 32, 0, o_whiteblockslope,
                {orientation:_o, image_index:_o}));
        }
        _baseline = scr_troop_build_grid_reference();
        var _start = get_timer(), _reference_us = 0;
        for (var _n = 0; _n < _requests; ++_n) {
            _start = get_timer();
            _fresh = scr_troop_build_grid_reference();
            _reference_us += get_timer() - _start;
            if (!scr_troop_nav_grids_equal(_baseline, _fresh)) throw "Reference geometry changed";
            ds_grid_destroy(_fresh);
            _fresh = -1;
        }
        var _fresh_us = 0;
        for (var _n = 0; _n < _requests; ++_n) {
            _start = get_timer();
            _fresh = scr_troop_build_grid();
            _fresh_us += get_timer() - _start;
            if (!scr_troop_nav_grids_equal(_baseline, _fresh)) throw "Instance geometry differs";
            ds_grid_destroy(_fresh);
            _fresh = -1;
        }
        _start = get_timer();
        var _cached = scr_troop_nav_grid();
        var _cold_us = get_timer() - _start;
        if (!scr_troop_nav_grids_equal(_baseline, _cached)) throw "Fresh/cache geometry differs";
        var _builds = _scratch.builds;
        _start = get_timer();
        for (var _n = 0; _n < _requests; ++_n) scr_troop_nav_grid();
        var _warm_us = get_timer() - _start;
        if (_scratch.builds != _builds || _scratch.cache_hits != _requests) throw "Unchanged geometry rebuilt";

        // A newly created block invalidates exactly once; deletion restores
        // the original grid. A native fresh rebuild cross-checks both states.
        if (_baseline[# 2, 2] == NAV_SOLID) throw "Navigation scratch cell occupied";
        var _added = timing_create_depth(64, 64, 0, o_anyblock, {sprite_index:s_block, mask_index:s_block});
        array_push(_owned, _added);
        _cached = scr_troop_nav_grid();
        _fresh = scr_troop_build_grid_reference();
        if (_scratch.builds != _builds + 1 || _cached[# 2, 2] != NAV_SOLID
            || !scr_troop_nav_grids_equal(_fresh, _cached)) throw "Create invalidation failed";
        ds_grid_destroy(_fresh); _fresh = -1;
        with (_added) instance_destroy();
        _cached = scr_troop_nav_grid();
        if (_scratch.builds != _builds + 2 || !scr_troop_nav_grids_equal(_baseline, _cached)) {
            throw "Destroy invalidation failed";
        }
        // Camera culling must not change either the cached cells or revision.
        // A real rebuild after culling must reactivate and include geometry.
        var _generation = _scratch.generation;
        instance_deactivate_object(_owned[0]);
        _cached = scr_troop_nav_grid();
        if (_scratch.generation != _generation || _scratch.builds != _builds + 2
            || !scr_troop_nav_grids_equal(_baseline, _cached)) throw "Culling invalidated geometry";
        scr_troop_nav_mark_dirty();
        _cached = scr_troop_nav_grid();
        if (_scratch.builds != _builds + 3 || !scr_troop_nav_grids_equal(_baseline, _cached)) {
            throw "Culled geometry missing from rebuild";
        }
        var _geometry_fixture = scr_troop_nav_geometry_fixture();
        _report = {passed:true, room:room_get_name(room), width:_width, height:_height,
            geometryInstances:array_length(_owned) - 1, requests:_requests,
            freshBuildTotalUs:_fresh_us, cachedColdBuildUs:_cold_us, cachedWarmTotalUs:_warm_us,
            freshMeanUs:_fresh_us / max(1, _requests), cachedWarmMeanUs:_warm_us / max(1, _requests),
            warmToFreshRatio:_warm_us / max(1, _fresh_us), builds:_scratch.builds,
            cacheHits:_scratch.cache_hits, invalidationChecks:3, cullingStable:true,
            referenceFreshTotalUs:_reference_us, referenceFreshMeanUs:_reference_us / max(1, _requests),
            instanceToReferenceRatio:_fresh_us / max(1, _reference_us), geometryFixture:_geometry_fixture};
    } catch (_error) {
        _failure = _error;
    }
    // Keep each owned DS grid/instance's lifetime explicit, even on failure.
    for (var _i = 0; _i < array_length(_owned); ++_i) {
        timing_activate_object(_owned[_i]);
        if (instance_exists(_owned[_i])) with (_owned[_i]) instance_destroy();
    }
    if (ds_exists(_fresh, ds_type_grid)) ds_grid_destroy(_fresh);
    if (ds_exists(_baseline, ds_type_grid)) ds_grid_destroy(_baseline);
    if (ds_exists(_scratch.grid, ds_type_grid)) ds_grid_destroy(_scratch.grid);
    _scratch.grid = -1; _scratch.built_generation = -1;
    global.troop_navigation = is_undefined(_saved) ? _scratch : _saved;
    if (!is_undefined(_failure)) throw _failure;
    show_debug_message("TCC_NAV_BENCHMARK " + json_stringify(_report));
    return _report;
}
