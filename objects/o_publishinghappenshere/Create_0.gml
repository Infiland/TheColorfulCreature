result = 0
timer = 120
timer2 = 120
//var app_id = "1651680"
var directory = working_directory + "/LevelEditor Files/" + "/" + global.levelname + "/"
image = directory + "/thumb.jpg"
new_item = steam_ugc_create_item(global.appid, ugc_filetype_community);
updated = 0
//steam_send_screenshot(image,window_get_width(), window_get_height())