// Foreground slopes use 32 px tiles and the original prototype's frame order:
// 0 lower-left, 1 lower-right, 2 upper-right, 3 upper-left. Collision is geometric,
// independent of the sprite's 34x33 artwork and its (0,1) origin.
function scr_slope_orientation(_value) {
    return ((floor(_value) mod 4) + 4) mod 4;
}

function scr_slope_colour(_object) {
    switch (_object) {
        case o_redblockslope: return 0;
        case o_yellowblockslope: return 1;
        case o_greenblockslope: return 2;
        case o_blueblockslope: return 3;
        default: return 4;
    }
}

function scr_slope_rect_hit(_slope, _left, _top, _right, _bottom) {
    var _sx = _slope.image_xscale;
    var _sy = _slope.image_yscale;
    if (_sx == 0 || _sy == 0) return false;
    var _x1 = (_left - _slope.x) / _sx;
    var _x2 = (_right - _slope.x) / _sx;
    var _y1 = (_top - _slope.y) / _sy;
    var _y2 = (_bottom - _slope.y) / _sy;
    var _l = min(_x1, _x2), _r = max(_x1, _x2);
    var _t = min(_y1, _y2), _b = max(_y1, _y2);
    // Bounds are geometric pixel areas, [0,32), not the unscaled sprite's
    // inclusive pixel indices 0..31. This also preserves the last scaled pixel.
    if (_r < 0 || _l >= 32 || _b < 0 || _t >= 32) return false;
    _l = max(_l, 0); _r = min(_r, 32);
    _t = max(_t, 0); _b = min(_b, 32);
    switch (scr_slope_orientation(_slope.orientation)) {
        case 0: return _b >= _l;
        case 1: return _b >= 32 - _r;
        case 2: return _t <= _r;
        case 3: return _t <= 32 - _l;
    }
    return false;
}

// The query list is temporary: no actor or room retains a DS allocation.
function scr_slope_rect(_left, _top, _right, _bottom, _colour = -1) {
    if (!instance_exists(o_slope)) return noone;
    var _list = ds_list_create();
    var _count = collision_rectangle_list(_left - 2, _top - 2, _right + 2, _bottom + 2,
        o_slope, false, true, _list, false);
    var _found = noone;
    for (var _i = 0; _i < _count; ++_i) {
        var _s = _list[| _i];
        if ((_colour < 0 || _s.slope_colour == _colour)
            && scr_slope_rect_hit(_s, _left, _top, _right, _bottom)) {
            _found = _s;
            break;
        }
    }
    ds_list_destroy(_list);
    return _found;
}

// Called in the moving actor's context; preserves custom/player mask offsets.
function scr_slope_place(_px, _py, _colour = -1, _clearance = 0) {
    // GameMaker bbox_right/bottom already include the outer pixel boundary.
    // Sample the covered pixel centres, matching native instance collisions.
    return scr_slope_rect(bbox_left + 0.5 + _px - x - _clearance,
        bbox_top + 0.5 + _py - y - _clearance,
        bbox_right - 0.5 + _px - x + _clearance,
        bbox_bottom - 0.5 + _py - y + _clearance, _colour);
}

// Native instance coordinates round to single precision when movement is
// applied. Reserve one float ULP during movement probes so a position accepted
// in GML's double precision cannot round into the triangle. Contact queries and
// verification remain exact; this does not forgive an existing overlap.
function scr_slope_motion_clearance(_left, _top, _right, _bottom) {
    return max(1, abs(_left), abs(_top), abs(_right), abs(_bottom))
        * 0.00000011920928955078125;
}

function scr_slope_near_actor(_dx, _dy, _padding = 2) {
    if (!instance_exists(o_slope)) return false;
    return collision_rectangle(bbox_left + min(0, _dx) - _padding,
        bbox_top + min(0, _dy) - _padding,
        bbox_right + max(0, _dx) + _padding,
        bbox_bottom + max(0, _dy) + _padding, o_slope, false, true) != noone;
}

function scr_slope_rectangular_solid(_px, _py, _dx) {
    if (place_meeting(_px, _py, o_anyblock)
        || place_meeting(_px, _py, o_movingplatforms)
        || place_meeting(_px, _py, o_shooter)
        || place_meeting(_px, _py, o_shooterright)
        || place_meeting(_px, _py, o_rocketlauncher)
        || place_meeting(_px, _py, o_rocketlauncherright)) return true;
    if (_dx < 0 && place_meeting(_px, _py, o_onewayrightblock)) return true;
    if (_dx > 0 && place_meeting(_px, _py, o_onewayleftblock)) return true;
    if (object_index == o_player || object_index == o_playerMU) {
        if (place_meeting(_px, _py, o_playerMU)) return true;
    }
    return false;
}

function scr_slope_solid(_px, _py, _dx, _clearance = 0) {
    return scr_slope_rectangular_solid(_px, _py, _dx)
        || scr_slope_place(_px, _py, -1, _clearance) != noone;
}

// Resolve the horizontal component without applying it. Each substep can climb
// at most one pixel of diagonal (plus mask rounding tolerance), never a wall.
// Descending stays attached only when the actor was standing on a slope.
function scr_slope_resolve_horizontal(_dx, _allow_step) {
    var _px = x, _py = y;
    var _clearance = scr_slope_motion_clearance(bbox_left - abs(_dx), bbox_top,
        bbox_right + abs(_dx), bbox_bottom);
    var _remaining = abs(_dx);
    var _sign = sign(_dx);
    var _blocked = false;
    while (_remaining > 0.0001) {
        var _step = min(1, _remaining) * _sign;
        var _nx = _px + _step;
        var _on_slope = scr_slope_place(_px, _py + 1) != noone;
        var _grounded = _on_slope || scr_slope_rectangular_solid(_px, _py + 1, 0)
            || place_meeting(_px, _py + 1, o_onewayupblock);
        if (scr_slope_solid(_nx, _py, _step, _clearance)) {
            var _climbed = false;
            // Stepping is permitted only against a lower-half slope; the
            // upper-half's flat wall/ceiling must block rather than eject.
            var _hit = scr_slope_place(_nx, _py, -1, _clearance);
            if (_allow_step && _grounded && _hit != noone) {
                var _orientation = scr_slope_orientation(_hit.orientation);
                var _lower = (_orientation < 2) == (_hit.image_yscale > 0);
                if (_lower) {
                    var _rise = max(1, abs(_step * _hit.image_yscale / _hit.image_xscale));
                    for (var _up = 1; _up <= ceil(_rise) + 1; ++_up) {
                        if (!scr_slope_solid(_nx, _py - _up, _step, _clearance)) {
                            _py -= _up;
                            _climbed = true;
                            break;
                        }
                    }
                }
            }
            if (!_climbed) { _blocked = true; break; }
        } else if (_allow_step && _on_slope) {
            // A 45-degree slope drops by at most one pixel per horizontal
            // pixel. Do not snap airborne actors or bridge a missing tile.
            var _support = scr_slope_place(_px, _py + 1);
            var _drop = min(32, ceil(abs(_step * _support.image_yscale / _support.image_xscale)) + 1);
            for (var _down = 1; _down <= _drop; ++_down) {
                if (scr_slope_solid(_nx, _py + _down, 0, _clearance)) {
                    _py += _down - 1;
                    break;
                }
            }
        }
        _px = _nx;
        _remaining -= abs(_step);
    }
    return { dx: _px - x, dy: _py - y, blocked: _blocked };
}

function scr_slope_resolve_vertical(_dy) {
    if (!scr_slope_near_actor(0, _dy, 1)) return { dy: _dy, blocked: false };
    var _clearance = scr_slope_motion_clearance(bbox_left, bbox_top - abs(_dy),
        bbox_right, bbox_bottom + abs(_dy));
    var _resolved = 0;
    var _remaining = abs(_dy);
    var _sign = sign(_dy);
    while (_remaining > 0.0001) {
        var _step = min(1, _remaining) * _sign;
        if (scr_slope_place(x, y + _resolved + _step, -1, _clearance) != noone) {
            return { dy: _resolved, blocked: true };
        }
        _resolved += _step;
        _remaining -= abs(_step);
    }
    return { dy: _resolved, blocked: false };
}

function scr_slope_harmful_contact(_colour) {
    if (_colour == 4 || !scr_slope_near_actor(0, 0, 2)) return false;
    // Match square-block seam forgiveness for top/bottom contacts, while a
    // stopped actor touching the incompatible side still takes damage.
    var _safe_vertical = false;
    var _colours = [o_redblock, o_yellowblock, o_greenblock, o_blueblock];
    for (var _c = 0; _c < 4; ++_c) {
        if (place_meeting(x, y - 1, _colours[_c]) || place_meeting(x, y + 1, _colours[_c])) {
            _safe_vertical = true;
        }
    }
    if (scr_slope_place(x, y - 1, _colour) != noone || scr_slope_place(x, y + 1, _colour) != noone) {
        _safe_vertical = true;
    }
    for (var _c = 0; _c < 4; ++_c) {
        if (_c == _colour) continue;
        if (scr_slope_place(x, y, _c) != noone) return true;
        if (!_safe_vertical && (scr_slope_place(x, y - 1, _c) != noone
            || scr_slope_place(x, y + 1, _c) != noone)) return true;
        if (hsp == 0 && (scr_slope_place(x - 1, y, _c) != noone
            || scr_slope_place(x + 1, y, _c) != noone)) return true;
    }
    return false;
}

// Thin tips must not be skipped by fast bullets between simulation steps.
function scr_slope_projectile_sweep(_from_x, _from_y, _to_x, _to_y) {
    if (!instance_exists(o_slope)) return false;
    var _distance = max(abs(_to_x - _from_x), abs(_to_y - _from_y));
    var _steps = max(1, ceil(_distance));
    for (var _i = 0; _i <= _steps; ++_i) {
        if (scr_slope_place(lerp(_from_x, _to_x, _i / _steps),
            lerp(_from_y, _to_y, _i / _steps)) != noone) return true;
    }
    return false;
}

// Reuse the actual block material, then give the cut edge the same small
// inset bevel. Artwork is clipped to the triangle and never defines collision.
function scr_slope_draw_band(_points, _orientation, _x, _y, _sx, _sy, _colour, _alpha) {
    var _order = [0, 1, 2, 0, 2, 3];
    draw_primitive_begin(pr_trianglelist);
    for (var _i = 0; _i < 6; ++_i) {
        var _p = _points[_order[_i]];
        var _px = _p[0], _py = _p[1];
        if (_orientation == 1 || _orientation == 2) _px = 32 - _px;
        if (_orientation == 2 || _orientation == 3) _py = 32 - _py;
        draw_vertex_colour(_x + _px * _sx, _y + _py * _sy, _colour, _alpha);
    }
    draw_primitive_end();
}
function scr_slope_draw(_colour, _orientation, _x, _y, _sx, _sy, _alpha, _style = -1) {
    if (_style < 0) _style = (room == r_leveleditor || room == r_customlevelworkshop)
        && variable_global_exists("LEBlockStyle") ? global.LEBlockStyle : 0;
    var _sprites = _style == 1
        ? [s_redblockbricks, s_yellowblockbricks, s_greenblockbricks, s_blueblockbricks, s_whiteblockbricks]
        : [s_redblock, s_yellowblock, s_greenblock, s_blueblock, s_whiteblock];
    var _sprite = _sprites[clamp(_colour, 0, 4)];
    var _corners = [[0, 0], [1, 0], [1, 1], [0, 1]];
    var _indices = [[0, 2, 3], [1, 2, 3], [0, 1, 2], [0, 1, 3]];
    var _o = scr_slope_orientation(_orientation);
    var _triangle = _indices[_o];
    // Immediate primitives use sprite-local UVs (0..1), unlike vertex buffers.
    draw_primitive_begin_texture(pr_trianglelist, sprite_get_texture(_sprite, 0));
    for (var _i = 0; _i < 3; ++_i) {
        var _p = _corners[_triangle[_i]];
        draw_vertex_texture_colour(_x + _p[0] * 32 * _sx, _y + _p[1] * 32 * _sy,
            _p[0], _p[1], c_white, _alpha);
    }
    draw_primitive_end();
    // Three narrow bands retain the cloudy/brick texture beneath them. Unlike
    // the prototype's black line, the bevel stays entirely inside the tile.
    var _lit = (_o < 2) == (_sy >= 0);
    scr_slope_draw_band([[0,0],[32,32],[29,32],[0,3]], _o, _x,_y,_sx,_sy, c_black, _alpha * 0.14);
    scr_slope_draw_band([[0,1],[31,32],[30,32],[0,2]], _o, _x,_y,_sx,_sy,
        _lit ? c_white : c_black, _alpha * (_lit ? 0.18 : 0.12));
    scr_slope_draw_band([[0,0],[32,32],[31,32],[0,1]], _o, _x,_y,_sx,_sy, c_black, _alpha * 0.32);
}

// Geometry assertions run inside GameMaker's native self-check harness. They
// exercise the actual GML used by players and projectiles, not a second model.
function scr_slope_geometry_selfcheck() {
    var _s = {x: 0, y: 0, image_xscale: 1, image_yscale: 1, orientation: 0};
    var _filled = [[4, 27], [27, 27], [27, 4], [4, 4]];
    var _empty = [[27, 4], [4, 4], [4, 27], [27, 27]];
    for (var _o = 0; _o < 4; ++_o) {
        _s.orientation = _o;
        var _a = _filled[_o], _b = _empty[_o];
        if (!scr_slope_rect_hit(_s, _a[0], _a[1], _a[0], _a[1])) throw "Slope filled quadrant " + string(_o);
        if (scr_slope_rect_hit(_s, _b[0], _b[1], _b[0], _b[1])) throw "Slope empty quadrant " + string(_o);
        if (scr_slope_rect_hit(_s, 32, 0, 40, 31)) throw "Slope escaped tile " + string(_o);
        if (!scr_slope_rect_hit(_s, 14.5, 3.5, 31.5, 27.5)) throw "Slope missed player box " + string(_o);
        _s.image_xscale = -2; _s.image_yscale = 2;
        if (!scr_slope_rect_hit(_s, -2 * _a[0], 2 * _a[1], -2 * _a[0], 2 * _a[1])) throw "Slope mirror/scale " + string(_o);
        _s.image_xscale = 1; _s.image_yscale = 1;
    }
    _s.orientation = 1;
    if (!scr_slope_rect_hit(_s, 31.75, 16, 31.75, 16)) throw "Slope lost final pixel area";
    _s.image_xscale = 2; _s.image_yscale = 2;
    if (!scr_slope_rect_hit(_s, 63.5, 32, 63.5, 32)) throw "Slope lost scaled edge";
    if (scr_slope_rect_hit(_s, 64, 32, 64, 32)) throw "Slope scaled outer boundary";
    _s.image_xscale = 0.5; _s.image_yscale = 0.5;
    if (!scr_slope_rect_hit(_s, 15.75, 8, 15.75, 8)) throw "Slope lost reduced edge";
    if (scr_slope_rect_hit(_s, 16, 8, 16, 8)) throw "Slope reduced outer boundary";
    // Native 150 FPS descent regression: y + 0.2 is clear in double precision,
    // then the instance stores y=6845.6005859375 and penetrates by 0.000122 px.
    // A movement probe must reject that candidate without weakening overlap.
    _s.x = 384; _s.y = 6872; _s.image_xscale = 4; _s.image_yscale = 4;
    _s.orientation = 0;
    var _l = 385.1004638671875, _r = 402.1004638671875;
    var _t = 6849.100390625, _b = 6873.100390625;
    if (scr_slope_rect_hit(_s, _l, _t, _r, _b)) throw "Slope fractional candidate baseline";
    if (!scr_slope_rect_hit(_s, _l, 6849.1005859375, _r, 6873.1005859375)) {
        throw "Slope overlap assertion lost precision";
    }
    var _clearance = scr_slope_motion_clearance(_l, _t, _r, _b);
    if (!scr_slope_rect_hit(_s, _l - _clearance, _t - _clearance,
        _r + _clearance, _b + _clearance)) throw "Slope float-storage clearance";
    if (scr_slope_rect_hit(_s, _l - _clearance, _t - 0.01 - _clearance,
        _r + _clearance, _b - 0.01 + _clearance)) throw "Slope clearance exceeded rounding";
    return true;
}
