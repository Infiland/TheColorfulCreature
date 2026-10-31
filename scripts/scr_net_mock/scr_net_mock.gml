// =============================================================================
// NETWORKING TEST MOCK (Check configuration only)
//
// Steam-free stand-in for the raw networking natives. The wrappers in scr_steam_safe consult
// global.tcc_net_mock before their readiness guard, so the real net layer (argument hygiene,
// clamping, result mapping, the classifier, every net_* function) runs against it unchanged.
// It is installed and removed by scr_online_transport_selfcheck and is never reachable in a
// shipped build, where TCC_SELF_CHECK is the literal false.
// =============================================================================

function net_test_hex(_buffer, _offset, _count) {
    static _digits = "0123456789abcdef";
    var _out = "";
    for (var _i = 0; _i < _count; ++_i) {
        var _b = buffer_peek(_buffer, _offset + _i, buffer_u8);
        _out += string_char_at(_digits, (_b >> 4) + 1) + string_char_at(_digits, (_b & 15) + 1);
    }
    return _out;
}

/// Fixed buffer holding the bytes of a lower-case hex string. The caller deletes it.
function net_test_from_hex(_hex) {
    static _digits = "0123456789abcdef";
    var _n = string_length(_hex) div 2;
    var _buffer = buffer_create(_n, buffer_fixed, 1);
    for (var _i = 0; _i < _n; ++_i) {
        var _hi = string_pos(string_char_at(_hex, _i * 2 + 1), _digits) - 1;
        var _lo = string_pos(string_char_at(_hex, _i * 2 + 2), _digits) - 1;
        buffer_poke(_buffer, _i, buffer_u8, _hi * 16 + _lo);
    }
    return _buffer;
}

/// Models ISteamNetworkingMessages behind the tcc_steam_net_* wrappers. Quirks reproduced from the native (each cited):
/// payload written at offset 0, never grown, overflow releases that and every later fetched message and sets the error text (NAT:195-201);
/// send results 1/25/3/8/2/undefined (NAT:116-157); a per-peer queue model that yields 25 organically; NoConnection after a peer-closed
/// session unless AutoRestartBrokenSession is in the flags; implicit accept on send; session requests posted for unaccepted senders and
/// re-posted on demand; unaccepted-sender policy "hold" or "drop" (the real behaviour is unverified, tests run both); deferred callbacks.
function TccNetMock(_my_id) constructor {
    my_id = _my_id;
    members = [_my_id];             // lobby seam; includes our own id exactly like the real member list
    owner = _my_id;
    inbox = [];                     // [{from, buf, size, held}]
    send_log = [];                  // [{user, count, offset, channel, flags, result, hex}]
    receive_log = [];               // [{channel, count}]
    accept_log = [];
    close_log = [];
    results = [];                   // scripted send results, consumed first; may contain undefined
    default_result = 1;
    cap = 524288;                   // per-peer send queue model (SendBufferSize default)
    queued = {};                    // string(user) -> queued bytes
    accepted = {};
    requested = {};
    closed_by_peer = {};
    policy_unaccepted = "hold";     // "hold" | "drop"
    error_text = "";
    request_cb = undefined;
    failed_cb = undefined;
    pending_callbacks = [];
    refresh_calls = 0;              // number of times the lobby seam was asked for the member count = net_refresh_members() calls
    max_native_count = 0;           // largest `count` ever passed to receive; must stay 1
    offset_bias = 0;                // added to the offset reported for every fetched message (0 = the native's behaviour for count 1)

    last_error = function() { return error_text; };
    lobby_member_count = function() { refresh_calls += 1; return array_length(members); };
    lobby_member_id = function(_index) { return (_index >= 0 && _index < array_length(members)) ? members[_index] : int64(0); };
    lobby_owner_id = function() { return owner; };

    send = function(_user, _buffer, _flags, _channel, _offset, _count) {
        var _length = buffer_get_size(_buffer);
        var _key = string(_user);
        var _result = default_result;
        if (_offset >= _length || _count == 0 || _offset + _count > _length) {
            _result = 8;
        } else if (variable_struct_exists(closed_by_peer, _key) && (_flags & 32) == 0) {
            _result = 3;
        } else if (array_length(results) > 0) {
            _result = results[0];
            array_delete(results, 0, 1);
        } else {
            var _q = variable_struct_exists(queued, _key) ? queued[$ _key] : 0;
            if (_q + _count > cap) _result = 25; else queued[$ _key] = _q + _count;
        }
        if (is_numeric(_result) && _result == 1) {
            accepted[$ _key] = true;                        // sending implicitly accepts
            variable_struct_remove(closed_by_peer, _key);   // and AutoRestartBrokenSession reopens a dead session
        }
        array_push(send_log, {user:_user, count:_count, offset:_offset, channel:_channel, flags:_flags, result:_result,
            hex:net_test_hex(_buffer, _offset, min(_count, _length - _offset))});
        return _result;
    };

    receive = function(_channel, _out, _count) {
        array_push(receive_log, {channel:_channel, count:_count});
        max_native_count = max(max_native_count, _count);
        error_text = "";
        var _fetched = [];
        var _picked = [];
        for (var _i = 0; _i < array_length(inbox) && array_length(_fetched) < _count; ++_i) {
            if (!inbox[_i].held) { array_push(_fetched, inbox[_i]); array_push(_picked, _i); }
        }
        for (var _f = array_length(_picked) - 1; _f >= 0; --_f) array_delete(inbox, _picked[_f], 1);   // fetched messages leave the queue even if they do not fit
        var _result = [];
        var _offset = 0;
        var _capacity = buffer_get_size(_out);
        for (var _m = 0; _m < array_length(_fetched); ++_m) {
            var _msg = _fetched[_m];
            if (_offset + _msg.size > _capacity) {
                error_text = "mock: output buffer exhausted.";
                for (var _k = _m; _k < array_length(_fetched); ++_k) buffer_delete(_fetched[_k].buf);   // this and every later fetched message
                break;
            }
            buffer_copy(_msg.buf, 0, _msg.size, _out, _offset);
            var _info = new SteamNetworkingMessage();
            _info.offset = _offset + offset_bias;
            _info.size = _msg.size;
            _info.steam_id_remote = _msg.from;
            _info.conn = 0;
            _info.channel = _channel;
            _info.flags = 0;
            array_push(_result, _info);
            _offset += _msg.size;
            buffer_delete(_msg.buf);
        }
        return _result;
    };

    accept = function(_user) {
        var _key = string(_user);
        array_push(accept_log, _user);
        var _known = variable_struct_exists(accepted, _key) || variable_struct_exists(requested, _key);
        accepted[$ _key] = true;
        for (var _i = 0; _i < array_length(inbox); ++_i) if (inbox[_i].from == _user) inbox[_i].held = false;
        return _known;
    };
    close = function(_user) {
        array_push(close_log, _user);
        variable_struct_remove(accepted, string(_user));
        return true;
    };

    post_request = function(_from) {
        requested[$ string(_from)] = true;
        if (!is_callable(request_cb)) return;
        var _r = new SteamNetworkingMessagesSessionRequest();
        _r.steam_id_remote = _from;
        array_push(pending_callbacks, {cb:request_cb, arg:_r});
    };
    /// A message from _from arrives (copied from _source[0 .. _size)). Unaccepted senders post a session request.
    inject = function(_from, _source, _size) {
        var _ok = variable_struct_exists(accepted, string(_from));
        if (!_ok) post_request(_from);
        if (!_ok && policy_unaccepted == "drop") return;
        var _copy = buffer_create(_size, buffer_fixed, 1);
        buffer_copy(_source, 0, _size, _copy, 0);
        array_push(inbox, {from:_from, buf:_copy, size:_size, held:!_ok});
    };
    inject_hex = function(_from, _hex) {
        var _b = net_test_from_hex(_hex);
        inject(_from, _b, buffer_get_size(_b));
        buffer_delete(_b);
    };
    set_session_request_callback = function(_cb) { request_cb = _cb; return true; };
    set_session_failed_callback = function(_cb) { failed_cb = _cb; return true; };
    fire_session_request = function(_id) {                    // queued like the native does; runs only in pump()
        var _r = new SteamNetworkingMessagesSessionRequest();
        _r.steam_id_remote = _id;
        array_push(pending_callbacks, {cb:request_cb, arg:_r});
    };
    fire_session_failed = function(_id, _reason, _text) {
        var _r = new SteamNetworkingMessagesSessionFailed();
        _r.steam_id_remote = _id;
        _r.end_reason = _reason;
        _r.debug_msg = _text;
        array_push(pending_callbacks, {cb:failed_cb, arg:_r});
    };
    /// One "time-source tick": runs every queued callback the way the dispatcher does (EXT:350): with a shared empty `self`.
    /// Returns the number of queued callbacks.
    pump = function() {
        var _list = pending_callbacks;
        pending_callbacks = [];
        for (var _i = 0; _i < array_length(_list); ++_i) {
            var _cb = _list[_i].cb;
            var _arg = _list[_i].arg;
            if (is_callable(_cb)) with ({}) method_call(_cb, [_arg]);
        }
        return array_length(_list);
    };
    drain = function() { queued = {}; };
    free = function() {
        for (var _i = 0; _i < array_length(inbox); ++_i) if (buffer_exists(inbox[_i].buf)) buffer_delete(inbox[_i].buf);
        inbox = [];
    };
}
