if global.friendleaderboardsettings = 1 { global.friendleaderboardsettings = 0 } else { global.friendleaderboardsettings = 1 }

if instance_exists(o_onlineleaderboards) {
with o_onlineleaderboards {
reloadleaderboards()
}}