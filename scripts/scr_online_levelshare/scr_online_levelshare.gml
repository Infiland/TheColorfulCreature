// =============================================================================
// SHARED LEVELS - peer-to-peer transfer of local levels.
//
// Editor play-tests and custom challenge levels exist only on their author's
// machine. Their level.json text is identified by its MD5. A follower requests
// it from the lobby owner, who sends it zlib-compressed in reliable chunks. The
// receiver verifies size, hash and level schema before caching it under
// "Online Levels/<md5>/", where it is played like a Workshop level.
// =============================================================================

#macro NET_SHARE_HEADER			44			// type + md5 + NUL + total + offset + length
#macro NET_SHARE_MAX_COMPRESSED	8388608
#macro NET_SHARE_MAX_TEXT		16777216
#macro NET_SHARE_TIMEOUT_MS		30000
#macro NET_SHARE_CHUNKS_PER_TICK	8

function net_levelshare_init() {
    global.net_share_texts = ds_map_create();	// md5 -> level.json text we can serve
    global.net_share_order = [];
    global.net_share_out = [];					// outgoing transfers
    global.net_share_in = undefined;			// the one incoming transfer
    global.net_share_denied = ds_map_create();	// md5 -> time a request failed
}

function net_levelshare_cleanup() {
    net_levelshare_lobby_reset();
    if (ds_exists(global.net_share_texts, ds_type_map)) ds_map_destroy(global.net_share_texts);
    if (ds_exists(global.net_share_denied, ds_type_map)) ds_map_destroy(global.net_share_denied);
}

// Transfers belong to the lobby they were requested in.
function net_levelshare_lobby_reset() {
    for (var _i = 0; _i < array_length(global.net_share_out); ++_i) {
        if (buffer_exists(global.net_share_out[_i].buffer)) buffer_delete(global.net_share_out[_i].buffer);
    }
    global.net_share_out = [];
    net_levelshare_in_clear();
}

function net_levelshare_in_clear() {
    var _in = global.net_share_in;
    if (is_struct(_in) && _in.buffer != -1 && buffer_exists(_in.buffer)) buffer_delete(_in.buffer);
    global.net_share_in = undefined;
}

function net_levelshare_md5_valid(_md5) {
    if (!is_string(_md5) || string_length(_md5) != 32) return false;
    for (var _i = 1; _i <= 32; ++_i) if (string_pos(string_char_at(_md5, _i), "0123456789abcdef") == 0) return false;
    return true;
}
function net_levelshare_dir(_md5) {
    return string_replace_all(directory_set("/Online Levels/" + _md5 + "/"), "\\", "/");
}
function net_levelshare_ready(_md5) {
    return net_levelshare_md5_valid(_md5) && file_exists(net_levelshare_dir(_md5) + "level.json");
}

/// Make a level.json text available to followers. Returns its MD5.
function net_levelshare_offer(_text) {
    var _md5 = md5_string_utf8(_text);
    if (!ds_map_exists(global.net_share_texts, _md5)) {
        global.net_share_texts[? _md5] = _text;
        array_push(global.net_share_order, _md5);
        // Keep the few most recent levels; older ones are still served from disk cache.
        while (array_length(global.net_share_order) > 4) {
            ds_map_delete(global.net_share_texts, global.net_share_order[0]);
            array_delete(global.net_share_order, 0, 1);
        }
    }
    return _md5;
}

// Read a whole file as text, or undefined.
function net_levelshare_read_text(_filename) {
    if (!file_exists(_filename)) return undefined;
    var _buffer = buffer_load(_filename);
    if (_buffer < 0) return undefined;
    var _size = buffer_get_size(_buffer);
    if (_size > NET_SHARE_MAX_TEXT) { buffer_delete(_buffer); return undefined; }
    var _terminated = buffer_create(_size + 1, buffer_fixed, 1);
    if (_size > 0) buffer_copy(_buffer, 0, _size, _terminated, 0);
    buffer_poke(_terminated, _size, buffer_u8, 0);
    buffer_delete(_buffer);
    buffer_seek(_terminated, buffer_seek_start, 0);
    var _text = buffer_read(_terminated, buffer_string);
    buffer_delete(_terminated);
    return _text;
}

/// Text for an MD5 we can serve: offered levels, or ones we received earlier.
function net_levelshare_text(_md5) {
    if (ds_map_exists(global.net_share_texts, _md5)) return global.net_share_texts[? _md5];
    if (!net_levelshare_ready(_md5)) return undefined;
    var _text = net_levelshare_read_text(net_levelshare_dir(_md5) + "level.json");
    if (is_undefined(_text) || md5_string_utf8(_text) != _md5) return undefined;
    return _text;
}

/// Ask a peer for a level. Returns false when it cannot be requested.
function net_levelshare_request(_md5, _peer) {
    if (!global.net_active || !net_levelshare_md5_valid(_md5)) return false;
    if (ds_map_exists(global.net_share_denied, _md5) && current_time - global.net_share_denied[? _md5] < 60000) return false;
    var _in = global.net_share_in;
    if (is_struct(_in) && _in.md5 == _md5) return true;
    if (_peer == 0 || _peer == global.net_my_steam_id || !net_lobby_member(_peer)) return false;
    net_levelshare_in_clear();
    global.net_share_in = {md5:_md5, peer:_peer, total:0, received:0, buffer:-1, deadline:current_time + NET_SHARE_TIMEOUT_MS};
    var _buffer = global.net_send_buffer;
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, NET_PACKET_LEVEL_REQUEST);
    buffer_write(_buffer, buffer_string, _md5);
    net_send_to(_peer, buffer_tell(_buffer), true);
    return true;
}

function net_levelshare_send_deny(_peer, _md5) {
    var _buffer = global.net_send_buffer;
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, NET_PACKET_LEVEL_DENY);
    buffer_write(_buffer, buffer_string, _md5);
    net_send_to(_peer, buffer_tell(_buffer), true);
}

function net_levelshare_serve(_peer, _md5) {
    for (var _i = 0; _i < array_length(global.net_share_out); ++_i) {
        var _out = global.net_share_out[_i];
        if (_out.peer == _peer && _out.md5 == _md5) return;	// already sending
    }
    var _text = array_length(global.net_share_out) < 8 ? net_levelshare_text(_md5) : undefined;
    if (is_undefined(_text)) { net_levelshare_send_deny(_peer, _md5); return; }
    var _length = string_byte_length(_text);
    var _raw = buffer_create(max(1, _length), buffer_fixed, 1);
    buffer_write(_raw, buffer_text, _text);
    var _compressed = buffer_compress(_raw, 0, _length);
    buffer_delete(_raw);
    if (_compressed < 0 || buffer_get_size(_compressed) > NET_SHARE_MAX_COMPRESSED) {
        if (_compressed >= 0) buffer_delete(_compressed);
        net_levelshare_send_deny(_peer, _md5);
        return;
    }
    array_push(global.net_share_out, {peer:_peer, md5:_md5, buffer:_compressed, size:buffer_get_size(_compressed), offset:0});
}

/// Pump outgoing chunks and expire a stalled download.
function net_levelshare_tick() {
    for (var _i = array_length(global.net_share_out) - 1; _i >= 0; --_i) {
        var _out = global.net_share_out[_i];
        var _done = !net_lobby_member(_out.peer);
        for (var _n = 0; _n < NET_SHARE_CHUNKS_PER_TICK && !_done; ++_n) {
            var _length = min(NET_CHUNK_DATA_SIZE, _out.size - _out.offset);
            var _buffer = global.net_send_buffer;
            if (buffer_get_size(_buffer) < NET_SHARE_HEADER + _length) buffer_resize(_buffer, NET_SHARE_HEADER + _length);
            buffer_seek(_buffer, buffer_seek_start, 0);
            buffer_write(_buffer, buffer_u8, NET_PACKET_LEVEL_CHUNK);
            buffer_write(_buffer, buffer_string, _out.md5);
            buffer_write(_buffer, buffer_u32, _out.size);
            buffer_write(_buffer, buffer_u32, _out.offset);
            buffer_write(_buffer, buffer_u16, _length);
            if (_length > 0) buffer_copy(_out.buffer, _out.offset, _length, _buffer, NET_SHARE_HEADER);
            // A full reliable queue refuses the chunk: resend the same one next tick.
            if (!net_send_to(_out.peer, NET_SHARE_HEADER + _length, true)) break;
            _out.offset += _length;
            if (_out.offset >= _out.size) _done = true;
        }
        if (_done) {
            if (buffer_exists(_out.buffer)) buffer_delete(_out.buffer);
            array_delete(global.net_share_out, _i, 1);
        }
    }
    var _in = global.net_share_in;
    if (is_struct(_in) && current_time > _in.deadline) {
        global.net_share_denied[? _in.md5] = current_time;
        net_levelshare_in_clear();
    }
}

function net_levelshare_receive(_sender, _type, _buffer, _size) {
    var _md5_end = net_packet_string_end(_buffer, 1, _size, 32);
    if (_md5_end != 33) return;
    var _md5 = buffer_peek(_buffer, 1, buffer_string);
    if (!net_levelshare_md5_valid(_md5)) return;
    switch (_type) {
        case NET_PACKET_LEVEL_REQUEST:
            if (_size == 34) net_levelshare_serve(_sender, _md5);
            break;
        case NET_PACKET_LEVEL_DENY:
            var _denied = global.net_share_in;
            if (_size == 34 && is_struct(_denied) && _denied.md5 == _md5 && _denied.peer == _sender) {
                global.net_share_denied[? _md5] = current_time;
                net_levelshare_in_clear();
            }
            break;
        case NET_PACKET_LEVEL_CHUNK:
            var _in = global.net_share_in;
            if (!is_struct(_in) || _in.md5 != _md5 || _in.peer != _sender || _size < NET_SHARE_HEADER) break;
            var _total = buffer_peek(_buffer, 34, buffer_u32);
            var _offset = buffer_peek(_buffer, 38, buffer_u32);
            var _length = buffer_peek(_buffer, 42, buffer_u16);
            // Reliable P2P delivery is ordered: anything else is a broken stream.
            if (_length > NET_CHUNK_DATA_SIZE || NET_SHARE_HEADER + _length != _size || _total < 1
                || _total > NET_SHARE_MAX_COMPRESSED || _offset != _in.received || _offset + _length > _total
                || (_in.buffer != -1 && _total != _in.total)) {
                global.net_share_denied[? _md5] = current_time;
                net_levelshare_in_clear();
                break;
            }
            if (_in.buffer == -1) {
                _in.total = _total;
                _in.buffer = buffer_create(_total, buffer_fixed, 1);
            }
            if (_length > 0) buffer_copy(_buffer, NET_SHARE_HEADER, _length, _in.buffer, _offset);
            _in.received += _length;
            _in.deadline = current_time + NET_SHARE_TIMEOUT_MS;
            if (_in.received >= _in.total) net_levelshare_finish();
            break;
    }
}

/// Verify and cache a completed download.
function net_levelshare_finish() {
    var _in = global.net_share_in;
    var _md5 = _in.md5;
    var _raw = buffer_decompress(_in.buffer);
    net_levelshare_in_clear();
    var _ok = false;
    if (_raw >= 0) {
        var _size = buffer_get_size(_raw);
        if (_size > 0 && _size <= NET_SHARE_MAX_TEXT && buffer_md5(_raw, 0, _size) == _md5) {
            var _directory = net_levelshare_dir(_md5);
            if (!directory_exists(_directory)) directory_create(_directory);
            var _pending = _directory + "level.json.pending";
            buffer_save_ext(_raw, _pending, 0, _size);
            var _document = level_parse_json_file(_pending);
            if (!is_undefined(_document) && level_validate(_document).valid) {
                if (file_exists(_directory + "level.json")) file_delete(_directory + "level.json");
                file_rename(_pending, _directory + "level.json");
                _ok = file_exists(_directory + "level.json");
            }
            if (file_exists(_pending)) file_delete(_pending);
        }
        buffer_delete(_raw);
    }
    if (!_ok) {
        global.net_share_denied[? _md5] = current_time;
        show_debug_message("[NET] Shared level " + _md5 + " failed verification");
    }
}
