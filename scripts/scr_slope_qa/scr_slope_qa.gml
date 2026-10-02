// Diagnostic room authoring only. Once the player is created, the fixture does
// not move it, change its physics/colour, supply input, or complete the level.
function qa_slope_fixture(_spec) {
    if (!qa_active() || qa_value(_spec, "fixture", "") != "slope") return false;
    var _s = qa_value(_spec, "slope", undefined);
    var _colour = qa_value(_s, "colour", -1);
    var _orientation = qa_value(_s, "orientation", -1);
    var _scenario = qa_value(_s, "scenario", "");
    if (!is_real(_colour) || _colour < 0 || _colour > 4 || _colour != floor(_colour)
        || !is_real(_orientation) || _orientation < 0 || _orientation > 3
        || _orientation != floor(_orientation)
        || !array_contains(_orientation < 2 ? ["ascent", "descent", "jump", "mismatch"]
            : ["ceiling", "side", "empty", "mismatch"], _scenario)) {
        qa_finish("invalid", "Invalid slope fixture colour/orientation/scenario");
        return true;
    }

    var _slopes = [o_redblockslope, o_yellowblockslope, o_greenblockslope, o_blueblockslope, o_whiteblockslope];
    var _pickups = [o_reditem, o_yellowitem, o_greenitem, o_blueitem, o_whiteitem];
    var _pickup_colour = _scenario == "mismatch" ? (_colour == 0 ? 1 : 0) : _colour;
    var _motion = _scenario == "mismatch" ? (_orientation < 2 ? "ascent" : "ceiling") : _scenario;
    var _floor_y = 7000;
    var _slope_y = _orientation < 2 || _motion == "side" ? 6872 : 6840;
    var _start_x, _start_y, _door_x, _door_y;

    if (_orientation < 2) {
        // A 128 x 128 triangle joins the lower floor to the upper landing.
        // Orientation 0 is high on the left; orientation 1 is high on the right.
        var _high_left = _orientation == 0;
        var _high_x = _high_left ? 256 : 640;
        var _low_x = _high_left ? 640 : 224;
        timing_create_depth(_high_left ? 160 : 512, 6872, 0, o_whiteblock,
            {image_xscale:7, image_yscale:1});
        _start_x = _motion == "descent" ? _high_x : _low_x;
        _start_y = _motion == "descent" ? 6844 : 6972;
        _door_x = _motion == "descent" ? _low_x : _high_x;
        _door_y = _motion == "descent" ? 6936 : 6808;
    } else if (_motion == "side") {
        // Walk into the tall, flat edge, without jumping. The real door is
        // beyond that wall and must remain unreachable under these inputs.
        _start_x = _orientation == 2 ? 640 : 224;
        _start_y = 6972;
        _door_x = _orientation == 2 ? 224 : 640;
        _door_y = 6936;
    } else if (_motion == "empty") {
        // Enter the empty lower half of the triangle's bounding box. The door
        // is in the nook, before the filled far edge; an AABB collider fails.
        _floor_y = 6984;
        _start_x = _orientation == 2 ? 224 : 640;
        _start_y = 6956;
        _door_x = 432;
        _door_y = 6920;
    } else {
        // Jump from the floor into the diagonal overhead, land normally, then
        // leave towards its high end. No special jump strength is installed.
        _start_x = 432;
        _start_y = 6972;
        _door_x = _orientation == 2 ? 224 : 640;
        _door_y = 6936;
    }
    timing_create_depth(128, _floor_y, 0, o_whiteblock, {image_xscale:24, image_yscale:1});
    timing_create_depth(384, _slope_y, 0, _slopes[_colour],
        {orientation:_orientation, image_index:_orientation, image_xscale:4, image_yscale:4});
    timing_create_depth(_door_x, _door_y, 0, o_door);
    // Pickups use the player's ordinary Collision event. Even a matching red
    // start gets a pickup, making all five colour setups follow the same path.
    timing_create_depth(_start_x, _start_y, 0, _pickups[_pickup_colour]);
    global.tcc_qa.slope_fixture = {colour:_colour, orientation:_orientation,
        scenario:_scenario, pickup_colour:_pickup_colour, left:384, top:_slope_y,
        right:512, bottom:_slope_y + 128, floor_y:_floor_y};
    timing_create_depth(_start_x, _start_y, 1, qa_player_object());
    return true;
}

// Observations supplement the real player trace; they never apply collision
// resolution or mutate the player. Non-slope runs pay only the guard cost.
function qa_slope_body_overlap(_player) {
    if (!qa_active() || !instance_exists(o_slope)) return false;
    var _overlap = false;
    with (_player) { _overlap = scr_slope_place(x, y) != noone; }
    return _overlap;
}

function qa_slope_snapshot(_player) {
    if (!qa_active() || !variable_struct_exists(global.tcc_qa, "slope_fixture")) return undefined;
    var _fixture = global.tcc_qa.slope_fixture;
    var _sample = undefined;
    with (_player) {
        var _ground = scr_slope_place(x, y + 1);
        var _ceiling = scr_slope_place(x, y - 1);
        var _left = scr_slope_place(x - 1, y);
        var _right = scr_slope_place(x + 1, y);
        _sample = {floor:_ground != noone, ceiling:_ceiling != noone,
            left:_left != noone, right:_right != noone,
            overlap:scr_slope_place(x, y) != noone,
            insideBounds:bbox_left < _fixture.right && bbox_right > _fixture.left
                && bbox_top < _fixture.bottom && bbox_bottom > _fixture.top,
            floorColour:_ground != noone ? _ground.slope_colour : -1,
            ceilingColour:_ceiling != noone ? _ceiling.slope_colour : -1,
            scenario:_fixture.scenario, colour:_fixture.colour, orientation:_fixture.orientation};
    }
    return _sample;
}

// Extra native actor fixtures. Setup supplies room instances only. Every later
// position, velocity, collision and lifetime comes from the production events.
function qa_native_actor_sample(_actor, _meta) {
    var _sample = {frame:global.tcc_qa.frame, name:_meta.name, object:_meta.object,
        colour:_meta.colour, orientation:_meta.orientation, scenario:_meta.scenario,
        alive:instance_exists(_actor)};
    if (!_sample.alive) return _sample;
    with (_actor) {
        _sample.x = x; _sample.y = y;
        _sample.bbox = [bbox_left, bbox_top, bbox_right, bbox_bottom];
        _sample.overlap = scr_slope_place(x, y) != noone;
        _sample.floor = scr_slope_place(x, y + 1) != noone;
        if (variable_instance_exists(id, "vsp")) _sample.vsp = vsp;
        if (variable_instance_exists(id, "state")) _sample.state = state;
        if (variable_instance_exists(id, "reactiontime")) _sample.reactionTicks = reactiontime;
        if (variable_instance_exists(id, "move")) _sample.move = move;
    }
    return _sample;
}

function qa_native_actor_observe() {
    if (!qa_active() || !variable_struct_exists(global.tcc_qa, "native_actor_targets")) return;
    var _q = global.tcc_qa;
    for (var _i = 0; _i < array_length(_q.native_actor_targets); ++_i) {
        var _target = _q.native_actor_targets[_i];
        array_push(_q.native_actor_trace, qa_native_actor_sample(_target.actor, _target.meta));
    }
}

function qa_native_actor_register(_actor, _name, _colour, _orientation, _scenario) {
    var _q = global.tcc_qa;
    var _meta = {name:_name, object:object_get_name(_actor.object_index),
        colour:_colour, orientation:_orientation, scenario:_scenario};
    array_push(_q.native_actor_targets, {actor:_actor, meta:_meta});
    array_push(_q.native_actor_initial, qa_native_actor_sample(_actor, _meta));
}

function qa_native_actor_fixture(_spec) {
    var _kind = qa_value(_spec, "fixture", "");
    if (!qa_active() || (_kind != "projectile-slopes" && _kind != "troop-slope")) return false;
    var _q = global.tcc_qa;
    _q.native_actor_targets = []; _q.native_actor_initial = []; _q.native_actor_trace = [];
    var _slopes = [o_redblockslope, o_yellowblockslope, o_greenblockslope, o_blueblockslope, o_whiteblockslope];
    if (_kind == "troop-slope") {
        var _orientation = qa_value(_spec, "orientation", -1);
        if (!array_contains([0, 1], _orientation)) { qa_finish("invalid", "Invalid troop slope orientation"); return true; }
        timing_create_depth(0, 7000, 0, o_whiteblock, {image_xscale:32});
        timing_create_depth(_orientation == 0 ? 0 : 512, 6872, 0, o_whiteblock,
            {image_xscale:_orientation == 0 ? 12 : 16});
        timing_create_depth(384, 6872, 0, o_whiteblockslope,
            {orientation:_orientation, image_index:_orientation, image_xscale:4, image_yscale:4});
        var _player_x = _orientation == 0 ? 640 : 288;
        var _troop_x = _orientation == 0 ? 736 : 192;
        // The player stays ahead using ordinary movement; no AI state, speed,
        // detection, reaction time, or pathfinding setting is overridden.
        timing_create_depth(_player_x, 6972, 1, o_player);
        var _troop = timing_create_depth(_troop_x, 6972, 1, o_enemyplayer);
        qa_native_actor_register(_troop, "native-chase", 4, _orientation, "ascent");
        return true;
    }
    var _name = qa_value(_spec, "projectile", "");
    var _allowed = ["o_playerbullet", "o_playerbulletMU", "o_bulletleft", "o_bulletright",
        "o_rocket", "o_rocket2", "o_enemytroopprojectileboss5"];
    if (!array_contains(_allowed, _name)) { qa_finish("invalid", "Unsupported projectile fixture"); return true; }
    var _object = asset_get_index(_name);
    timing_create_depth(0, 7000, 0, o_whiteblock, {image_xscale:24});
    timing_create_depth(96, 6972, 1, o_player);
    for (var _colour = 0; _colour < 5; ++_colour) {
        for (var _orientation = 0; _orientation < 4; ++_orientation) {
            var _left = 1280 + _orientation * 640, _top = 1024 + _colour * 1152;
            timing_create_depth(_left, _top, 0, _slopes[_colour],
                {orientation:_orientation, image_index:_orientation, image_xscale:4, image_yscale:4});
            // Two actor masks in opposite, widely separated quadrants. A
            // rectangular fallback wrongly destroys the empty-half projectile.
            var _empty_x = (_orientation == 0 || _orientation == 3) ? 104 : 24;
            var _empty_y = _orientation < 2 ? 24 : 104;
            for (var _empty = 0; _empty <= 1; ++_empty) {
                var _px = _left + (_empty ? _empty_x : 128 - _empty_x);
                var _py = _top + (_empty ? _empty_y : 128 - _empty_y);
                var _actor = timing_create_depth(_px, _py, 1, _object, {hpproj:1});
                qa_native_actor_register(_actor, string(_colour) + "-" + string(_orientation) + "-" + string(_empty),
                    _colour, _orientation, _empty ? "empty" : "filled");
            }
        }
    }
    return true;
}
