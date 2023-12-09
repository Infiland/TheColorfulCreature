///@desc Example - Step
if (Discord_ready) {
  Time_left -= (delta_time / 1000000);
  if (Time_left <= 0) {
    
    if (Pupper_check.Toggled) {
      Puppers++;
      Time_left = floor(10 + sqrt(Puppers + Puppers));
      Details_string = string(Puppers) + " Puppers sprouted.";
      rousr_dissonance_set_details(Details_string);
    } else {
     Time_left = Timestamp;
    }
    if (Timer_check.Toggled)
      rousr_dissonance_set_timestamps(0, Time_left);
  }
}

if (keyboard_check_pressed(vk_escape) && global.__field_focus == noone)
  game_end();