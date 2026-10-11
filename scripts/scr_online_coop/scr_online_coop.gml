// =============================================================================
// CO-OP LEVEL EDITOR - build a level together with invited friends.
//
// The creator's game owns the level. Only friends the creator invites from the
// editor can enter; everyone else in the lobby keeps waiting in their menu.
// Guests build and play-test their own copy, which exists only in memory: they
// cannot save, load, rename or publish it (level_editor_directory() is empty
// for them and the creator's file buttons are never created).
//
// Editor input is never replayed on another machine. Each player diffs the
// saveable level objects (the entries level_capture writes) and sends the
// result: every object carries a uid, and an edit is a list of destroyed uids
// plus spawned entries. Guests apply their own edits at once and send them to
// the creator, who checks and applies them, then relays them to every guest in
// one numbered stream together with the creator's own edits. A joining guest
// receives the level as a private in-memory snapshot tagged with that stream
// position. Builders on a play-test receive changes that would land on their
// player at their next respawn.
// =============================================================================

#macro NET_PACKET_COOP_INVITE	25	// creator -> friend: build with me
#macro NET_PACKET_COOP_JOIN		26	// guest -> creator: accepted, send me the level
#macro NET_PACKET_COOP_WELCOME	27	// creator -> guest: slot, stream position, snapshot
#macro NET_PACKET_COOP_DENY		28	// creator -> guest: refused
#macro NET_PACKET_COOP_OPS		29	// creator -> guests: numbered level changes
#macro NET_PACKET_COOP_EDIT		30	// guest -> creator: the guest's own changes
#macro NET_PACKET_COOP_CURSOR	31	// builder -> builders: pointer (unreliable)
#macro NET_PACKET_COOP_END		32	// creator -> guest: the session is over for you
#macro NET_PACKET_COOP_LEAVE	33	// guest -> creator: left the editor
#macro NET_PACKET_COOP_RESYNC	34	// guest -> creator: send the level again

#macro NET_COOP_VERSION			1
#macro NET_COOP_UID_SPACE		4294967296	// uid = slot * space + counter
#macro NET_COOP_ENTRY_BYTES		46			// uid, object, x, y, frame, xscale, yscale, orientation
#macro NET_COOP_INVITE_MS		120000
#macro NET_COOP_JOIN_MS			45000
#macro NET_COOP_HOST_LOST_MS	8000
#macro NET_COOP_BUDGET			3000		// objects a guest may change in a burst
#macro NET_COOP_BUDGET_REFILL	600			// per second
#macro NET_COOP_META_MAX		6000		// bytes of settings text per packet

#macro NET_COOP_DENY_NOT_INVITED	1
#macro NET_COOP_DENY_NOT_BUILDING	2
#macro NET_COOP_DENY_VERSION		3
#macro NET_COOP_DENY_FULL			4
#macro NET_COOP_END_CLOSED			1
#macro NET_COOP_END_REMOVED			2

function net_coop_init() {
    global.net_coop_role = "";			// "", "host" (the creator) or "guest"
    global.net_coop_cid = "";
    global.net_coop_host = int64(0);	// guest: the creator's Steam ID
    global.net_coop_slot = 0;			// uid space: creator 0, guests 1..NET_MAX_LOBBY
    global.net_coop_counter = 0;
    global.net_coop_state = "";			// guest: "loading", "entering", "hold" or "active"
    global.net_coop_seq = 0;			// creator: last batch sent; guest: last batch applied
    global.net_coop_edit_seq = 0;		// guest: last edit packet sent
    global.net_coop_snapshot_md5 = "";
    global.net_coop_snapshot_seq = 0;
    global.net_coop_snapshot_tries = 0;
    global.net_coop_objects = ds_map_create();	// uid -> {inst, w, x, y, o, stamp}
    global.net_coop_invited = ds_map_create();	// creator: Steam ID -> {id, name, at}
    global.net_coop_guests = ds_map_create();	// creator: Steam ID -> guest record
    global.net_coop_cursors = ds_map_create();	// Steam ID -> pointer of another builder
    global.net_coop_stamp = 0;
    global.net_coop_queue = [];			// remote batches waiting to be applied
    global.net_coop_early = [];			// guest: creator batches that arrived before the level
    global.net_coop_meta = "";			// settings as last sent or received
    global.net_coop_offer = undefined;	// invitation shown to this player
    global.net_coop_accept = undefined;	// accepted invitation on its way to the creator
    global.net_coop_pending = undefined;// guest: level waiting for the editor room
    global.net_coop_entered = false;	// guest: has been in the creator's level
    global.net_coop_next_slot = 1;		// creator: slots are never reused, so uids never collide
    global.net_coop_ready = false;		// creator: the editor holds a level
    global.net_coop_edits = 0;			// creator: remote edits applied (play-test verification)
    global.net_coop_dirty = 0;
    global.net_coop_scan_tick = 0;
    global.net_coop_cursor_tick = 0;
    global.net_coop_host_seen = 0;
    global.net_coop_notice = "";
}

function net_coop_cleanup() {
    if (ds_exists(global.net_coop_objects, ds_type_map)) ds_map_destroy(global.net_coop_objects);
    if (ds_exists(global.net_coop_invited, ds_type_map)) ds_map_destroy(global.net_coop_invited);
    if (ds_exists(global.net_coop_guests, ds_type_map)) ds_map_destroy(global.net_coop_guests);
    if (ds_exists(global.net_coop_cursors, ds_type_map)) ds_map_destroy(global.net_coop_cursors);
}

/// Our lobby changed. A session lives in one lobby, but an accepted invitation is
/// exactly such a change, so it survives.
function net_coop_lobby_reset() {
    if (!variable_global_exists("net_coop_role")) return;
    if (global.net_coop_role == "host") net_coop_reset();
    else if (global.net_coop_role == "guest") net_coop_guest_exit(loc("NET_COOP_LOST"));
}

function net_coop_is_guest() {
    return variable_global_exists("net_coop_role") && global.net_coop_role == "guest";
}
function net_coop_is_host() {
    return variable_global_exists("net_coop_role") && global.net_coop_role == "host";
}
/// Following the lobby owner pauses while this player builds with someone.
function net_coop_busy() {
    return variable_global_exists("net_coop_role") && (global.net_coop_role != "" || is_struct(global.net_coop_accept));
}
/// Level key shared by everyone in the session, in build and play mode alike.
function net_coop_level_key() {
    if (!variable_global_exists("net_coop_role") || global.net_coop_role == "" || room != r_leveleditor) return "";
    if (global.net_coop_role == "host" && !global.net_coop_ready) return "";
    return "co:" + global.net_coop_cid;
}
/// Play-test verification: a run only verifies the level if nobody changed it meanwhile.
function net_coop_edit_count() {
    return variable_global_exists("net_coop_edits") ? global.net_coop_edits : 0;
}

function net_coop_reset() {
    global.net_coop_role = "";
    global.net_coop_cid = "";
    global.net_coop_host = int64(0);
    global.net_coop_slot = 0;
    global.net_coop_counter = 0;
    global.net_coop_state = "";
    global.net_coop_seq = 0;
    global.net_coop_edit_seq = 0;
    global.net_coop_snapshot_md5 = "";
    global.net_coop_snapshot_seq = 0;
    global.net_coop_snapshot_tries = 0;
    ds_map_clear(global.net_coop_objects);
    ds_map_clear(global.net_coop_invited);
    ds_map_clear(global.net_coop_guests);
    ds_map_clear(global.net_coop_cursors);
    global.net_coop_queue = [];
    global.net_coop_early = [];
    global.net_coop_meta = "";
    global.net_coop_pending = undefined;
    global.net_coop_entered = false;
    global.net_coop_next_slot = 1;
    global.net_coop_ready = false;
}

// -----------------------------------------------------------------------------
// Saveable editor objects and their wire format
// -----------------------------------------------------------------------------
/// The registry in a fixed order shared by every copy of this game version.
function net_coop_registry() {
    static _data = undefined;
    if (!is_undefined(_data)) return _data;
    var _names = variable_struct_get_names(level_registry());
    array_sort(_names, true);
    var _of = [];		// object index -> wire index + 1
    var _joined = "";
    for (var _i = 0; _i < array_length(_names); ++_i) {
        _of[real(level_object(_names[_i]))] = _i + 1;
        _joined += _names[_i] + ",";
    }
    // A spike's Create can turn it into one of these; it is saved as a plain spike.
    var _spike = _of[real(o_spike)];
    _of[real(o_goldenspike)] = _spike;
    _of[real(o_weirdspike)] = _spike;
    // In the editor a locked door turns into a door on every machine by itself.
    _of[real(o_lockeddoor)] = _of[real(o_door)];
    _data = {names:_names, of:_of, hash:md5_string_utf8(_joined)};
    return _data;
}

/// Wire index + 1 of an instance's object, or 0 when it is not level content.
function net_coop_wire(_inst) {
    var _of = net_coop_registry().of;
    var _index = real(_inst.object_index);
    return _index < array_length(_of) ? _of[_index] : 0;
}

/// Slope orientation as level_capture saves it; 0 for everything else.
function net_coop_orientation(_inst, _name) {
    if (!level_is_slope(_name)) return 0;
    if (variable_instance_exists(_inst, "orientation")) return _inst.orientation;
    return ((floor(_inst.image_index) mod 4) + 4) mod 4;
}

function net_coop_new_uid() {
    global.net_coop_counter += 1;
    return global.net_coop_slot * NET_COOP_UID_SPACE + global.net_coop_counter;
}

function net_coop_entry_of(_inst, _w, _uid) {
    var _name = net_coop_registry().names[_w - 1];
    return {uid:_uid, w:_w, x:_inst.x, y:_inst.y, ii:_inst.image_index,
        xs:_inst.image_xscale, ys:_inst.image_yscale, o:net_coop_orientation(_inst, _name)};
}

function net_coop_entry_valid(_s) {
    var _count = array_length(net_coop_registry().names);
    if (!net_finite(_s.uid) || _s.uid < 1 || _s.uid != floor(_s.uid)) return false;
    if (_s.w < 1 || _s.w > _count) return false;
    if (!net_finite(_s.x) || !net_finite(_s.y) || abs(_s.x) > 1048576 || abs(_s.y) > 1048576) return false;
    if (!net_finite(_s.ii) || abs(_s.ii) > 1000000) return false;
    if (!net_finite(_s.xs) || !net_finite(_s.ys) || _s.xs == 0 || _s.ys == 0
        || abs(_s.xs) < 0.00001 || abs(_s.ys) < 0.00001 || abs(_s.xs) > 1024 || abs(_s.ys) > 1024) return false;
    return _s.o >= 0 && _s.o <= 3;
}

function net_coop_write_entry(_buffer, _s) {
    buffer_write(_buffer, buffer_f64, _s.uid);
    buffer_write(_buffer, buffer_u8, _s.w);
    buffer_write(_buffer, buffer_f64, _s.x);
    buffer_write(_buffer, buffer_f64, _s.y);
    buffer_write(_buffer, buffer_f32, _s.ii);
    buffer_write(_buffer, buffer_f64, _s.xs);
    buffer_write(_buffer, buffer_f64, _s.ys);
    buffer_write(_buffer, buffer_u8, _s.o);
}

function net_coop_read_entry(_buffer) {
    return {uid:buffer_read(_buffer, buffer_f64), w:buffer_read(_buffer, buffer_u8),
        x:buffer_read(_buffer, buffer_f64), y:buffer_read(_buffer, buffer_f64), ii:buffer_read(_buffer, buffer_f32),
        xs:buffer_read(_buffer, buffer_f64), ys:buffer_read(_buffer, buffer_f64), o:buffer_read(_buffer, buffer_u8)};
}

// -----------------------------------------------------------------------------
// Finding this player's own edits
// -----------------------------------------------------------------------------
/// Give every level object a uid without sending anything (a new or reloaded level).
/// _keep keeps the uids a snapshot carried.
function net_coop_baseline(_keep) {
    ds_map_clear(global.net_coop_objects);
    var _stamp = ++global.net_coop_stamp;
    timing_activate_object(o_leveleditorloadplacement);
    var _objects = global.net_coop_objects;
    var _names = net_coop_registry().names;
    with (o_leveleditorloadplacement) {
        var _w = net_coop_wire(id);
        if (_w == 0) continue;
        if (!_keep || !variable_instance_exists(id, "net_uid") || ds_map_exists(_objects, net_uid)) net_uid = net_coop_new_uid();
        _objects[? net_uid] = {inst:id, w:_w, x:x, y:y, o:net_coop_orientation(id, _names[_w - 1]), stamp:_stamp};
    }
}

/// Diff the level against the last scan. Returns {destroys, spawns}.
function net_coop_scan() {
    var _objects = global.net_coop_objects;
    var _names = net_coop_registry().names;
    var _stamp = ++global.net_coop_stamp;
    var _destroys = [];
    var _spawns = [];
    var _seen = 0;
    with (o_leveleditorloadplacement) {
        var _w = net_coop_wire(id);
        if (_w == 0) continue;
        _seen += 1;
        var _o = net_coop_orientation(id, _names[_w - 1]);
        var _uid = variable_instance_exists(id, "net_uid") ? net_uid : undefined;
        var _rec = is_undefined(_uid) ? undefined : _objects[? _uid];
        var _mine = is_struct(_rec) && _rec.inst == id;
        if (_mine && _rec.w == _w && _rec.x == x && _rec.y == y && _rec.o == _o) {
            _rec.stamp = _stamp;
            continue;
        }
        // Recoloured, converted or rotated in place: it becomes a new object.
        if (_mine) {
            array_push(_destroys, _uid);
            ds_map_delete(_objects, _uid);
        }
        net_uid = net_coop_new_uid();
        _objects[? net_uid] = {inst:id, w:_w, x:x, y:y, o:_o, stamp:_stamp};
        array_push(_spawns, net_coop_entry_of(id, _w, net_uid));
    }
    if (_seen < ds_map_size(_objects)) {
        // Big levels cull blocks outside the view; only this player's own actions,
        // which happen on screen, remove objects between scans.
        var _culling = instance_exists(o_smoothcamera) && variable_global_exists("biglevelperfsettings") && global.biglevelperfsettings >= 1;
        var _cx = camera_get_view_x(view_camera[0]);
        var _cy = camera_get_view_y(view_camera[0]);
        var _cw = camera_get_view_width(view_camera[0]);
        var _ch = camera_get_view_height(view_camera[0]);
        var _key = ds_map_find_first(_objects);
        while (!is_undefined(_key)) {
            var _next = ds_map_find_next(_objects, _key);
            var _rec = _objects[? _key];
            if (_rec.stamp != _stamp && !instance_exists(_rec.inst)
                && (!_culling || point_in_rectangle(_rec.x, _rec.y, _cx - 64, _cy - 64, _cx + _cw + 64, _cy + _ch + 64))) {
                array_push(_destroys, _key);
                ds_map_delete(_objects, _key);
            }
            _key = _next;
        }
    }
    return {destroys:_destroys, spawns:_spawns};
}

/// Scan when this player may have edited and send what changed.
function net_coop_scan_send(_force) {
    if (room != r_leveleditor || global.LEMode != 1) return;
    if (global.net_coop_role == "guest" && global.net_coop_state != "active") return;
    if (!_force) {
        if (mouse_check_button(mb_any) || keyboard_check(vk_anykey) || instance_exists(o_deleteblock)
            || instance_exists(o_waterleveleditorline)) global.net_coop_dirty = 12;
        var _tick = timing_tick_id();
        var _due = (global.net_coop_dirty > 0 && _tick - global.net_coop_scan_tick >= 2) || _tick - global.net_coop_scan_tick >= 60;
        if (global.net_coop_dirty > 0) global.net_coop_dirty -= 1;
        if (!_due) return;
    }
    global.net_coop_scan_tick = timing_tick_id();
    var _diff = net_coop_scan();
    if (array_length(_diff.destroys) == 0 && array_length(_diff.spawns) == 0) return;
    if (global.net_coop_role == "host") net_coop_send_ops(_diff.destroys, _diff.spawns, undefined, 0);
    else net_coop_send_edit(_diff.destroys, _diff.spawns, undefined);
}

// -----------------------------------------------------------------------------
// Applying other builders' edits
// -----------------------------------------------------------------------------
function net_coop_spawn(_s) {
    if (ds_map_exists(global.net_coop_objects, _s.uid)) return noone;	// already here (our own edit)
    var _name = net_coop_registry().names[_s.w - 1];
    var _entry = {obj:_name, x:_s.x, y:_s.y, imageindex:_s.ii, xscale:_s.xs, yscale:_s.ys, orientation:_s.o};
    var _inst = level_spawn_entry(_entry, level_document_layer(), "editor", undefined, _s.uid);
    if (!instance_exists(_inst)) return noone;
    var _w = net_coop_wire(_inst);
    if (_w == 0) {
        instance_destroy(_inst);
        return noone;
    }
    global.net_coop_objects[? _s.uid] = {inst:_inst, w:_w, x:_inst.x, y:_inst.y,
        o:net_coop_orientation(_inst, net_coop_registry().names[_w - 1]), stamp:global.net_coop_stamp};
    // Placing a one-way block also places its placement blocker.
    if (string_pos("o_oneway", _name) == 1) instance_create(_inst.x, _inst.y, o_blockcheck2);
    return _inst;
}

function net_coop_destroy(_uid) {
    var _rec = global.net_coop_objects[? _uid];
    if (!is_struct(_rec)) return false;
    ds_map_delete(global.net_coop_objects, _uid);
    // Culled off-screen objects must be woken before they can be destroyed.
    timing_activate_object(_rec.inst);
    if (!instance_exists(_rec.inst)) return false;
    var _inst = _rec.inst;
    var _obj = _inst.object_index;
    var _name = object_get_name(_obj);
    var _x = _inst.x;
    var _y = _inst.y;
    // During a play-test, markers have already spawned the real object.
    if (room == r_leveleditor && global.LEMode == 2 && string_copy(_name, string_length(_name) - 1, 2) == "LE") {
        var _runtime = asset_get_index(string_copy(_name, 1, string_length(_name) - 2));
        if (_runtime != -1 && asset_get_type(_runtime) == asset_object) {
            if (string_pos("mov", _name) > 0 || _obj == o_enemyplayerLE) {
                // Movers leave their marker: reset that kind, the other markers respawn theirs.
                with (_runtime) instance_destroy();
                with (_obj) {
                    if (id == _inst) continue;
                    if (variable_instance_exists(id, "spawn")) spawn = 1;
                    if (variable_instance_exists(id, "canspawn")) canspawn = 1;
                }
            } else {
                with (_runtime) if (x == _x && y == _y) instance_destroy();
            }
        }
    }
    if (string_pos("o_oneway", _name) == 1) with (o_blockcheck2) if (x == _x && y == _y) instance_destroy();
    instance_destroy(_inst);
    return true;
}

/// Bounding box an entry will occupy, for the play-test safety check.
function net_coop_entry_box(_s) {
    var _obj = level_object(net_coop_registry().names[_s.w - 1]);
    var _sprite = object_get_mask(_obj);
    if (_sprite < 0) _sprite = object_get_sprite(_obj);
    var _w = 32, _h = 32, _ox = 0, _oy = 0;
    if (_sprite >= 0 && sprite_exists(_sprite)) {
        _w = sprite_get_width(_sprite); _h = sprite_get_height(_sprite);
        _ox = sprite_get_xoffset(_sprite); _oy = sprite_get_yoffset(_sprite);
    }
    var _x1 = _s.x - _ox * _s.xs, _x2 = _x1 + _w * _s.xs;
    var _y1 = _s.y - _oy * _s.ys, _y2 = _y1 + _h * _s.ys;
    return [min(_x1, _x2), min(_y1, _y2), max(_x1, _x2), max(_y1, _y2)];
}

/// A batch may land now unless it would put something on this player's play-test character.
function net_coop_batch_safe(_batch) {
    if (room != r_leveleditor || global.LEMode != 2 || !instance_exists(o_player)) return true;
    var _p = instance_find(o_player, 0);
    for (var _i = 0; _i < array_length(_batch.spawns); ++_i) {
        var _box = net_coop_entry_box(_batch.spawns[_i]);
        if (rectangle_in_rectangle(_box[0], _box[1], _box[2], _box[3],
            _p.bbox_left - 16, _p.bbox_top - 16, _p.bbox_right + 16, _p.bbox_bottom + 16) != 0) return false;
    }
    return true;
}

/// Groups the editor keeps a single instance of.
function net_coop_singleton_group(_obj) {
    switch (_obj) {
        case o_playerspawner: return [o_playerspawner];
        case o_door: case o_lockeddoor: return [o_door, o_lockeddoor];
        case o_portalpurpleopen: return [o_portalpurpleopen];
        case o_portalpurpleclosed: return [o_portalpurpleclosed];
    }
    return undefined;
}

function net_coop_apply_batch(_batch) {
    global.net_coop_applying = true;
    var _host = global.net_coop_role == "host";
    var _relay_destroys = [];
    var _relay_spawns = [];
    for (var _i = 0; _i < array_length(_batch.destroys); ++_i) {
        if (net_coop_destroy(_batch.destroys[_i]) || _host) array_push(_relay_destroys, _batch.destroys[_i]);
    }
    var _limit_hit = false;
    for (var _i = 0; _i < array_length(_batch.spawns); ++_i) {
        var _s = _batch.spawns[_i];
        if (_host) {
            // A guest's objects must stay inside the level and inside its own uid space.
            var _ok = floor(_s.uid / NET_COOP_UID_SPACE) == _batch.origin
                && _s.x >= -64 && _s.x < room_width + 64 && _s.y >= 0 && _s.y < room_height + 64
                && ds_map_size(global.net_coop_objects) < 50000;
            var _inst = _ok ? net_coop_spawn(_s) : noone;
            if (!instance_exists(_inst)) {
                if (ds_map_size(global.net_coop_objects) >= 50000) _limit_hit = true;
                // Tell the builder to take it back.
                if (!ds_map_exists(global.net_coop_objects, _s.uid)) array_push(_relay_destroys, _s.uid);
                continue;
            }
            array_push(_relay_spawns, _s);
            var _group = net_coop_singleton_group(_inst.object_index);
            if (is_array(_group)) {
                for (var _g = 0; _g < array_length(_group); ++_g) {
                    with (_group[_g]) {
                        if (id == _inst) continue;
                        // One placed here this tick has no uid yet; nobody else knows it.
                        if (!variable_instance_exists(id, "net_uid") || !ds_map_exists(global.net_coop_objects, net_uid)) { instance_destroy(); continue; }
                        array_push(_relay_destroys, net_uid);
                        net_coop_destroy(net_uid);
                    }
                }
            }
        } else {
            net_coop_spawn(_s);
        }
    }
    if (is_struct(_batch.meta)) net_coop_meta_apply(_batch.meta, _host);
    global.net_coop_applying = false;
    if (_host) {
        // Someone else changed the level: it must be beaten again before it can be published.
        global.LEVerified = 0;
        global.net_coop_edits += 1;
        if (_limit_hit) net_notice(loc("NET_COOP_LIMIT"));
        if (array_length(_relay_destroys) > 0 || array_length(_relay_spawns) > 0) net_coop_send_ops(_relay_destroys, _relay_spawns, undefined, _batch.origin);
    }
}

function net_coop_pump() {
    while (array_length(global.net_coop_queue) > 0) {
        var _batch = global.net_coop_queue[0];
        if (!net_coop_batch_safe(_batch)) break;	// waits for the next respawn, in order
        array_delete(global.net_coop_queue, 0, 1);
        net_coop_apply_batch(_batch);
    }
}

// -----------------------------------------------------------------------------
// Level settings
// -----------------------------------------------------------------------------
function net_coop_meta_capture() {
    return {
        name:string(global.levelname), text:string(global.leveleditorstring), music:string(global.leveleditormusic),
        startingColor:global.defaultcolorLE, background:global.LEBackground, starRotation:global.LEStarRotation,
        diamondTime:global.LEDiamondMedalTime, blockStyle:global.LEBlockStyle, starStyle:global.LEStarStyle,
        fog:variable_global_exists("LEFog") ? global.LEFog : 0
    };
}

function net_coop_meta_text() {
    var _meta = net_coop_meta_capture();
    // Long narrator text is cut for the live stream; snapshots carry all of it.
    if (string_byte_length(_meta.text) > 3000) _meta.text = string_copy(_meta.text, 1, 700);
    return json_stringify(_meta);
}

/// Apply another builder's settings. The creator never takes a name from a guest.
function net_coop_meta_apply(_meta, _from_guest) {
    var _music = string(global.leveleditormusic);
    if (!_from_guest) {
        var _name = net_field(_meta, "name", undefined);
        if (is_string(_name) && string_length(_name) <= 256) global.levelname = _name;
    }
    var _text = net_field(_meta, "text", undefined);
    if (is_string(_text) && string_length(_text) <= 65536) global.leveleditorstring = _text;
    var _new_music = net_field(_meta, "music", undefined);
    if (is_string(_new_music) && string_length(_new_music) <= 8 && string_digits(_new_music) == _new_music && _new_music != "") {
        global.leveleditormusic = clamp(real(_new_music), 0, 31);
    }
    var _color = net_field(_meta, "startingColor", undefined);
    if (net_finite(_color) && _color >= 0 && _color <= 4 && _color == floor(_color)) global.defaultcolorLE = _color;
    var _background = net_field(_meta, "background", undefined);
    if (net_finite(_background) && _background >= 0 && _background <= 2) global.LEBackground = _background;
    var _fog = net_field(_meta, "fog", undefined);
    if (net_finite(_fog) && _fog >= 0 && _fog <= 1) global.LEFog = _fog;
    var _fields = ["starRotation", "diamondTime", "blockStyle", "starStyle"];
    var _globals = ["LEStarRotation", "LEDiamondMedalTime", "LEBlockStyle", "LEStarStyle"];
    for (var _i = 0; _i < array_length(_fields); ++_i) {
        var _value = net_field(_meta, _fields[_i], undefined);
        if (net_finite(_value) && abs(_value) < 1000000) variable_global_set(_globals[_i], _value);
    }
    if (room == r_leveleditor) {
        scr_LEChangeScenery();
        if (global.LEFog == 1) { if (!instance_exists(o_fog)) instance_create(0, 0, o_fog); }
        else instance_destroy(o_fog);
        var _sprites = [s_playerred, s_playeryellow, s_playergreen, s_playerblue, s_playerwhite];
        with (o_playerspawner) sprite_index = _sprites[clamp(global.defaultcolorLE, 0, 4)];
        with (o_inputtext) text = global.leveleditorstring;
        if (string(global.leveleditormusic) != _music) scr_leveleditormusic();
    }
    // A guest takes the creator's settings as its own; the creator sends a guest's on.
    if (!_from_guest) global.net_coop_meta = net_coop_meta_text();
}

// -----------------------------------------------------------------------------
// Packets
// -----------------------------------------------------------------------------
function net_coop_header(_type) {
    var _buffer = global.net_send_buffer;
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, _type);
    buffer_write(_buffer, buffer_string, global.net_coop_cid);
    return _buffer;
}

/// Write one batch packet; returns how many destroys and spawns it took.
function net_coop_write_batch(_type, _seq, _origin, _destroys, _d0, _spawns, _s0, _meta) {
    var _buffer = net_coop_header(_type);
    buffer_write(_buffer, buffer_u32, _seq);
    buffer_write(_buffer, buffer_u8, _origin);
    var _room = NET_CHUNK_MAX_SIZE - buffer_tell(_buffer) - 8 - (is_string(_meta) ? string_byte_length(_meta) + 1 : 0);
    var _nd = clamp(array_length(_destroys) - _d0, 0, max(0, _room div 8));
    _room -= _nd * 8;
    var _ns = clamp(array_length(_spawns) - _s0, 0, max(0, _room div NET_COOP_ENTRY_BYTES));
    buffer_write(_buffer, buffer_u16, _nd);
    for (var _i = 0; _i < _nd; ++_i) buffer_write(_buffer, buffer_f64, _destroys[_d0 + _i]);
    buffer_write(_buffer, buffer_u16, _ns);
    for (var _i = 0; _i < _ns; ++_i) net_coop_write_entry(_buffer, _spawns[_s0 + _i]);
    buffer_write(_buffer, buffer_u8, is_string(_meta) ? 1 : 0);
    if (is_string(_meta)) buffer_write(_buffer, buffer_string, _meta);
    return [_nd, _ns, buffer_tell(_buffer)];
}

/// Creator: send numbered changes to every guest.
function net_coop_send_ops(_destroys, _spawns, _meta, _origin) {
    var _d = 0, _s = 0;
    do {
        global.net_coop_seq += 1;
        var _done = net_coop_write_batch(NET_PACKET_COOP_OPS, global.net_coop_seq, _origin, _destroys, _d, _spawns, _s, _meta);
        _d += _done[0];
        _s += _done[1];
        _meta = undefined;
        var _key = ds_map_find_first(global.net_coop_guests);
        while (!is_undefined(_key)) {
            net_send_to(global.net_coop_guests[? _key].id, _done[2], true);
            _key = ds_map_find_next(global.net_coop_guests, _key);
        }
    } until (_d >= array_length(_destroys) && _s >= array_length(_spawns));
}

/// Guest: send this player's own changes to the creator.
function net_coop_send_edit(_destroys, _spawns, _meta) {
    var _d = 0, _s = 0;
    do {
        // Numbered, so the creator notices a lost packet and sends the level again.
        global.net_coop_edit_seq += 1;
        var _done = net_coop_write_batch(NET_PACKET_COOP_EDIT, global.net_coop_edit_seq, global.net_coop_slot, _destroys, _d, _spawns, _s, _meta);
        _d += _done[0];
        _s += _done[1];
        _meta = undefined;
        net_send_to(global.net_coop_host, _done[2], true);
    } until (_d >= array_length(_destroys) && _s >= array_length(_spawns));
}

/// Read a batch after the header; undefined when malformed.
function net_coop_read_batch(_buffer, _size) {
    if (buffer_tell(_buffer) + 9 > _size) return undefined;
    var _seq = buffer_read(_buffer, buffer_u32);
    var _origin = buffer_read(_buffer, buffer_u8);
    var _nd = buffer_read(_buffer, buffer_u16);
    if (buffer_tell(_buffer) + _nd * 8 + 3 > _size) return undefined;
    var _destroys = array_create(_nd);
    for (var _i = 0; _i < _nd; ++_i) {
        _destroys[_i] = buffer_read(_buffer, buffer_f64);
        if (!net_finite(_destroys[_i])) return undefined;
    }
    var _ns = buffer_read(_buffer, buffer_u16);
    if (buffer_tell(_buffer) + _ns * NET_COOP_ENTRY_BYTES + 1 > _size) return undefined;
    var _spawns = array_create(_ns);
    for (var _i = 0; _i < _ns; ++_i) {
        _spawns[_i] = net_coop_read_entry(_buffer);
        if (!net_coop_entry_valid(_spawns[_i])) return undefined;
    }
    var _meta = undefined;
    if (buffer_read(_buffer, buffer_u8) == 1) {
        if (net_packet_string_end(_buffer, buffer_tell(_buffer), _size, NET_COOP_META_MAX) < 0) return undefined;
        try { _meta = json_parse(buffer_read(_buffer, buffer_string)); } catch (_error) { return undefined; }
        if (!is_struct(_meta)) return undefined;
    }
    return {seq:_seq, origin:_origin, destroys:_destroys, spawns:_spawns, meta:_meta};
}

function net_coop_send_simple(_target, _type, _value) {
    var _buffer = net_coop_header(_type);
    buffer_write(_buffer, buffer_u8, _value);
    net_send_to(_target, buffer_tell(_buffer), true);
}

/// Dispatched by net_receive_packets for every co-op packet type but the invitation.
function net_coop_receive(_sender, _type, _buf, _size) {
    if (_size > NET_CHUNK_MAX_SIZE || net_packet_string_end(_buf, 1, _size, 40) < 0) return;
    buffer_seek(_buf, buffer_seek_start, 1);
    var _cid = buffer_read(_buf, buffer_string);
    var _key = string(_sender);
    switch (_type) {
        case NET_PACKET_COOP_JOIN:
            if (buffer_tell(_buf) + 5 > _size || net_packet_string_end(_buf, buffer_tell(_buf) + 4, _size, 40) < 0) break;
            var _version = buffer_read(_buf, buffer_u32);
            net_coop_host_join(_sender, _cid, _version, buffer_read(_buf, buffer_string));
            break;
        case NET_PACKET_COOP_EDIT:
            if (global.net_coop_role != "host" || _cid != global.net_coop_cid) break;
            var _guest = global.net_coop_guests[? _key];
            if (is_undefined(_guest)) { net_coop_send_simple(_sender, NET_PACKET_COOP_END, NET_COOP_END_REMOVED); break; }
            var _batch = net_coop_read_batch(_buf, _size);
            if (is_undefined(_batch)) break;
            _batch.origin = _guest.slot;
            net_coop_host_edit(_guest, _batch);
            break;
        case NET_PACKET_COOP_LEAVE:
        case NET_PACKET_COOP_RESYNC:
            if (global.net_coop_role != "host" || _cid != global.net_coop_cid) break;
            var _who = global.net_coop_guests[? _key];
            if (is_undefined(_who)) break;
            if (_type == NET_PACKET_COOP_LEAVE) {
                net_notice(string_replace(loc("NET_COOP_GUEST_LEFT"), "{NAME}", _who.name));
                ds_map_delete(global.net_coop_guests, _key);
                ds_map_delete(global.net_coop_cursors, _key);
            } else if (current_time - _who.snapshot_at > 3000) {
                _who.resync = true;
            }
            break;
        case NET_PACKET_COOP_CURSOR:
            if (_cid != global.net_coop_cid || global.net_coop_role == "" || buffer_tell(_buf) + 9 > _size) break;
            var _cursor = global.net_coop_cursors[? _key];
            if (is_undefined(_cursor)) {
                _cursor = {name:net_clean_name(tcc_steam_get_user_persona_name_sync(_sender)), x:0, y:0, flags:0, at:0,
                    color:make_color_hsv((ds_map_size(global.net_coop_cursors) * 67 + 20) mod 256, 160, 255)};
                global.net_coop_cursors[? _key] = _cursor;
            }
            var _cx = buffer_read(_buf, buffer_f32);
            var _cy = buffer_read(_buf, buffer_f32);
            if (!net_finite(_cx) || !net_finite(_cy)) break;
            _cursor.x = _cx; _cursor.y = _cy;
            _cursor.flags = buffer_read(_buf, buffer_u8);
            _cursor.at = current_time;
            break;
        default:
            // Creator -> guest packets come only from the creator we accepted.
            var _accept = global.net_coop_accept;
            var _expected = global.net_coop_role == "guest" ? global.net_coop_host : (is_struct(_accept) ? _accept.host : int64(0));
            var _expected_cid = global.net_coop_role == "guest" ? global.net_coop_cid : (is_struct(_accept) ? _accept.cid : "");
            if (_sender != _expected || _cid != _expected_cid) break;
            net_coop_guest_receive(_type, _buf, _size);
            break;
    }
}

// -----------------------------------------------------------------------------
// Invitations
// -----------------------------------------------------------------------------
function net_coop_friend_playing(_id) {
    var _friends = net_friends_list();
    for (var _i = 0; _i < array_length(_friends); ++_i) if (_friends[_i].id == _id) return _friends[_i];
    return undefined;
}

/// Creator: invite a friend who is playing the game.
function net_coop_invite(_id, _name) {
    if (!global.net_active || room != r_leveleditor || global.net_coop_role == "guest" || !global.net_coop_ready) return false;
    if (global.net_coop_role == "") {
        global.net_coop_role = "host";
        global.net_coop_cid = net_new_sid();
        global.net_coop_slot = 0;
        global.net_coop_counter = 0;
        global.net_coop_seq = 0;
        global.net_coop_edits = 0;
        net_coop_baseline(false);
        global.net_coop_meta = net_coop_meta_text();
    }
    global.net_coop_invited[? string(_id)] = {id:_id, name:net_clean_name(_name), at:current_time};
    var _buffer = net_coop_header(NET_PACKET_COOP_INVITE);
    buffer_write(_buffer, buffer_u64, global.net_lobby_id);
    buffer_write(_buffer, buffer_u32, NET_COOP_VERSION);
    buffer_write(_buffer, buffer_string, net_coop_registry().hash);
    buffer_write(_buffer, buffer_string, string_copy(net_clean_name(global.levelname), 1, 64));
    net_send_to(_id, buffer_tell(_buffer), true);
    net_notice(string_replace(loc("NET_COOP_INVITE_SENT"), "{NAME}", net_clean_name(_name)));
    return true;
}

/// An invitation arrives from someone who need not share our lobby yet.
function net_coop_receive_invite(_sender, _buf, _size) {
    if (_size > NET_PACKET_MAX_SIZE || net_packet_string_end(_buf, 1, _size, 40) < 0) return;
    buffer_seek(_buf, buffer_seek_start, 1);
    var _cid = buffer_read(_buf, buffer_string);
    if (_cid == "" || buffer_tell(_buf) + 13 > _size) return;
    var _lobby = buffer_read(_buf, buffer_u64);
    var _version = buffer_read(_buf, buffer_u32);
    if (net_packet_string_end(_buf, buffer_tell(_buf), _size, 32) < 0) return;
    var _hash = buffer_read(_buf, buffer_string);
    if (net_packet_string_end(_buf, buffer_tell(_buf), _size, 256) < 0) return;
    var _level = net_clean_name(buffer_read(_buf, buffer_string));
    if (_lobby == 0) return;
    // Only friends playing right now can invite; anyone else could send packets.
    var _friend = net_coop_friend_playing(_sender);
    if (is_undefined(_friend)) return;
    if (_version != NET_COOP_VERSION || _hash != net_coop_registry().hash) {
        net_notice(string_replace(loc("NET_COOP_VERSION"), "{NAME}", _friend.name));
        return;
    }
    if (global.net_coop_role == "guest" && global.net_coop_host == _sender && global.net_coop_cid == _cid) return;
    var _offer = global.net_coop_offer;
    if (is_struct(_offer) && _offer.from == _sender && _offer.cid == _cid && current_time - _offer.at < 2000) return;
    global.net_coop_offer = {from:_sender, name:_friend.name, level:_level, cid:_cid, lobby:_lobby, at:current_time};
}

function net_coop_accept_offer() {
    var _offer = global.net_coop_offer;
    global.net_coop_offer = undefined;
    if (!is_struct(_offer) || !net_enabled()) return;
    if (global.net_coop_role == "host") net_coop_host_end(NET_COOP_END_CLOSED);
    else if (global.net_coop_role == "guest") net_coop_guest_exit("");
    global.net_coop_accept = {host:_offer.from, name:_offer.name, cid:_offer.cid, lobby:_offer.lobby, at:current_time, sent:0};
    if (!(global.net_active && global.net_lobby_id == _offer.lobby)) net_request_join(_offer.lobby);
}

/// Accepted: once we share the creator's lobby, ask for the level.
function net_coop_accept_tick() {
    var _accept = global.net_coop_accept;
    if (!is_struct(_accept)) return;
    if (current_time - _accept.at > NET_COOP_JOIN_MS) {
        global.net_coop_accept = undefined;
        net_flash(false, loc("NET_COOP_JOIN_FAILED"));
        return;
    }
    if (!global.net_active || global.net_lobby_id != _accept.lobby || !net_lobby_member(_accept.host)) return;
    if (current_time - _accept.sent < 3000) return;
    _accept.sent = current_time;
    var _buffer = global.net_send_buffer;
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, NET_PACKET_COOP_JOIN);
    buffer_write(_buffer, buffer_string, _accept.cid);
    buffer_write(_buffer, buffer_u32, NET_COOP_VERSION);
    buffer_write(_buffer, buffer_string, net_coop_registry().hash);
    net_send_to(_accept.host, buffer_tell(_buffer), true);
}

// -----------------------------------------------------------------------------
// Creator
// -----------------------------------------------------------------------------
function net_coop_editor_ready() {
    return room == r_leveleditor && instance_exists(o_leveleditorselect)
        && !instance_exists(o_spawnthing) && !instance_exists(o_levelreloadagain);
}

function net_coop_host_join(_sender, _cid, _version, _hash) {
    if (global.net_coop_role != "host" || _cid != global.net_coop_cid) {
        net_coop_send_deny(_sender, _cid, NET_COOP_DENY_NOT_BUILDING);
        return;
    }
    if (_version != NET_COOP_VERSION || _hash != net_coop_registry().hash) { net_coop_send_deny(_sender, _cid, NET_COOP_DENY_VERSION); return; }
    var _key = string(_sender);
    var _invite = global.net_coop_invited[? _key];
    if (is_undefined(_invite)) { net_coop_send_deny(_sender, _cid, NET_COOP_DENY_NOT_INVITED); return; }
    if (!global.net_coop_ready) return;	// the guest asks again
    var _guest = global.net_coop_guests[? _key];
    if (is_undefined(_guest)) {
        if (global.net_coop_next_slot > 255 || ds_map_size(global.net_coop_guests) >= NET_MAX_LOBBY) { net_coop_send_deny(_sender, _cid, NET_COOP_DENY_FULL); return; }
        var _slot = global.net_coop_next_slot;
        global.net_coop_next_slot += 1;
        _guest = {id:_sender, name:_invite.name, slot:_slot, budget:NET_COOP_BUDGET, refill_at:current_time,
            resync:false, snapshot_at:-100000, edit_seq:0};
        global.net_coop_guests[? _key] = _guest;
        net_notice(string_replace(loc("NET_COOP_GUEST_JOINED"), "{NAME}", _guest.name));
    } else if (current_time - _guest.snapshot_at < 5000) {
        return;	// a repeated request while the first answer is on its way
    }
    net_coop_send_snapshot(_guest, false);
}

function net_coop_send_deny(_target, _cid, _reason) {
    var _buffer = global.net_send_buffer;
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, NET_PACKET_COOP_DENY);
    buffer_write(_buffer, buffer_string, _cid);
    buffer_write(_buffer, buffer_u8, _reason);
    net_send_to(_target, buffer_tell(_buffer), true);
}

/// The level as it stands in the stream, private to one guest. Its file identity
/// (Workshop item and version) never leaves the creator's machine.
function net_coop_snapshot_text(_guest) {
    var _rows = [];
    var _names = net_coop_registry().names;
    timing_activate_object(o_leveleditorloadplacement);
    with (o_leveleditorloadplacement) {
        var _w = net_coop_wire(id);
        if (_w == 0 || !variable_instance_exists(id, "net_uid")) continue;
        var _order = variable_instance_exists(id, "level_document_order") ? level_document_order : 1000000000 + array_length(_rows);
        array_push(_rows, {order:_order, uid:net_uid, entry:{obj:_names[_w - 1], x:x, y:y, imageindex:image_index,
            xscale:image_xscale, yscale:image_yscale, orientation:net_coop_orientation(id, _names[_w - 1])}});
    }
    array_sort(_rows, function(_a, _b) { return _a.order - _b.order; });
    var _document = level_document_defaults();
    _document.metadata = level_metadata_capture();
    _document.metadata.publishId = "0";
    _document.metadata.workshopVersion = 0;
    var _uids = array_create(array_length(_rows));
    for (var _i = 0; _i < array_length(_rows); ++_i) {
        array_push(_document.instances, _rows[_i].entry);
        _uids[_i] = _rows[_i].uid;
    }
    return json_stringify({level:_document, uids:_uids, seq:global.net_coop_seq, guest:string(_guest.id)});
}

function net_coop_send_snapshot(_guest, _resync) {
    // Everything this player built so far goes out first, so the snapshot matches the stream.
    net_coop_scan_send(true);
    var _md5 = net_levelshare_offer(net_coop_snapshot_text(_guest), _guest.id);
    _guest.snapshot_at = current_time;
    _guest.resync = false;
    var _buffer = net_coop_header(NET_PACKET_COOP_WELCOME);
    buffer_write(_buffer, buffer_u8, _guest.slot);
    buffer_write(_buffer, buffer_u32, global.net_coop_seq);
    buffer_write(_buffer, buffer_u8, _resync ? 1 : 0);
    buffer_write(_buffer, buffer_string, _md5);
    net_send_to(_guest.id, buffer_tell(_buffer), true);
}

/// Tell guests to wait: the level is being rebuilt (an empty snapshot id).
function net_coop_send_hold() {
    var _buffer = net_coop_header(NET_PACKET_COOP_WELCOME);
    buffer_write(_buffer, buffer_u8, 0);
    buffer_write(_buffer, buffer_u32, global.net_coop_seq);
    buffer_write(_buffer, buffer_u8, 1);
    buffer_write(_buffer, buffer_string, "");
    var _size = buffer_tell(_buffer);
    var _key = ds_map_find_first(global.net_coop_guests);
    while (!is_undefined(_key)) {
        net_send_to(global.net_coop_guests[? _key].id, _size, true);
        _key = ds_map_find_next(global.net_coop_guests, _key);
    }
}

function net_coop_host_edit(_guest, _batch) {
    var _gap = _batch.seq != _guest.edit_seq + 1;
    _guest.edit_seq = _batch.seq;
    // The level is being rebuilt; the guest gets the new one afterwards.
    if (!global.net_coop_ready) return;
    // A lost edit means the guest's copy differs from ours: send the level again.
    if (_gap) _guest.resync = true;
    var _cost = array_length(_batch.destroys) + array_length(_batch.spawns);
    if (_cost > _guest.budget) {
        // Flooding: ignore it and put that guest back in step with the level.
        _guest.resync = true;
        return;
    }
    _guest.budget -= _cost;
    array_push(global.net_coop_queue, _batch);
}

function net_coop_host_kick(_id) {
    var _key = string(_id);
    var _guest = global.net_coop_guests[? _key];
    ds_map_delete(global.net_coop_invited, _key);
    ds_map_delete(global.net_coop_guests, _key);
    ds_map_delete(global.net_coop_cursors, _key);
    if (!is_undefined(_guest)) net_coop_send_simple(_id, NET_PACKET_COOP_END, NET_COOP_END_REMOVED);
}

function net_coop_host_end(_reason) {
    var _key = ds_map_find_first(global.net_coop_guests);
    while (!is_undefined(_key)) {
        net_coop_send_simple(global.net_coop_guests[? _key].id, NET_PACKET_COOP_END, _reason);
        _key = ds_map_find_next(global.net_coop_guests, _key);
    }
    net_coop_reset();
}

function net_coop_host_tick() {
    if (room != r_leveleditor || !global.net_active) {
        net_coop_host_end(NET_COOP_END_CLOSED);
        return;
    }
    var _ready = net_coop_editor_ready();
    if (!_ready) {
        if (global.net_coop_ready) {
            global.net_coop_ready = false;
            global.net_coop_queue = [];
            net_coop_send_hold();
        }
        return;
    }
    if (!global.net_coop_ready) {
        // A new or reloaded level: everyone starts again from it.
        global.net_coop_ready = true;
        net_coop_baseline(false);
        global.net_coop_meta = net_coop_meta_text();
        var _key = ds_map_find_first(global.net_coop_guests);
        while (!is_undefined(_key)) {
            global.net_coop_guests[? _key].resync = true;
            _key = ds_map_find_next(global.net_coop_guests, _key);
        }
    }
    // Guests who left the lobby are gone; budgets refill.
    var _key = ds_map_find_first(global.net_coop_guests);
    while (!is_undefined(_key)) {
        var _next = ds_map_find_next(global.net_coop_guests, _key);
        var _guest = global.net_coop_guests[? _key];
        if (!net_lobby_member(_guest.id)) {
            net_notice(string_replace(loc("NET_COOP_GUEST_LEFT"), "{NAME}", _guest.name));
            ds_map_delete(global.net_coop_guests, _key);
            ds_map_delete(global.net_coop_cursors, _key);
        } else {
            var _elapsed = current_time - _guest.refill_at;
            if (_elapsed >= 100) {
                _guest.budget = min(NET_COOP_BUDGET, _guest.budget + NET_COOP_BUDGET_REFILL * _elapsed / 1000);
                _guest.refill_at = current_time;
            }
            if (_guest.resync && current_time - _guest.snapshot_at > 3000) net_coop_send_snapshot(_guest, true);
        }
        _key = _next;
    }
    net_coop_pump();
    net_coop_scan_send(false);
    var _meta = net_coop_meta_text();
    if (_meta != global.net_coop_meta) {
        global.net_coop_meta = _meta;
        net_coop_send_ops([], [], _meta, 0);
    }
}

// -----------------------------------------------------------------------------
// Guest
// -----------------------------------------------------------------------------
function net_coop_guest_receive(_type, _buf, _size) {
    switch (_type) {
        case NET_PACKET_COOP_WELCOME:
            if (buffer_tell(_buf) + 7 > _size) break;
            var _slot = buffer_read(_buf, buffer_u8);
            var _seq = buffer_read(_buf, buffer_u32);
            var _resync = buffer_read(_buf, buffer_u8) == 1;
            if (net_packet_string_end(_buf, buffer_tell(_buf), _size, 32) < 0) break;
            var _md5 = buffer_read(_buf, buffer_string);
            if (_md5 != "" && !net_levelshare_md5_valid(_md5)) break;
            if (global.net_coop_role == "") {
                if (_resync || _md5 == "" || _slot < 1) break;
                var _accept = global.net_coop_accept;
                global.net_coop_accept = undefined;
                net_coop_reset();
                global.net_coop_role = "guest";
                global.net_coop_cid = _accept.cid;
                global.net_coop_host = _accept.host;
                global.net_coop_slot = _slot;
                global.net_coop_host_seen = current_time;
                net_follow_cancel();
            }
            if (_md5 == "") {
                global.net_coop_state = "hold";		// the creator is rebuilding the level
                break;
            }
            global.net_coop_state = "loading";
            global.net_coop_snapshot_md5 = _md5;
            global.net_coop_snapshot_seq = _seq;
            global.net_coop_snapshot_tries = 0;
            net_levelshare_request(_md5, global.net_coop_host, true);
            break;
        case NET_PACKET_COOP_DENY:
            if (buffer_tell(_buf) + 1 > _size) break;
            var _reason = buffer_read(_buf, buffer_u8);
            if (global.net_coop_role == "guest") { net_coop_guest_exit(loc("NET_COOP_CLOSED")); break; }
            global.net_coop_accept = undefined;
            net_flash(false, loc(_reason == NET_COOP_DENY_VERSION ? "NET_COOP_DENIED_VERSION"
                : (_reason == NET_COOP_DENY_FULL ? "NET_COOP_DENIED_FULL" : "NET_COOP_DENIED")));
            break;
        case NET_PACKET_COOP_OPS:
            if (global.net_coop_role != "guest") break;
            var _batch = net_coop_read_batch(_buf, _size);
            if (is_undefined(_batch)) break;
            if (global.net_coop_state != "active") {
                array_push(global.net_coop_early, _batch);
                break;
            }
            if (_batch.seq <= global.net_coop_seq) break;
            if (_batch.seq != global.net_coop_seq + 1) {
                // A gap can only mean lost state: start again from a fresh level.
                net_coop_guest_resync();
                array_push(global.net_coop_early, _batch);
                break;
            }
            global.net_coop_seq = _batch.seq;
            array_push(global.net_coop_queue, _batch);
            break;
        case NET_PACKET_COOP_END:
            if (global.net_coop_role != "guest") { global.net_coop_accept = undefined; break; }
            var _why = (buffer_tell(_buf) + 1 <= _size) ? buffer_read(_buf, buffer_u8) : NET_COOP_END_CLOSED;
            net_coop_guest_exit(loc(_why == NET_COOP_END_REMOVED ? "NET_COOP_REMOVED" : "NET_COOP_CLOSED"));
            break;
    }
}

function net_coop_guest_resync() {
    global.net_coop_state = "hold";
    var _buffer = net_coop_header(NET_PACKET_COOP_RESYNC);
    buffer_write(_buffer, buffer_u8, 0);
    net_send_to(global.net_coop_host, buffer_tell(_buffer), true);
}

/// Parse a snapshot; undefined unless it is a valid level with one uid per object.
function net_coop_parse_snapshot(_text) {
    var _data = undefined;
    try { _data = json_parse(_text); } catch (_error) { return undefined; }
    var _level = net_field(_data, "level", undefined);
    var _uids = net_field(_data, "uids", undefined);
    if (!is_struct(_level) || !is_array(_uids) || !level_validate(_level).valid) return undefined;
    if (array_length(_uids) != array_length(_level.instances)) return undefined;
    for (var _i = 0; _i < array_length(_uids); ++_i) if (!net_finite(_uids[_i]) || _uids[_i] < 1) return undefined;
    // Nothing that names the creator's files reaches this machine.
    _level.metadata.publishId = "0";
    _level.metadata.workshopVersion = 0;
    return {level:_level, uids:_uids};
}

/// Leave whatever the guest was doing and open the editor on the creator's level.
function net_coop_guest_enter(_snapshot) {
    net_enter_begin();
    // The guest's own editor helpers would load, save or show menus over the shared level.
    instance_destroy(o_leveleditormenusetup);
    instance_destroy(o_chooseleveleditorlevel);
    instance_destroy(o_spawnthing);
    instance_destroy(o_levelreloadagain);
    instance_destroy(o_leveleditorleaveask);
    // The editor globals o_leveleditor's button sets, without its setup menu.
    global.LEBuild = 1;
    global.LES = 0;
    global.levelname = "";
    global.level_editor_folder = "";
    global.previoustext = "";
    global.leveleditorstring = "";
    global.naminglevel = false;
    global.writingmode = 0;
    global.LEVerified = 0;
    global.defaultcolorLE = 0;
    global.LEMode = 1;
    global.color = 0;
    global.leveleditormusic = 0;
    global.LEBackground = 0;
    global.LEStarRotation = 0;
    global.LEbuttonpage = 1;
    global.LEDiamondMedalTime = 100;
    global.leveleditorversion = 1;
    global.Publish_ID = 0;
    global.workshoplevelversion = 0;
    global.LEStarStyle = 0;
    global.LEBlockStyle = 0;
    global.workshop = 0;
    sprite_set_offset(s_cannotplace, 0, 0);
    room_set_width(r_leveleditor, _snapshot.level.metadata.widthBlocks * 32);
    room_set_height(r_leveleditor, 64 + _snapshot.level.metadata.heightBlocks * 32);
    global.net_coop_pending = _snapshot;
    global.net_coop_state = "entering";
    if (room == r_leveleditor) room_restart(); else room_goto(r_leveleditor);
}

/// Build the creator's level in this room and continue the stream from it.
function net_coop_guest_apply(_snapshot, _first) {
    global.net_coop_queue = [];
    global.net_coop_applying = true;
    var _ok = level_apply(_snapshot.level, "editor", _snapshot.uids);
    global.net_coop_applying = false;
    if (!_ok) { net_coop_guest_exit(loc("NET_COOP_LOST")); return; }
    global.Publish_ID = 0;
    global.level_editor_folder = "";
    net_coop_baseline(true);
    if (_first) {
        global.LEBuild = 1;
        global.LES = 0;
        if (!instance_exists(o_inputtext)) instance_create(0, 0, o_inputtext);
        if (instance_exists(o_spawnthing) == false) instance_create(0, 0, o_spawnthing);
    }
    scr_LEChangeScenery();
    with (o_inputtext) text = global.leveleditorstring;
    scr_leveleditormusic();
    global.net_coop_meta = net_coop_meta_text();
    global.net_coop_seq = global.net_coop_snapshot_seq;
    global.net_coop_state = "active";
    global.net_coop_entered = true;
    // Changes made after the snapshot, in order.
    array_sort(global.net_coop_early, function(_a, _b) { return _a.seq - _b.seq; });
    var _early = global.net_coop_early;
    global.net_coop_early = [];
    for (var _i = 0; _i < array_length(_early); ++_i) {
        if (_early[_i].seq != global.net_coop_seq + 1) continue;
        global.net_coop_seq = _early[_i].seq;
        array_push(global.net_coop_queue, _early[_i]);
    }
}

/// Play-test state that must not survive a room restart.
function net_coop_build_mode() {
    if (global.LEMode != 2) return;
    global.time = 0;
    global.LESavedWinTime = 0;
    instance_destroy(o_time);
    instance_destroy(o_timecounter);
    instance_destroy(o_deathcounter);
    global.LEMode = 1;
    with (o_LEMode) image_index = 0;
}

function net_coop_guest_tick() {
    if (net_lobby_member(global.net_coop_host)) global.net_coop_host_seen = current_time;
    else if (current_time - global.net_coop_host_seen > NET_COOP_HOST_LOST_MS) { net_coop_guest_exit(loc("NET_COOP_LOST")); return; }
    // The guest left the editor (Esc, Back): the session ends for them.
    if (global.net_coop_entered && room != r_leveleditor && global.net_coop_state != "entering") {
        net_coop_guest_exit("");
        return;
    }
    switch (global.net_coop_state) {
        case "loading":
            var _memory = global.net_share_memory;
            if (is_struct(_memory) && _memory.md5 == global.net_coop_snapshot_md5) {
                global.net_share_memory = undefined;
                var _snapshot = net_coop_parse_snapshot(_memory.text);
                if (is_undefined(_snapshot)) { net_coop_guest_exit(loc("NET_COOP_LOST")); return; }
                var _dims = room == r_leveleditor
                    && room_width == _snapshot.level.metadata.widthBlocks * 32
                    && room_height == 64 + _snapshot.level.metadata.heightBlocks * 32;
                if (room == r_leveleditor && _dims && instance_exists(o_leveleditorselect)) {
                    net_coop_guest_apply(_snapshot, false);
                } else if (room == r_leveleditor && instance_exists(o_leveleditorselect)) {
                    // A resized level needs the room rebuilt at its new size.
                    net_coop_build_mode();
                    room_set_width(r_leveleditor, _snapshot.level.metadata.widthBlocks * 32);
                    room_set_height(r_leveleditor, 64 + _snapshot.level.metadata.heightBlocks * 32);
                    global.net_coop_pending = _snapshot;
                    global.net_coop_state = "entering";
                    room_restart();
                } else {
                    net_coop_guest_enter(_snapshot);
                }
                break;
            }
            var _in = global.net_share_in;
            if (is_struct(_in) && _in.md5 == global.net_coop_snapshot_md5) break;
            // Not downloading: ask again, or start over with a fresh snapshot.
            if (ds_map_exists(global.net_share_denied, global.net_coop_snapshot_md5)) {
                ds_map_delete(global.net_share_denied, global.net_coop_snapshot_md5);
                global.net_coop_snapshot_tries += 1;
                if (global.net_coop_snapshot_tries > 3) { net_coop_guest_exit(loc("NET_COOP_LOST")); return; }
                net_coop_guest_resync();
            } else {
                net_levelshare_request(global.net_coop_snapshot_md5, global.net_coop_host, true);
            }
            break;
        case "entering":
            var _pending = global.net_coop_pending;
            if (room != r_leveleditor || !is_struct(_pending)) break;
            global.net_coop_pending = undefined;
            net_coop_guest_apply(_pending, true);
            break;
        case "active":
            net_coop_pump();
            net_coop_scan_send(false);
            var _meta = net_coop_meta_text();
            if (_meta != global.net_coop_meta) {
                global.net_coop_meta = _meta;
                net_coop_send_edit([], [], _meta);
            }
            break;
    }
}

/// The session is over for this guest. In the editor they return to the main menu;
/// nothing of the creator's level stays behind.
function net_coop_guest_exit(_notice) {
    if (global.net_coop_role == "guest" && net_lobby_member(global.net_coop_host)) {
        var _buffer = net_coop_header(NET_PACKET_COOP_LEAVE);
        buffer_write(_buffer, buffer_u8, 0);
        net_send_to(global.net_coop_host, buffer_tell(_buffer), true);
    }
    var _in_editor = room == r_leveleditor || global.net_coop_state == "entering";
    net_coop_reset();
    global.levelname = "";
    global.level_editor_folder = "";
    global.leveleditorstring = "";
    global.Publish_ID = 0;
    if (_in_editor) {
        net_coop_build_mode();
        audio_stop_all();
        hidehud();
        instance_destroy(o_smoothcamera);
        instance_destroy(o_leveleditorleaveask);
        instance_destroy(o_spawnthing);
        level_music_release();
        room_set_width(r_leveleditor, 1024);
        room_set_height(r_leveleditor, 768);
        global.LES = 0;
        window_set_cursor(cr_default);
        room_goto(r_mainmenu);
    }
    if (_notice != "") net_flash(false, _notice);
}

// -----------------------------------------------------------------------------
// Pointers of the other builders
// -----------------------------------------------------------------------------
function net_coop_send_cursor() {
    if (room != r_leveleditor || timing_tick_id() - global.net_coop_cursor_tick < 4) return;
    global.net_coop_cursor_tick = timing_tick_id();
    var _key = global.net_level_key;
    if (_key == "") return;
    var _flags = (global.LEMode == 2 ? 1 : 0) | (instance_exists(o_deleteblock) ? 2 : 0);
    var _buffer = net_coop_header(NET_PACKET_COOP_CURSOR);
    buffer_write(_buffer, buffer_f32, mouse_x);
    buffer_write(_buffer, buffer_f32, mouse_y);
    buffer_write(_buffer, buffer_u8, _flags);
    var _size = buffer_tell(_buffer);
    for (var _i = 0; _i < array_length(global.net_member_list); ++_i) {
        var _peer = global.net_players[? string(global.net_member_list[_i])];
        if (is_struct(_peer) && _peer.level_key == _key) net_send_to(global.net_member_list[_i], _size, false);
    }
}

/// Draw event, room space: where the other builders point.
function net_coop_draw_cursors() {
    if (!variable_global_exists("net_coop_role") || global.net_coop_role == "" || room != r_leveleditor) return;
    draw_set_font(fnt_multiplayerfont);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    var _key = ds_map_find_first(global.net_coop_cursors);
    while (!is_undefined(_key)) {
        var _c = global.net_coop_cursors[? _key];
        if (current_time - _c.at < 1500 && (_c.flags & 1) == 0) {
            var _color = _c.color;
            var _cx = floor(_c.x / 32) * 32;
            var _cy = floor(_c.y / 32) * 32;
            draw_set_alpha(0.8);
            draw_set_color(_color);
            draw_rectangle(_cx, _cy, _cx + 31, _cy + 31, true);
            draw_rectangle(_cx + 1, _cy + 1, _cx + 30, _cy + 30, true);
            if ((_c.flags & 2) != 0) draw_line_width(_cx + 4, _cy + 4, _cx + 27, _cy + 27, 2);
            draw_set_color(c_black);
            draw_text(_cx + 17, _cy - 1, _c.name);
            draw_set_color(_color);
            draw_text(_cx + 16, _cy - 2, _c.name);
        }
        _key = ds_map_find_next(global.net_coop_cursors, _key);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// -----------------------------------------------------------------------------
// Per tick (o_networkmanager Step, after net_tick)
// -----------------------------------------------------------------------------
function net_coop_tick() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    var _offer = global.net_coop_offer;
    if (is_struct(_offer) && (current_time - _offer.at > NET_COOP_INVITE_MS || !net_enabled())) global.net_coop_offer = undefined;
    net_coop_accept_tick();
    switch (global.net_coop_role) {
        case "host": net_coop_host_tick(); break;
        case "guest": net_coop_guest_tick(); break;
    }
    if (global.net_coop_role != "") net_coop_send_cursor();
}

// -----------------------------------------------------------------------------
// Invitation prompt (any room, drawn by o_networkmanager)
// -----------------------------------------------------------------------------
function net_coop_offer_buttons() {
    return [{x0:332, y0:122, x1:502, y1:150, action:"accept"}, {x0:522, y0:122, x1:692, y1:150, action:"decline"}];
}

/// Begin Step: a click on the prompt never reaches the room underneath.
function net_coop_offer_input() {
    if (!variable_global_exists("net_coop_offer") || !is_struct(global.net_coop_offer)) return;
    if (!mouse_check_button_pressed(mb_left)) return;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    if (!point_in_rectangle(_mx, _my, 312, 40, 712, 160)) return;
    var _buttons = net_coop_offer_buttons();
    for (var _i = 0; _i < array_length(_buttons); ++_i) {
        var _b = _buttons[_i];
        if (!point_in_rectangle(_mx, _my, _b.x0, _b.y0, _b.x1, _b.y1)) continue;
        if (_b.action == "accept") net_coop_accept_offer(); else global.net_coop_offer = undefined;
    }
    mouse_clear(mb_left);
}

function net_coop_draw_offer() {
    var _offer = global.net_coop_offer;
    if (!is_struct(_offer)) return;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    draw_set_alpha(0.92);
    draw_set_color($1a1a1a);
    draw_rectangle(312, 40, 712, 160, false);
    draw_set_alpha(1);
    draw_set_color($00aaff);
    draw_rectangle(312, 40, 712, 160, true);
    var _left = 1 - clamp((current_time - _offer.at) / NET_COOP_INVITE_MS, 0, 1);
    draw_rectangle(313, 157, 313 + 398 * _left, 159, false);
    net_draw_avatar(_offer.from, 324, 52, 48, 1);
    draw_set_font(fnt_multiplayerfont);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text_ext(384, 52, string_replace(loc("NET_COOP_INVITED"), "{NAME}", _offer.name), 16, 316);
    draw_set_color($aaaaaa);
    if (_offer.level != "") draw_text_ext(384, 88, "\"" + _offer.level + "\"", 16, 316);
    var _buttons = net_coop_offer_buttons();
    var _labels = [loc("NET_COOP_ACCEPT"), loc("NET_COOP_DECLINE")];
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var _i = 0; _i < array_length(_buttons); ++_i) {
        var _b = _buttons[_i];
        var _hover = point_in_rectangle(_mx, _my, _b.x0, _b.y0, _b.x1, _b.y1);
        draw_set_color(_hover ? $3a3a5a : $2a2a2a);
        draw_rectangle(_b.x0, _b.y0, _b.x1, _b.y1, false);
        draw_set_color(_hover ? $00aaff : $555555);
        draw_rectangle(_b.x0, _b.y0, _b.x1, _b.y1, true);
        draw_set_color(c_white);
        draw_text((_b.x0 + _b.x1) / 2, (_b.y0 + _b.y1) / 2, _labels[_i]);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

/// Bottom banner text for the session, or "".
function net_coop_banner() {
    if (!variable_global_exists("net_coop_role")) return "";
    if (is_struct(global.net_coop_accept)) return string_replace(loc("NET_COOP_JOINING"), "{NAME}", global.net_coop_accept.name);
    if (global.net_coop_role != "guest") return "";
    var _host = net_clean_name(tcc_steam_get_user_persona_name_sync(global.net_coop_host));
    switch (global.net_coop_state) {
        case "loading": case "entering": return loc("NET_COOP_DOWNLOADING");
        case "hold": return string_replace(loc("NET_COOP_HOLD"), "{NAME}", _host);
    }
    if (room == r_leveleditor && global.LEMode == 2 && array_length(global.net_coop_queue) > 0) return loc("NET_COOP_WAITING_CHANGES");
    return "";
}

// -----------------------------------------------------------------------------
// Build-together panel (runs in o_coopinvitepanel's scope)
// -----------------------------------------------------------------------------
function net_coop_panel_layout() {
    buttons = [];
    array_push(buttons, net_friends_button(px1 - 44, py0 + 6, px1 - 8, py0 + 38, "X", "close"));
    var _host = global.net_coop_role != "guest";
    // Builders: the creator first, then the guests.
    builders = [];
    if (_host) {
        array_push(builders, {id:global.net_my_steam_id, name:net_clean_name(tcc_steam_get_persona_name()), creator:true, guest:undefined});
        var _key = ds_map_find_first(global.net_coop_guests);
        while (!is_undefined(_key)) {
            var _g = global.net_coop_guests[? _key];
            array_push(builders, {id:_g.id, name:_g.name, creator:false, guest:_g});
            _key = ds_map_find_next(global.net_coop_guests, _key);
        }
    } else {
        array_push(builders, {id:global.net_coop_host, name:net_clean_name(tcc_steam_get_user_persona_name_sync(global.net_coop_host)), creator:true, guest:undefined});
        array_push(builders, {id:global.net_my_steam_id, name:net_clean_name(tcc_steam_get_persona_name()), creator:false, guest:undefined});
    }
    builders_y = py0 + 104;
    for (var _i = 0; _i < array_length(builders); ++_i) {
        var _b = builders[_i];
        if (_host && !_b.creator) array_push(buttons, net_friends_button(px1 - 150, builders_y + _i * 28 - 2, px1 - 20, builders_y + _i * 28 + 22, loc("NET_COOP_REMOVE"), "kick", _b.id));
    }
    friends_y = builders_y + array_length(builders) * 28 + 16;
    list_top = friends_y + 30;
    list_bottom = py1 - 56;
    if (!_host) {
        array_push(buttons, net_friends_button((px0 + px1) / 2 - 100, py1 - 46, (px0 + px1) / 2 + 100, py1 - 12, loc("NET_COOP_LEAVE"), "leave"));
        scroll_max = 0;
        return;
    }
    var _can_invite = global.net_active && global.net_coop_role != "guest" && net_coop_editor_ready();
    var _rows = array_length(friends);
    scroll_max = max(0, _rows * row_h - (list_bottom - list_top));
    for (var _i = 0; _i < _rows; ++_i) {
        var _friend = friends[_i];
        var _ry = list_top + _i * row_h - scroll;
        if (_ry + row_h < list_top || _ry > list_bottom) continue;
        if (ds_map_exists(global.net_coop_guests, string(_friend.id))) continue;
        var _invited = ds_map_exists(global.net_coop_invited, string(_friend.id));
        var _button = net_friends_button(px1 - 170, _ry + 12, px1 - 20, _ry + 44, loc(_invited ? "NET_COOP_INVITE_AGAIN" : "NET_COOP_INVITE"), "invite", _friend, _can_invite);
        _button.clip = true;
        array_push(buttons, _button);
    }
}

function net_coop_panel_action(_button) {
    if (!_button.enabled) return;
    switch (_button.action) {
        case "close": close_requested = true; break;
        case "invite": net_coop_invite(_button.arg.id, _button.arg.name); break;
        case "kick": net_coop_host_kick(_button.arg); break;
        case "leave":
            close_requested = true;
            net_coop_guest_exit("");
            break;
    }
}

function net_coop_panel_draw() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _host = global.net_coop_role != "guest";
    draw_set_alpha(0.85 * overlay_alpha);
    draw_rectangle_color(0, 0, 1024, 768, c_black, c_black, c_black, c_black, false);
    draw_set_alpha(overlay_alpha);
    draw_set_color($1a1a1a);
    draw_rectangle(px0, py0, px1, py1, false);
    draw_set_color($444444);
    draw_rectangle(px0, py0, px1, py1, true);
    draw_set_color($2a2a2a);
    draw_rectangle(px0, py0, px1, py0 + 44, false);
    draw_set_color($00aaff);
    draw_rectangle(px0, py0 + 44, px1, py0 + 46, false);

    draw_set_font(global.deathfont);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text((px0 + px1) / 2, py0 + 10, loc("NET_COOP_TITLE"));
    draw_set_halign(fa_left);
    draw_set_color($aaaaaa);
    var _creator = _host ? "" : net_clean_name(tcc_steam_get_user_persona_name_sync(global.net_coop_host));
    var _about = _host ? loc("NET_COOP_ABOUT_HOST") : string_replace_all(loc("NET_COOP_ABOUT_GUEST"), "{NAME}", _creator);
    draw_text_ext_transformed(px0 + 20, py0 + 54, _about, 22, (px1 - px0 - 40) / 0.65, 0.65, 0.65, 0);

    draw_set_color($00aaff);
    draw_text_transformed(px0 + 20, builders_y - 26, loc("NET_COOP_BUILDERS"), 0.8, 0.8, 0);
    for (var _i = 0; _i < array_length(builders); ++_i) {
        var _b = builders[_i];
        var _line = builders_y + _i * 28;
        net_draw_avatar(_b.id, px0 + 20, _line, 20, overlay_alpha);
        var _cursor = global.net_coop_cursors[? string(_b.id)];
        var _doing = (is_struct(_cursor) && current_time - _cursor.at < 3000 && (_cursor.flags & 1) != 0) ? loc("NET_COOP_PLAYTESTING") : loc("NET_COOP_BUILDING");
        var _text = _b.name + (_b.creator ? " (" + loc("NET_COOP_CREATOR") + ")" : "");
        if (_b.id != global.net_my_steam_id) _text += "  -  " + _doing;
        draw_set_color(c_white);
        draw_text_transformed(px0 + 50, _line + 2, _text, 0.75, 0.75, 0);
    }
    var _hover = net_friends_panel_hover(_mx, _my);
    if (_host) {
        draw_set_color($00aaff);
        draw_text_transformed(px0 + 20, friends_y, loc("NET_FRIENDS_PLAYING"), 0.8, 0.8, 0);
        draw_rectangle(px0 + 16, friends_y + 24, px1 - 16, friends_y + 25, false);
        gpu_set_scissor(px0 + 1, list_top, px1 - px0 - 2, list_bottom - list_top);
        var _steam = platform_steam() && tcc_steam_initialised();
        if (array_length(friends) == 0) {
            draw_set_color($888888);
            draw_set_halign(fa_center);
            draw_text_transformed((px0 + px1) / 2, list_top + 40, _steam ? loc("NET_NO_FRIENDS_PLAYING") : loc("NET_STEAM_REQUIRED"), 0.8, 0.8, 0);
            draw_set_halign(fa_left);
        }
        for (var _i = 0; _i < array_length(friends); ++_i) {
            var _friend = friends[_i];
            var _ry = list_top + _i * row_h - scroll;
            if (_ry + row_h < list_top || _ry > list_bottom) continue;
            net_draw_avatar(_friend.id, px0 + 24, _ry + 8, 40, overlay_alpha);
            draw_set_color(c_white);
            draw_text_transformed(px0 + 76, _ry + 8, _friend.name, 0.9, 0.9, 0);
            var _status = _friend.status == "" ? loc("NET_PLAYING_TCC") : _friend.status;
            if (ds_map_exists(global.net_coop_guests, string(_friend.id))) _status = loc("NET_COOP_BUILDING_WITH_YOU");
            else if (ds_map_exists(global.net_coop_invited, string(_friend.id))) _status = loc("NET_COOP_INVITED_WAITING");
            draw_set_color($aaaaaa);
            draw_text_transformed(px0 + 76, _ry + 30, _status, 0.7, 0.7, 0);
        }
        for (var _i = 0; _i < array_length(buttons); ++_i) if (buttons[_i].clip) net_friends_draw_button(buttons[_i], _hover == _i);
        gpu_set_scissor(-1, -1, -1, -1);
        if (scroll_max > 0) {
            var _track = list_bottom - list_top;
            var _bar = max(24, _track * _track / (_track + scroll_max));
            var _bar_y = list_top + (_track - _bar) * (scroll / scroll_max);
            draw_set_color($555555);
            draw_rectangle(px1 - 8, _bar_y, px1 - 4, _bar_y + _bar, false);
        }
        if (!global.net_active) {
            draw_set_color($888888);
            draw_set_halign(fa_center);
            draw_text_transformed((px0 + px1) / 2, py1 - 40, loc(global.onlinemultiplayersettings == 1 ? "NET_SESSION_STARTING" : "NET_ONLINE_DISABLED"), 0.7, 0.7, 0);
            draw_set_halign(fa_left);
        }
    }
    for (var _i = 0; _i < array_length(buttons); ++_i) if (!buttons[_i].clip) net_friends_draw_button(buttons[_i], _hover == _i);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}
