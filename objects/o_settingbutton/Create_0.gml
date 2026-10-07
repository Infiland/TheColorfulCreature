declarecustombutton()
depth = -10000000000

// Settings-specific instance variables (set by spawner)
setting_type = STYPE.TOGGLE
setting_menu = 0
setting_col = 32
setting_row = 0
setting_info_id = 0
setting_gvar = ""
setting_label = ""
setting_max = 1
setting_options = []
setting_target_menu = 0
setting_callback = undefined
custom_cycle = false
cheat_gated = false
one_way = false
gated = false
dlc_gate = -1
demo_gate = false
use_loc = false

// Button sizing
image_xscale = 50
image_yscale = 10

mobile_settings_slot = -1;
mobile_page_direction = 0;
mobile_language = -1;

mobile_card_width = 464;
mobile_card_height = 108;
if (platform_mobile()) visible = false; // First Step assigns the active page and hit area.
