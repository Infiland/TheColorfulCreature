if (!timing_instance_step()) exit;
tradeup_defaults();
var _state = global.tradeup_state;
trade_in_progress = _state.phase != "idle";
if (_state.revision != inventory_revision) {
    inventory_revision = _state.revision;
    entries = scr_build_tradeup_list();
    selected = clamp(selected,0,max(0,array_length(entries)-1));
}
dis = lerp(dis,selected,min(1,0.1 * (144 / global.maxfps)));
if (arrowyscale > 1) change = 0;
if (arrowyscale < 0.9) change = 1;
arrowyscale = lerp(arrowyscale,change == 0 ? 0.89 : 1.01,min(1,0.1 * (60 / global.maxfps)));

// Do not navigate, close the owner, or accept another row behind confirmation.
if (instance_exists(o_popup)) exit;
var _device = gamepad_remap_active_device(true);
if (timing_keyboard_pressed(vk_escape) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device,gp_face2))) {
    instance_destroy(); exit;
}
if (timing_keyboard_pressed(ord("R")) && !trade_in_progress) tradeup_request_inventory();
if (trade_in_progress || !_state.ready) exit;

var _count = array_length(entries);
if (_count == 0) exit;
var _interact = timing_keyboard_pressed(settings_keyboard_code(global.controlsinteract))
    || (_device >= 0 && tcc_gamepad_button_check_pressed(_device,gamepad_remap_get(3)));
if (timing_keyboard_pressed(vk_enter) || _interact) {
    var _entry = entries[selected];
    global.popup_config = {
        title:loc("TRADE_UP"),
        message:"Trade 5x " + scr_get_tier_name(_entry.tier) + " " + _entry.name
            + " for 1x " + scr_get_tier_name(_entry.tier+1) + " " + _entry.name + "?",
        mode:1,
        cb_yes:method({owner:id,skin:_entry.skin_id,tier:_entry.tier,revision:_state.revision},function() {
            if (!instance_exists(owner)) return;
            if (global.tradeup_state.revision != revision) {
                global.tradeup_state.message = "Inventory changed. Choose the trade again.";
                return;
            }
            scr_execute_trade_up(skin,tier);
        }),
        cb_no:undefined
    };
    instance_create(0,0,o_popup);
    exit;
}
var _left = timing_keyboard_down(vk_left) || (_device >= 0 && tcc_gamepad_button_check(_device,gp_padl));
var _right = timing_keyboard_down(vk_right) || (_device >= 0 && tcc_gamepad_button_check(_device,gp_padr));
var _direction = (_right ? 1 : 0) - (_left ? 1 : 0);
if (_direction == 0) { press = 0; holdcooldown = 40; }
else {
    holdcooldown -= 60 / global.maxfps;
    if (press != _direction || holdcooldown <= 0) {
        selected = clamp(selected+_direction,0,_count-1);
        holdcooldown = press == _direction ? 4 : 40;
        press = _direction;
    }
}
