// =============================================================================
// ONLINE TRANSPORT SELF-CHECK (Check configuration, no Steam)
//
// All online state is made of global singletons, so the REAL net layer acts as the only node and
// every remote peer is a script that feeds bytes into the mock (scr_net_mock) and reads what the
// node sent. The mock sits inside the tcc_steam_net_* wrappers and the three lobby read wrappers;
// argument hygiene, clamping, result mapping, the receive classifier and every net_* function run
// for real. Protocol writers and decoders are pure functions, so round trips cover the remote half.
//
// net_tick itself is not driven (it returns at its Steam guard here); the tests call the pieces it
// calls. Time is driven through _now parameters and by writing fields (last_update, progress_at),
// never by sleeping; "a new tick" is global.net_refresh_forced_tick = -1.
// =============================================================================

// Golden protocol 3 vectors (little endian), recomputed from the writers' layouts.
#macro NET_TEST_STATE   "1007000000c0420000004307ffffff000000803f0000803f000000000000803f03725f6c766c3100725f6c766c310000010200008040000040c00000"
#macro NET_TEST_HELLO   "110300506c61796572000000000000c05e400000"
#macro NET_TEST_PING    "130d0c0b0a725f6c766c3100725f6c766c310000"
#macro NET_TEST_PONG    "1404030201"
#macro NET_TEST_REQUEST "16303132333435363738396162636465663031323334353637383961626364656600"

// Ids above 2^53 must be built from strings: a numeric literal would already be a rounded double.
function net_test_ids() {
    return [int64("76561198000000001"), int64("76561198000000002"), int64("76561198000000003"), int64("76561198999999999")];
}
function net_test_state() {
    return {seq:7, x:96, y:128, image_index:7, image_blend:c_white, image_xscale:1, image_yscale:1, image_angle:0, image_alpha:1,
        color:3, room_name:"r_lvl1", level_key:"r_lvl1", skin:0, hat:1, item:2, hsp:4, vsp:-3, is_dead:0, zerogrv:0};
}
function net_test_last(_mock) {
    return _mock.send_log[array_length(_mock.send_log) - 1];
}
/// First byte of a lower-case hex string.
function net_test_type(_hex) {
    static _digits = "0123456789abcdef";
    return (string_pos(string_char_at(_hex, 1), _digits) - 1) * 16 + string_pos(string_char_at(_hex, 2), _digits) - 1;
}
/// A LEVEL_CHUNK packet as a fixed buffer: the header, then _length payload bytes where byte i of the stream is (_offset + i) mod 251.
function net_test_chunk(_md5, _total, _offset, _length) {
    var _packet = buffer_create(NET_SHARE_HEADER + _length, buffer_fixed, 1);
    buffer_seek(_packet, buffer_seek_start, 0);
    buffer_write(_packet, buffer_u8, NET_PACKET_LEVEL_CHUNK);
    buffer_write(_packet, buffer_string, _md5);
    buffer_write(_packet, buffer_u32, _total);
    buffer_write(_packet, buffer_u32, _offset);
    buffer_write(_packet, buffer_u16, _length);
    for (var _i = 0; _i < _length; ++_i) buffer_poke(_packet, NET_SHARE_HEADER + _i, buffer_u8, (_offset + _i) mod 251);
    return _packet;
}
/// "" when every logged send used the flags its packet type requires on channel 0 at offset 0:
/// reliable 41 for control and level traffic, unreliable 33 for ghost traffic (STATE, PING, PONG). Never NoDelay.
function net_test_flags_problem(_mock) {
    for (var _i = 0; _i < array_length(_mock.send_log); ++_i) {
        var _entry = _mock.send_log[_i];
        var _type = net_test_type(_entry.hex);
        var _expected = (_type == NET_PACKET_STATE || _type == NET_PACKET_PING || _type == NET_PACKET_PONG) ? 33 : 41;
        if (_entry.flags != _expected || (_entry.flags & 4) != 0 || _entry.channel != 0 || _entry.offset != 0)
            return "send " + string(_i) + " of packet type " + string(_type) + " used flags " + string(_entry.flags);
    }
    return "";
}

function net_test_begin(_my_id, _others) {
    timing_boot();                                   // as scr_confirmation_modal_selfcheck does; timing_tick_id() needs a clock
    // net_write_hello reads the equipped cosmetics; the self-check can start before the customizables are loaded
    if (!variable_global_exists("skinselected")) global.skinselected = 0;
    if (!variable_global_exists("hatselected")) global.hatselected = 0;
    net_init();                                      // Steam-free
    var _mock = new TccNetMock(_my_id);
    for (var _i = 0; _i < array_length(_others); ++_i) array_push(_mock.members, _others[_i]);
    global.tcc_net_mock = _mock;
    global.net_my_steam_id = _my_id;
    global.net_active = true;
    global.net_is_host = false;
    global.net_lobby_id = int64("109775240000000001");
    global.net_refresh_forced_tick = -1;
    net_refresh_members();
    _mock.refresh_calls = 0;
    net_register_steam_callbacks();                  // goes through the mock: stores the two USER callbacks
    return _mock;
}
function net_test_end() {
    if (variable_global_exists("tcc_net_mock") && is_struct(global.tcc_net_mock)) global.tcc_net_mock.free();
    global.tcc_net_mock = undefined;
    net_reset_lobby_state();
    global.net_my_steam_id = int64(0);
    global.net_active = false;
}

function scr_online_transport_selfcheck() {
    scr_port_assert(!tcc_steam_ready(), "transport self-check expects an inert Steam layer (Check configuration)");
    net_test_fixtures();
    net_test_classify();
    net_test_send_args();
    net_test_send_types();
    net_test_receive_isolation();
    net_test_receive_chunks();
    net_test_receive_membership();
    net_test_receive_replies();
    net_test_budget();
    net_test_accept();
    net_test_accept_policy();
    net_test_session_events();
    net_test_outbox();
    net_test_leave();
    net_test_peer_loss();
    net_test_level_share();
    net_test_level_stall();
    net_test_host_name();
    net_test_inert();
    show_debug_message("TCC_ONLINE_TRANSPORT_SELF_CHECK_PASS");
}

/// T-I1 and the decoder half of T-W1: fixture ids are exact int64 values, and every decoder accepts its golden vector
/// and rejects it truncated at every shorter length.
function net_test_fixtures() {
    var _ids = net_test_ids();
    scr_port_assert(_ids[0] != _ids[1] && _ids[1] != _ids[2] && _ids[2] != _ids[3],
        "fixture ids stay distinct: int64() of a 17 digit string must not round through a double");
    scr_port_assert(is_int64(_ids[0]) && string(_ids[0]) == "76561198000000001" && string(_ids[3]) == "76561198999999999"
        && string_length(string(_ids[0])) == 17, "fixture ids are exact 17 digit int64 values");

    var _buffer = net_test_from_hex(NET_TEST_STATE);
    var _size = buffer_get_size(_buffer);
    var _state = net_decode_state(_buffer, _size);
    scr_port_assert(_size == 60 && !is_undefined(_state) && _state.x == 96 && _state.y == 128 && _state.hat == 1 && _state.item == 2,
        "golden STATE vector decodes");
    for (var _n = 0; _n < _size; ++_n)
        scr_port_assert(is_undefined(net_decode_state(_buffer, _n)), "golden STATE vector cut to " + string(_n) + " bytes is rejected");
    buffer_delete(_buffer);

    _buffer = net_test_from_hex(NET_TEST_HELLO);
    _size = buffer_get_size(_buffer);
    var _hello = net_decode_hello(_buffer, _size);
    scr_port_assert(_size == 20 && !is_undefined(_hello) && _hello.username == "Player" && _hello.join_time == 123 && !_hello.reply,
        "golden HELLO vector decodes");
    for (var _n = 0; _n < _size; ++_n)
        scr_port_assert(is_undefined(net_decode_hello(_buffer, _n)), "golden HELLO vector cut to " + string(_n) + " bytes is rejected");
    buffer_delete(_buffer);

    _buffer = net_test_from_hex(NET_TEST_PING);
    _size = buffer_get_size(_buffer);
    var _ping = net_decode_ping(_buffer, _size);
    scr_port_assert(_size == 20 && !is_undefined(_ping) && _ping.stamp == $0A0B0C0D && _ping.room_name == "r_lvl1"
        && _ping.level_key == "r_lvl1" && _ping.sid == "", "golden PING vector decodes");
    for (var _n = 0; _n < _size; ++_n)
        scr_port_assert(is_undefined(net_decode_ping(_buffer, _n)), "golden PING vector cut to " + string(_n) + " bytes is rejected");
    buffer_delete(_buffer);
}

function net_test_classify() {
    var _m = new SteamNetworkingMessage();
    _m.size = 77;
    var _got = tcc_steam_net_classify([_m], "");
    scr_port_assert(is_struct(_got) && _got.size == 77, "classify: a message is returned");
    scr_port_assert(tcc_steam_net_classify([], "x: output buffer exhausted.") == TCC_NET_RX_DROPPED, "classify: exhaustion is a consumed message");
    scr_port_assert(is_undefined(tcc_steam_net_classify([], "")), "classify: empty queue");
    scr_port_assert(is_undefined(tcc_steam_net_classify([], "Steam API not initialized")), "classify: Steam not ready is not exhaustion");
    scr_port_assert(is_undefined(tcc_steam_net_classify(undefined, "")), "classify: extension missing");
}

/// T-S1, T-S3, T-S4, T-S5: native arguments of a send, the result taxonomy, who may be sent to.
function net_test_send_args() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    buffer_resize(global.net_send_buffer, 8236);                      // grown buffer with a stale tail (L:168)
    var _size = net_write_state(global.net_send_buffer, net_test_state());
    scr_port_assert(_size == 60, "golden STATE fixture is 60 bytes");
    scr_port_assert(net_send_to(_ids[1], _size, false), "unreliable send to a member succeeds");
    var _sent = _mock.send_log[0];
    scr_port_assert(_sent.count == 60 && _sent.offset == 0 && _sent.channel == 0 && _sent.flags == 33, "STATE: offset 0, count = packet size, channel 0, flags 33");
    scr_port_assert(_sent.hex == NET_TEST_STATE, "STATE bytes equal the golden vector");
    scr_port_assert(!net_send_to(_ids[0], _size, false) && !net_send_to(_ids[3], _size, false) && array_length(_mock.send_log) == 1,
        "own id and non-members are refused without a native call");
    _mock.results = [25];
    scr_port_assert(!net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.LimitExceeded,
        "LimitExceeded is false, and the reason is available");
    _mock.results = [undefined];
    scr_port_assert(!net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.Fail, "undefined maps to Fail, no exception");
    _mock.results = [3];
    scr_port_assert(!net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.NoConnection, "NoConnection is false, and the reason is available");
    _mock.results = [8];
    scr_port_assert(!net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.InvalidParam, "InvalidParam from the native is false, and the reason is available");
    scr_port_assert(net_send_to(_ids[1], _size, false) && tcc_steam_net_last_send_result() == SteamApiResult.Ok, "Ok is the only true");
    scr_port_assert(!tcc_steam_net_packet_send(_ids[1], global.net_send_buffer, 0) && tcc_steam_net_last_send_result() == SteamApiResult.InvalidParam,
        "size 0 is refused before the native");
    scr_port_assert(!tcc_steam_net_packet_send(_ids[1], -1, 5) && !tcc_steam_net_packet_send(undefined, global.net_send_buffer, 5),
        "bad buffer / bad id are refused without show_error");
    // a session the peer closed refuses plain sends (flags 8 = reliable without AutoRestartBrokenSession); the project's flags reopen it
    _mock.closed_by_peer[$ string(_ids[1])] = true;
    scr_port_assert(!tcc_steam_net_packet_send(_ids[1], global.net_send_buffer, _size, 8) && tcc_steam_net_last_send_result() == SteamApiResult.NoConnection,
        "a session closed by the peer refuses a send without AutoRestartBrokenSession");
    scr_port_assert(net_send_to(_ids[1], _size, false) && !variable_struct_exists(_mock.closed_by_peer, string(_ids[1])),
        "the project's flags reopen a session the peer closed");
    net_send_hello(_ids[1], true);
    net_send_bye();
    var _n = array_length(_mock.send_log);
    scr_port_assert(_mock.send_log[_n - 2].flags == 41 && _mock.send_log[_n - 1].flags == 41 && _mock.send_log[_n - 1].hex == "12", "HELLO and BYE: flags 41; BYE is one byte 0x12");
    net_test_end();
}

/// T-S2 and the encoder half of T-W1: every packet type through its real sender, flags per type, golden bytes.
function net_test_send_types() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[1])] = true;
    var _peer = _ids[1];
    var _md5 = "0123456789abcdef0123456789abcdef";
    var _saved_time = global.net_join_time;
    var _saved_skin = global.skinselected;
    var _saved_hat = global.hatselected;
    // HELLO: with an empty persona name and join time 123 it equals the golden vector minus the name "Player"
    global.net_join_time = 123;
    global.skinselected = 0;
    global.hatselected = 0;
    net_send_hello(_peer, false);
    var _hello = net_test_last(_mock);
    var _expected_hello = string_copy(NET_TEST_HELLO, 1, 6) + string_copy(NET_TEST_HELLO, 19, string_length(NET_TEST_HELLO) - 18);
    scr_port_assert(_hello.hex == _expected_hello, "HELLO bytes equal the golden vector (empty name)");
    global.net_join_time = _saved_time;
    global.skinselected = _saved_skin;
    global.hatselected = _saved_hat;
    net_send_hello(-1, true);                                         // broadcast form
    scr_port_assert(string_copy(net_test_last(_mock).hex, 1, 6) == "110301", "HELLO reply flag is carried");
    net_send_bye();
    scr_port_assert(net_test_last(_mock).hex == "12", "BYE is one byte 0x12");
    global.net_ping_at = 0;
    net_send_ping();
    scr_port_assert(net_test_type(net_test_last(_mock).hex) == NET_PACKET_PING, "PING is sent by the keepalive");
    global.net_ping_at = 0;
    // PONG: answered inside the receive path
    _mock.inject_hex(_peer, NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(net_test_last(_mock).hex == "140d0c0b0a", "PONG echoes the PING stamp");
    // ER_PICKS
    var _saved_sid = global.net_session_sid;
    global.net_session_sid = "s1";
    global.net_er_picks[? "1"] = "r_lvl1";
    net_er_send_picks(_peer, 1, 1);
    ds_map_delete(global.net_er_picks, "1");
    global.net_session_sid = _saved_sid;
    scr_port_assert(net_test_last(_mock).hex == "157331000101000000725f6c766c3100", "ER_PICKS bytes equal the layout (sid s1, one pick)");
    // level REQUEST and DENY
    ds_map_delete(global.net_share_denied, _md5);
    scr_port_assert(net_levelshare_request(_md5, _peer), "a level request is issued");
    scr_port_assert(net_test_last(_mock).hex == NET_TEST_REQUEST, "REQUEST bytes equal the golden vector");
    net_levelshare_send_deny(_peer, _md5);
    scr_port_assert(net_test_last(_mock).hex == "18" + string_copy(NET_TEST_REQUEST, 3, string_length(NET_TEST_REQUEST) - 2), "DENY bytes equal the golden layout");
    var _problem = net_test_flags_problem(_mock);
    scr_port_assert(_problem == "", "flags per packet type: " + _problem);
    net_test_end();
}

function net_test_receive_isolation() {
    var _ids = net_test_ids();
    // Run twice: with the production buffer, and with a 2048-byte buffer that forces the "output buffer exhausted" path.
    for (var _pass = 0; _pass < 2; ++_pass) {
        var _mock = net_test_begin(_ids[0], [_ids[1], _ids[2], _ids[3]]);
        scr_port_assert(buffer_get_size(global.net_recv_buffer) == NET_RECV_BUFFER_BYTES, "production receive buffer is 524288 bytes");
        var _production = global.net_recv_buffer;
        var _small = -1;
        if (_pass == 1) { _small = buffer_create(2048, buffer_fixed, 1); global.net_recv_buffer = _small; }
        _mock.accepted[$ string(_ids[1])] = true; _mock.accepted[$ string(_ids[2])] = true; _mock.accepted[$ string(_ids[3])] = true;
        var _garbage = buffer_create(9000, buffer_fixed, 1);
        buffer_poke(_garbage, 0, buffer_u8, 16);
        _mock.inject_hex(_ids[1], NET_TEST_STATE);
        _mock.inject(_ids[2], _garbage, 9000);
        _mock.inject_hex(_ids[3], NET_TEST_PING);
        net_receive_packets();
        scr_port_assert(ds_map_exists(global.net_players, string(_ids[1])), "valid STATE before the oversized message is processed");
        scr_port_assert(ds_map_exists(global.net_players, string(_ids[3])), "valid PING after the oversized message is processed in the SAME tick");
        scr_port_assert(array_length(_mock.inbox) == 0 && _mock.max_native_count == 1, "queue drained; native count was always 1");
        var _last = _mock.send_log[array_length(_mock.send_log) - 1];
        scr_port_assert(string_copy(_last.hex, 1, 2) == "14" && _last.flags == 33, "the PING was answered with an unreliable PONG");
        buffer_delete(_garbage);
        if (_pass == 1) { buffer_delete(_small); global.net_recv_buffer = _production; }
        net_test_end();
    }
}

/// T-R3 and T-R7: chunk-sized messages through the production buffer, a hostile oversized one, and the sender / offset guards.
function net_test_receive_chunks() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[1])] = true;
    global.net_ids_checked = true;                                    // the one-time id log belongs to the first real message
    var _md5 = "0123456789abcdef0123456789abcdef";
    ds_map_delete(global.net_share_denied, _md5);
    scr_port_assert(net_levelshare_request(_md5, _ids[1]), "chunk test: the download is requested");
    // an 8236 byte LEVEL_CHUNK reaches the reader whole
    var _first = net_test_chunk(_md5, 8292, 0, 8192);
    scr_port_assert(buffer_get_size(_first) == 8236, "a full chunk packet is 8236 bytes");
    _mock.inject(_ids[1], _first, 8236);
    buffer_delete(_first);
    net_receive_packets();
    var _in = global.net_share_in;
    scr_port_assert(is_struct(_in) && _in.received == 8192 && _in.buffer != -1, "the first chunk is accepted");
    scr_port_assert(buffer_peek(_in.buffer, 0, buffer_u8) == 0 && buffer_peek(_in.buffer, 8191, buffer_u8) == 8191 mod 251,
        "the chunk payload arrived whole and starts at the right offset");
    // the last chunk completes the stream; the bytes are not the announced level, so the hash check refuses it (no file is written)
    var _second = net_test_chunk(_md5, 8292, 8192, 100);
    _mock.inject(_ids[1], _second, buffer_get_size(_second));
    buffer_delete(_second);
    net_receive_packets();
    scr_port_assert(is_undefined(global.net_share_in) && ds_map_exists(global.net_share_denied, _md5), "a completed stream is verified; a wrong hash is refused and remembered");
    ds_map_delete(global.net_share_denied, _md5);
    // a 600000 byte message cannot fit the buffer: consumed and dropped, the next message still arrives
    var _dropped = global.net_session_stats.rx_dropped;
    var _huge = buffer_create(600000, buffer_fixed, 1);
    buffer_poke(_huge, 0, buffer_u8, NET_PACKET_LEVEL_CHUNK);
    _mock.inject(_ids[1], _huge, 600000);
    buffer_delete(_huge);
    _mock.inject_hex(_ids[1], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(global.net_session_stats.rx_dropped == _dropped + 1 && ds_map_exists(global.net_players, string(_ids[1])) && array_length(_mock.inbox) == 0,
        "an oversized message is consumed and counted; the loop ends normally");
    // a message that does not start at offset 0, and one from sender 0, are counted and ignored
    ds_map_clear(global.net_players);
    _dropped = global.net_session_stats.rx_dropped;
    _mock.offset_bias = 5;
    _mock.inject_hex(_ids[1], NET_TEST_PING);
    net_receive_packets();
    _mock.offset_bias = 0;
    scr_port_assert(global.net_session_stats.rx_dropped == _dropped + 1 && !ds_map_exists(global.net_players, string(_ids[1])), "a message with offset != 0 is dropped and counted");
    _mock.accepted[$ "0"] = true;
    _mock.inject_hex(int64(0), NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(global.net_session_stats.rx_dropped == _dropped + 2 && ds_map_size(global.net_players) == 0, "a message from sender 0 is dropped and counted");
    net_test_end();
}

/// T-R4: the first half. A stranger earns one forced refresh per tick; a newcomer the membership cache has not seen yet is admitted by it.
function net_test_receive_membership() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[2])] = true;
    _mock.accepted[$ string(_ids[3])] = true;
    global.net_refresh_forced_tick = -1;
    _mock.refresh_calls = 0;
    _mock.inject_hex(_ids[2], NET_TEST_PING);
    _mock.inject_hex(_ids[2], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(_mock.refresh_calls == 1 && !ds_map_exists(global.net_players, string(_ids[2])) && array_length(_mock.inbox) == 0,
        "a stranger: one forced refresh per tick, its messages are dropped");
    array_push(_mock.members, _ids[3]);                               // joined the lobby; the cached member list has not seen it yet
    global.net_refresh_forced_tick = -1;
    _mock.refresh_calls = 0;
    _mock.inject_hex(_ids[3], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(_mock.refresh_calls == 1 && ds_map_exists(global.net_players, string(_ids[3])), "a newcomer: the forced refresh admits the sender");
    net_test_end();
}

/// T-R5, T-I1: replies to HELLO, PONG handling, BYE closes the session exactly once, ids stay int64 on the way through the wrapper.
function net_test_receive_replies() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[1])] = true;
    var _peer = _ids[1];
    var _key = string(_peer);
    // the wrapper hands out the sender as an int64 equal to the member id
    _mock.inject_hex(_peer, NET_TEST_PING);
    var _probe = tcc_steam_net_packet_receive(global.net_recv_buffer);
    scr_port_assert(is_struct(_probe) && is_int64(_probe.steam_id_remote) && _probe.steam_id_remote == _peer
        && string_length(string(_probe.steam_id_remote)) == 17 && _probe.offset == 0 && _probe.size == 20 && _probe.channel == 0,
        "the receive wrapper reports the sender as an int64 equal to the member id");
    scr_port_assert(net_lobby_member(_probe.steam_id_remote), "the reported sender is a member");
    // HELLO announcement (reply 0) is answered by a HELLO reply (flags 41); a reply is not answered again
    var _before = array_length(_mock.send_log);
    _mock.inject_hex(_peer, NET_TEST_HELLO);
    net_receive_packets();
    scr_port_assert(array_length(_mock.send_log) == _before + 1, "a HELLO announcement is answered exactly once");
    var _reply = net_test_last(_mock);
    scr_port_assert(string_copy(_reply.hex, 1, 6) == "110301" && _reply.flags == 41, "the answer is a reliable HELLO with the reply flag");
    var _data = global.net_players[? _key];
    scr_port_assert(is_struct(_data) && _data.username == "Player" && _data.announced, "the announcement registered the player");
    _mock.inject_hex(_peer, string_copy(NET_TEST_HELLO, 1, 4) + "01" + string_copy(NET_TEST_HELLO, 7, string_length(NET_TEST_HELLO) - 6));
    net_receive_packets();
    scr_port_assert(array_length(_mock.send_log) == _before + 1, "a HELLO reply is not answered");
    // PONG: a fresh stamp sets the round trip time, the golden vector's old stamp is ignored
    var _pong = buffer_create(5, buffer_fixed, 1);
    buffer_write(_pong, buffer_u8, NET_PACKET_PONG);
    buffer_write(_pong, buffer_u32, (current_time - 40) & $FFFFFFFF);
    _mock.inject(_peer, _pong, 5);
    buffer_delete(_pong);
    net_receive_packets();
    var _rtt = global.net_players[? _key].rtt;
    scr_port_assert(_rtt >= 0 && _rtt < 60000, "a PONG with a fresh stamp sets the round trip time");
    _mock.inject_hex(_peer, NET_TEST_PONG);
    net_receive_packets();
    scr_port_assert(global.net_players[? _key].rtt == _rtt, "a PONG with an old stamp is ignored");
    // BYE: only the 1 byte form counts, and the session is closed exactly once
    var _closes = array_length(_mock.close_log);
    _mock.inject_hex(_peer, "1200");
    net_receive_packets();
    scr_port_assert(ds_map_exists(global.net_players, _key) && array_length(_mock.close_log) == _closes, "a BYE of the wrong size is ignored");
    _mock.inject_hex(_peer, "12");
    net_receive_packets();
    scr_port_assert(!ds_map_exists(global.net_players, _key) && array_length(_mock.close_log) == _closes + 1 && _mock.close_log[_closes] == _peer,
        "a BYE removes the player and closes the session exactly once");
    net_test_end();
}

function net_test_budget() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[1])] = true;
    repeat (200) _mock.inject_hex(_ids[1], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(array_length(_mock.receive_log) == 128 && array_length(_mock.inbox) == 72, "exactly 128 messages per tick; the rest stays queued");
    net_test_end();
}

/// T-A1, T-A2, T-A3: deferred callback, member accepted once, stranger refresh / expiry / ignore window, bounds.
function net_test_accept() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    var _t0 = 100000;
    _mock.fire_session_request(_ids[1]);
    scr_port_assert(array_length(global.net_session_requests) == 0, "callbacks are deferred: nothing happens before pump()");
    _mock.pump();                                                     // runs net_on_session_request with a dummy self
    scr_port_assert(array_length(global.net_session_requests) == 1, "member request queued by the callback");
    net_accept_pending_sessions(_t0);
    scr_port_assert(array_length(_mock.accept_log) == 1 && _mock.accept_log[0] == _ids[1] && array_length(global.net_session_requests) == 0, "member accepted once, queue empty");
    // stranger: fresh -> one forced refresh, never accepted, expires, ignored for 30 s
    global.net_refresh_forced_tick = -1;
    _mock.refresh_calls = 0;
    net_session_request_add(_ids[3], _t0);
    net_accept_pending_sessions(_t0);
    scr_port_assert(_mock.refresh_calls == 1 && array_length(_mock.accept_log) == 1 && array_length(global.net_session_requests) == 1, "fresh stranger: one forced refresh, not accepted");
    net_accept_pending_sessions(_t0);
    scr_port_assert(_mock.refresh_calls == 1, "the forced refresh is limited to one per tick");
    net_accept_pending_sessions(_t0 + NET_SESSION_REQUEST_TTL_MS + 1);
    scr_port_assert(array_length(global.net_session_requests) == 0, "stranger expired");
    scr_port_assert(!net_session_request_add(_ids[3], _t0 + 20000), "re-post inside the ignore window is not queued");
    scr_port_assert(net_session_request_add(_ids[3], _t0 + NET_SESSION_REQUEST_TTL_MS + NET_SESSION_IGNORE_MS + 2), "ignore window ends");
    // a lobby member is never held back by the ignore window
    global.net_session_requests = [];
    global.net_session_ignored[$ string(_ids[1])] = _t0 + 999999;
    scr_port_assert(net_session_request_add(_ids[1], _t0), "a member is queued even inside an ignore window");
    // the budget is shared with the receive loop
    global.net_refresh_forced_tick = timing_tick_id();
    _mock.refresh_calls = 0;
    _mock.accepted[$ string(_ids[3])] = true;
    _mock.inject_hex(_ids[3], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(_mock.refresh_calls == 0, "a tick whose forced refresh was spent does not refresh again for a non-member sender");
    // malformed requests and bounds
    net_on_session_request(undefined); net_on_session_request({});
    var _bad = new SteamNetworkingMessagesSessionRequest();
    net_on_session_request(_bad);
    scr_port_assert(!net_session_request_add(0, _t0) && !net_session_request_add(_ids[0], _t0) && !net_session_request_add("x", _t0), "id 0, own id and strings are ignored");
    global.net_session_requests = [];
    for (var _i = 0; _i < 40; ++_i) net_session_request_add(int64("765611981000000" + string(10 + _i)), _t0);
    scr_port_assert(array_length(global.net_session_requests) <= NET_SESSION_REQUEST_MAX, "queue is bounded");
    net_test_end();
}

/// T-A7: a member's first message while its session is not accepted yet, under both unverified native policies.
function net_test_accept_policy() {
    var _ids = net_test_ids();
    for (var _pass = 0; _pass < 2; ++_pass) {
        var _drop = _pass == 1;
        var _mock = net_test_begin(_ids[0], [_ids[1]]);
        _mock.policy_unaccepted = _drop ? "drop" : "hold";
        _mock.inject_hex(_ids[1], NET_TEST_PING);                     // posts a session request; held or dropped by policy
        net_receive_packets();
        scr_port_assert(!ds_map_exists(global.net_players, string(_ids[1])), "nothing from an unaccepted sender is processed");
        _mock.pump();                                                 // the request callback queues the member
        scr_port_assert(array_length(global.net_session_requests) == 1, "the unaccepted sender's request is queued");
        var _accepted = global.net_session_stats.accepted;
        net_accept_pending_sessions();
        scr_port_assert(array_length(_mock.accept_log) == 1 && global.net_session_stats.accepted == _accepted + 1 && array_length(global.net_session_requests) == 0,
            "the member is accepted by the accept pass");
        if (_drop) {
            scr_port_assert(array_length(_mock.inbox) == 0, "drop policy: the message sent before the accept is gone");
            _mock.inject_hex(_ids[1], NET_TEST_PING);                 // the sender's next ping arrives on the accepted session
        }
        net_receive_packets();
        scr_port_assert(ds_map_exists(global.net_players, string(_ids[1])), _drop ? "drop policy: the re-sent message flows" : "hold policy: the held message flows after the accept");
        net_test_end();
    }
}

/// T-A4, T-A5, T-A6: no lobby means entries wait; reset clears the queue and the ignore map; registering twice; failure diagnostics.
function net_test_session_events() {
    var _ids = net_test_ids();
    var _t0 = 100000;
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    // T-A4
    global.net_active = false;
    scr_port_assert(net_session_request_add(_ids[1], _t0) && net_session_request_add(_ids[3], _t0), "requests are queued while no lobby is active");
    net_accept_pending_sessions(_t0 + NET_SESSION_REQUEST_TTL_MS + 1);
    scr_port_assert(array_length(_mock.accept_log) == 0 && array_length(global.net_session_requests) == 2, "nothing is accepted or expired while no lobby is active");
    global.net_session_ignored[$ string(_ids[3])] = _t0 + 999999;
    net_reset_lobby_state();
    scr_port_assert(array_length(global.net_session_requests) == 0 && variable_struct_names_count(global.net_session_ignored) == 0, "a lobby reset clears the request queue and the ignore map");
    global.net_active = true;
    net_refresh_members();                                            // the reset emptied the membership cache
    // T-A5
    net_register_steam_callbacks();
    net_register_steam_callbacks();
    scr_port_assert(is_callable(_mock.request_cb) && is_callable(_mock.failed_cb), "both session callbacks are registered");
    _mock.fire_session_request(_ids[1]);
    scr_port_assert(_mock.pump() == 1 && array_length(global.net_session_requests) == 1, "registering twice leaves exactly one callback per kind");
    // T-A6
    var _stats = global.net_session_stats;
    var _failed = _stats.failed;
    _mock.fire_session_failed(_ids[3], 5003, "relay unreachable");
    scr_port_assert(_stats.failed == _failed, "a failure callback is deferred too");
    _mock.pump();
    scr_port_assert(_stats.failed == _failed + 1 && is_struct(_stats.last_failure) && _stats.last_failure.user == string(_ids[3])
        && _stats.last_failure.reason == 5003 && _stats.last_failure.text == "relay unreachable", "a failed session is counted and recorded");
    var _logged = _stats.failure_logged_at;
    _mock.fire_session_failed(_ids[3], 5003, string_repeat("x", 300));
    _mock.pump();
    scr_port_assert(_stats.failed == _failed + 2 && _stats.failure_logged_at == _logged && string_length(_stats.last_failure.text) == 128,
        "failure logging is rate limited and the text is capped");
    scr_port_assert(net_lobby_member(_ids[1]) && !net_lobby_member(_ids[3]) && global.net_active, "a failed session changes no membership");
    net_on_session_failed(undefined); net_on_session_failed({});
    net_test_end();
}

function net_test_outbox() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.results = [25];
    net_send_hello(_ids[1], true);                                    // refused with LimitExceeded -> outbox
    scr_port_assert(array_length(global.net_outbox) == 1, "refused HELLO enters the outbox");
    var _kept = global.net_outbox[0].buffer;
    net_outbox_pump();
    scr_port_assert(array_length(global.net_outbox) == 0 && !buffer_exists(_kept), "retry succeeds, entry and buffer freed");
    var _n = array_length(_mock.send_log);
    scr_port_assert(_mock.send_log[_n - 1].hex == _mock.send_log[_n - 2].hex && _mock.send_log[_n - 1].flags == 41, "the retry carries the identical bytes");
    _mock.results = [25, 25];                                         // the chunk and the BYE are refused: neither is ever queued
    buffer_seek(global.net_send_buffer, buffer_seek_start, 0); buffer_write(global.net_send_buffer, buffer_u8, NET_PACKET_LEVEL_CHUNK);
    net_send_to(_ids[1], NET_SHARE_HEADER, true);
    net_send_bye();
    scr_port_assert(array_length(global.net_outbox) == 0, "chunks and BYE are not outbox-eligible");
    _mock.results = [25];
    net_send_to(_ids[1], 5, false);                                   // a refused unreliable packet is not queued either
    scr_port_assert(array_length(global.net_outbox) == 0, "unreliable packets are not outbox-eligible");
    _mock.results = [25];
    net_send_hello(_ids[1], true);
    net_outbox_pump(current_time + NET_OUTBOX_AGE_MS + 1);
    scr_port_assert(array_length(global.net_outbox) == 0, "entries expire");
    _mock.results = [25];
    net_send_hello(_ids[1], true);
    array_delete(_mock.members, 1, 1);
    net_refresh_members();
    net_outbox_pump();
    scr_port_assert(array_length(global.net_outbox) == 0, "entries for a peer that left are dropped");
    _mock.cap = 0;                                                    // organic LimitExceeded from the queue model
    array_push(_mock.members, _ids[2]);
    net_refresh_members();
    var _dropped = global.net_send_stats.outbox_dropped;
    repeat (NET_OUTBOX_MAX + 4) net_send_hello(_ids[2], true);
    scr_port_assert(array_length(global.net_outbox) == NET_OUTBOX_MAX && global.net_send_stats.outbox_dropped == _dropped + 4, "outbox is bounded; the oldest entries are dropped first");
    // a retry that meets a full queue keeps its entries (order is preserved); a hard failure drops only that entry, the rest go on
    net_outbox_pump();
    scr_port_assert(array_length(global.net_outbox) == NET_OUTBOX_MAX, "a retry that meets a full queue keeps its entries");
    var _sent = global.net_send_stats.outbox_sent;
    _dropped = global.net_send_stats.outbox_dropped;
    _mock.cap = 524288;
    _mock.results = [3];
    net_outbox_pump();
    scr_port_assert(array_length(global.net_outbox) == 0 && global.net_send_stats.outbox_dropped == _dropped + 1
        && global.net_send_stats.outbox_sent == _sent + NET_OUTBOX_MAX - 1, "a retry refused for another reason is dropped, the others are delivered");
    _mock.cap = 0;
    repeat (3) net_send_hello(_ids[2], true);
    scr_port_assert(array_length(global.net_outbox) == 3, "refused packets are queued again");
    var _held = global.net_outbox[0].buffer;
    net_reset_lobby_state();
    scr_port_assert(array_length(global.net_outbox) == 0 && !buffer_exists(_held), "a lobby reset frees the outbox buffers");
    net_test_end();
}

/// T-L1: leaving announces and closes every member, accepts nothing.
function net_test_leave() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1], _ids[2], _ids[3]]);
    net_leave_lobby(false);
    var _byes = 0;
    var _targets = {};
    for (var _i = 0; _i < array_length(_mock.send_log); ++_i) {
        var _entry = _mock.send_log[_i];
        if (_entry.hex == "12" && _entry.flags == 41) { _byes += 1; _targets[$ string(_entry.user)] = true; }
    }
    scr_port_assert(_byes == 3 && variable_struct_names_count(_targets) == 3 && variable_struct_exists(_targets, string(_ids[1]))
        && variable_struct_exists(_targets, string(_ids[2])) && variable_struct_exists(_targets, string(_ids[3])), "leaving sends one reliable BYE to each member");
    scr_port_assert(array_length(_mock.close_log) == 3 && array_length(_mock.accept_log) == 0, "leaving closes one session per member and accepts none");
    scr_port_assert(!global.net_active && array_length(global.net_member_list) == 0, "leaving resets the lobby state");
    net_test_end();
}

/// T-L2: the paths that close a session (timeout, membership prune) and the ones that must not (lobby reset).
function net_test_peer_loss() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1], _ids[2]]);
    _mock.accepted[$ string(_ids[1])] = true;
    _mock.accepted[$ string(_ids[2])] = true;
    _mock.inject_hex(_ids[1], NET_TEST_PING);
    _mock.inject_hex(_ids[2], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(ds_map_size(global.net_players) == 2, "two peers are tracked");
    var _closes = array_length(_mock.close_log);
    global.net_players[? string(_ids[1])].last_update = current_time - NET_PEER_TIMEOUT_MS - 1000;
    net_update_ghosts();
    scr_port_assert(!ds_map_exists(global.net_players, string(_ids[1])) && ds_map_exists(global.net_players, string(_ids[2]))
        && array_length(_mock.close_log) == _closes + 1 && _mock.close_log[_closes] == _ids[1], "a peer silent for 10 s is removed and its session closed");
    array_delete(_mock.members, 2, 1);                                // _ids[2] left the lobby
    net_refresh_members();
    scr_port_assert(!ds_map_exists(global.net_players, string(_ids[2])) && array_length(_mock.close_log) == _closes + 2 && _mock.close_log[_closes + 1] == _ids[2],
        "a member that left the lobby is pruned by the refresh and its session closed");
    array_push(_mock.members, _ids[2]);
    net_refresh_members();
    _mock.accepted[$ string(_ids[2])] = true;                         // the close dropped the acceptance; the returning member is accepted again
    _mock.inject_hex(_ids[2], NET_TEST_PING);
    net_receive_packets();
    scr_port_assert(ds_map_exists(global.net_players, string(_ids[2])), "a returning member is tracked again");
    _closes = array_length(_mock.close_log);
    net_reset_lobby_state();
    scr_port_assert(array_length(_mock.close_log) == _closes && ds_map_size(global.net_players) == 0, "a lobby reset closes no session");
    net_test_end();
}

/// T-L3 (sender half, and the receiver's chunk handling in net_test_receive_chunks): serve a level to a scripted requester,
/// refuse the third chunk once, rebuild the bytes from the mock's log. No file is written.
function net_test_level_share() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1]]);
    _mock.accepted[$ string(_ids[1])] = true;
    var _peer = _ids[1];
    var _stalled = global.net_send_stats.stalled;
    // unknown level: the request is denied with the golden bytes
    var _before = array_length(_mock.send_log);
    _mock.inject_hex(_peer, NET_TEST_REQUEST);
    net_receive_packets();
    scr_port_assert(array_length(_mock.send_log) == _before + 1 && net_test_last(_mock).flags == 41
        && net_test_last(_mock).hex == "18" + string_copy(NET_TEST_REQUEST, 3, string_length(NET_TEST_REQUEST) - 2) && array_length(global.net_share_out) == 0,
        "a request for an unknown level is denied");
    // offered level of 20000 bytes = chunks of 8192, 8192 and 3616
    var _text = string_repeat("abcdefghij", 2000);
    var _md5 = net_levelshare_offer(_text);
    var _request = buffer_create(34, buffer_fixed, 1);
    buffer_write(_request, buffer_u8, NET_PACKET_LEVEL_REQUEST);
    buffer_write(_request, buffer_string, _md5);
    _mock.inject(_peer, _request, buffer_tell(_request));
    buffer_delete(_request);
    net_receive_packets();
    scr_port_assert(array_length(global.net_share_out) == 1 && global.net_share_out[0].peer == _peer && global.net_share_out[0].md5 == _md5, "a request for an offered level is queued");
    var _from = array_length(_mock.send_log);
    _mock.results = [1, 1, 25];                                       // the third chunk is refused once
    net_levelshare_tick();
    scr_port_assert(array_length(_mock.send_log) == _from + 3 && _mock.send_log[_from + 2].result == 25 && array_length(global.net_share_out) == 1
        && global.net_share_out[0].offset == 2 * NET_CHUNK_DATA_SIZE && array_length(global.net_outbox) == 0, "a refused chunk stops the tick and is not queued elsewhere");
    var _active_buffer = global.net_share_out[0].buffer;
    net_levelshare_tick();
    scr_port_assert(array_length(_mock.send_log) == _from + 4 && _mock.send_log[_from + 3].result == 1 && _mock.send_log[_from + 3].hex == _mock.send_log[_from + 2].hex
        && array_length(global.net_share_out) == 0 && !buffer_exists(_active_buffer), "the refused chunk is resent identically; the finished transfer frees its buffer");
    scr_port_assert(global.net_send_stats.stalled == _stalled, "a healthy transfer is not counted as stalled");
    var _assembled = buffer_create(20000, buffer_fixed, 1);
    var _chunks = 0;
    for (var _i = _from; _i < array_length(_mock.send_log); ++_i) {
        var _entry = _mock.send_log[_i];
        if (_entry.result != 1) continue;
        var _packet = net_test_from_hex(_entry.hex);
        var _offset = buffer_peek(_packet, 38, buffer_u32);
        var _length = buffer_peek(_packet, 42, buffer_u16);
        scr_port_assert(buffer_peek(_packet, 0, buffer_u8) == NET_PACKET_LEVEL_CHUNK && _entry.flags == 41 && buffer_peek(_packet, 34, buffer_u32) == 20000
            && buffer_get_size(_packet) == NET_SHARE_HEADER + _length && _offset == _chunks * NET_CHUNK_DATA_SIZE, "chunk " + string(_chunks) + " has the announced header");
        buffer_copy(_packet, NET_SHARE_HEADER, _length, _assembled, _offset);
        buffer_delete(_packet);
        _chunks += 1;
    }
    scr_port_assert(_chunks == 3 && buffer_md5(_assembled, 0, 20000) == _md5, "the chunks rebuild exactly the offered level");
    buffer_delete(_assembled);
    var _problem = net_test_flags_problem(_mock);
    scr_port_assert(_problem == "", "flags per packet type: " + _problem);
    // the offer is process-wide state: take it back
    ds_map_delete(global.net_share_texts, _md5);
    for (var _o = array_length(global.net_share_order) - 1; _o >= 0; --_o) if (global.net_share_order[_o] == _md5) array_delete(global.net_share_order, _o, 1);
    net_test_end();
}

/// T-L4: a transfer that has not moved for 60 s is dropped and its buffer freed; one that has moved recently is left alone.
function net_test_level_stall() {
    var _ids = net_test_ids();
    var _mock = net_test_begin(_ids[0], [_ids[1], _ids[2]]);
    _mock.cap = 0;                                                    // every send is refused
    var _stalled = global.net_send_stats.stalled;
    var _data = buffer_create(100, buffer_fixed, 1);
    var _healthy = buffer_create(100, buffer_fixed, 1);
    global.net_share_out = [
        {peer:_ids[1], md5:"0123456789abcdef0123456789abcdef", buffer:_data, size:100, offset:0, progress_at:current_time - 70000},
        {peer:_ids[2], md5:"fedcba9876543210fedcba9876543210", buffer:_healthy, size:100, offset:0, progress_at:current_time - 1000}
    ];
    net_levelshare_tick();
    scr_port_assert(array_length(global.net_share_out) == 1 && global.net_share_out[0].peer == _ids[2] && !buffer_exists(_data) && buffer_exists(_healthy),
        "a transfer with no accepted chunk for 60 s is dropped and its buffer freed; a recent one is untouched");
    scr_port_assert(global.net_send_stats.stalled == _stalled + 1, "the stall is counted");
    net_test_end();
    scr_port_assert(!buffer_exists(_healthy), "a lobby reset frees queued transfer buffers");
}

/// T-H1: the host name is a cached global; owners keep the hosting text, a reset clears it.
function net_test_host_name() {
    var _ids = net_test_ids();
    net_test_begin(_ids[0], [_ids[1]]);
    global.net_is_host = true;
    global.net_host_name = "Alice";
    net_cache_host_name();
    scr_port_assert(global.net_host_name == "Alice", "the cache refresh is a no-op for the lobby owner");
    global.net_is_host = false;
    net_cache_host_name();
    scr_port_assert(is_string(global.net_host_name) && global.net_host_name == "", "a follower refresh without lobby data leaves an empty name, not a stale one");
    scr_port_assert(net_clean_name("A" + chr(10) + "B" + chr(13) + "C") == "A B C", "host names lose line breaks");
    global.net_host_name = "Bob";
    net_reset_lobby_state();
    scr_port_assert(global.net_host_name == "", "a lobby reset clears the cached host name");
    net_log_transport("selfcheck");                                   // diagnostics read only fields that exist
    net_test_end();
}

/// T-P1: production allocation and the inert layer without a mock.
function net_test_inert() {
    var _ids = net_test_ids();
    net_test_begin(_ids[0], [_ids[1]]);
    net_test_end();
    scr_port_assert(buffer_exists(global.net_recv_buffer) && buffer_get_size(global.net_recv_buffer) == NET_RECV_BUFFER_BYTES
        && buffer_get_type(global.net_recv_buffer) == buffer_fixed, "the receive buffer is the fixed production allocation");
    scr_port_assert(is_undefined(tcc_steam_net_mock()) && is_undefined(global.tcc_net_mock), "the mock seam is removed after the tests");
    scr_port_assert(!tcc_steam_net_packet_send(_ids[1], global.net_send_buffer, 5) && is_undefined(tcc_steam_net_packet_receive(global.net_recv_buffer))
        && !tcc_steam_net_accept_session(_ids[1]) && !tcc_steam_net_close_p2p_session(_ids[1]), "net wrappers are inert without a mock");
    scr_port_assert(tcc_steam_lobby_get_member_count() == 0 && tcc_steam_lobby_get_member_id(0) == 0 && tcc_steam_lobby_get_owner_id() == 0, "lobby reads are inert without a mock");
    scr_port_assert(!tcc_steam_net_set_session_request_callback(net_on_session_request) && !tcc_steam_net_set_session_failed_callback(net_on_session_failed),
        "session callbacks are refused without Steam");
    scr_port_assert(!net_send_to(_ids[1], 5, true), "the net layer refuses a send without a lobby");
}
