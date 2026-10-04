/// @description Draw online multiplayer HUD info (GUI layer)

// --- Bottom bar: joining, results and following the host ---
var _bar_text = "";
var _bar_color = c_white;
var _bar_alpha = 0;
if (global.net_connect_state == 2) {
	var _dots = "";
	repeat (floor(global.net_connect_timer / 30) % 4) _dots += ".";
	_bar_text = loc("NET_CONNECTING") + _dots;
	_bar_alpha = 1;
} else if (global.net_connect_state == 3 || global.net_connect_state == 4) {
	_bar_alpha = clamp(global.net_connect_flash / 60, 0, 1);
	_bar_text = global.net_connect_msg;
	_bar_color = global.net_connect_state == 3 ? c_lime : make_color_rgb(255, 80, 80);
}
var _job = global.net_follow_job;
if (is_struct(_job)) {
	var _host = net_field(_job.desc, "name", "");
	var _mode = net_session_text(_job.desc);
	if (_job.state == "wait") {
		var _dots = "";
		repeat (floor(current_time / 400) % 4) _dots += ".";
		_bar_text = string_replace(loc("NET_DOWNLOADING_LEVEL"), "{NAME}", _host) + _dots;
	} else if (!net_follow_can_enter()) {
		_bar_text = string_replace(string_replace(loc("NET_FOLLOW_BLOCKED"), "{NAME}", _host), "{MODE}", _mode);
	} else {
		_bar_text = string_replace(string_replace(string_replace(loc("NET_FOLLOW_COUNTDOWN"), "{NAME}", _host), "{MODE}", _mode),
			"{SECONDS}", string(ceil(_job.timer / 60)));
	}
	_bar_color = c_white;
	_bar_alpha = 1;
}
if (_bar_alpha > 0 && _bar_text != "") {
	draw_set_alpha(0.7 * _bar_alpha);
	draw_set_color(c_black);
	draw_rectangle(0, 728, 1024, 768, false);
	draw_set_font(fnt_multiplayerfont);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_alpha(_bar_alpha);
	draw_set_color(_bar_color);
	draw_text(512, 748, _bar_text);
}

// --- Online player count (top-right corner, during gameplay) ---
draw_set_font(fnt_multiplayerfont);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
var _notice_y = 6;
if (global.net_active && global.net_level_key != "" && net_member_count() > 1) {
	draw_set_alpha(0.6);
	var _text = string_replace(string_replace(loc("NET_PLAYERS_HERE"), "{HERE}", string(net_get_ghost_count() + 1)),
		"{TOTAL}", string(net_member_count()));
	draw_set_color(c_black);
	draw_text(1020 + 1, _notice_y + 1, _text);
	draw_set_color(c_white);
	draw_text(1020, _notice_y, _text);
	_notice_y += 16;
}

// --- Notices (players joining/leaving, host changes) ---
for (var _i = 0; _i < array_length(global.net_notices); ++_i) {
	var _notice = global.net_notices[_i];
	draw_set_alpha(clamp(_notice.timer / 60, 0, 1) * 0.9);
	draw_set_color(c_black);
	draw_text(1020 + 1, _notice_y + 1, _notice.text);
	draw_set_color(c_white);
	draw_text(1020, _notice_y, _notice.text);
	_notice_y += 14;
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
