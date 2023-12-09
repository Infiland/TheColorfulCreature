image_speed = 0
if current_month = 4 {
if current_day < 5 {
image_index = 1
}}

if current_month = 5 {
if current_day < 5 {
image_index = 1
}}
audio_stop_sound(m_owthespikes);
if !audio_is_playing(m_warp) {
audio_play_sound(m_warp,0,0)
}