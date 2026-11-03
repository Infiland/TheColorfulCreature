depth = -20000

// Drawing and clicks are handled by the creator; no default sprite or mouse mask
sprite_index = -1

selected = 0
selected_order = 0

level = 0
mPath = ""

base_x = x
base_y = y
filtered_out = 1 // the creator shows it once it knows where it goes
hov = 0
fit_key = ""
fit_lines = []

mTitle = "Loading"
mTitle_lc = "loading"
mTags = ""
loaded = 0

diamond_time = 0
difficulty = 0

steam_details = -1
thumb_spr = -1
thumb_loaded = 0

owner_id = 0

alarm[0] = 1

timing_ui_register_target("workshop-sequence-tile");
