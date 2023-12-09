///@desc 
var yy = 0;
var line_height = string_height("Join requested") + 2;

var time = floor(Time_left);
var mm = floor(time / 60);
var ss = time % 60;
var mm = (mm < 10 ? "0" : "") + string(mm);
var ss = (ss < 10 ? "0" : "") + string(ss);

var ttw = string_width("Details: ");
draw_text(x, yy, "Details: "); draw_text(x + ttw, yy, Details_string); yy += line_height;
if (Timer_check.Toggled) {  draw_text(x, yy, "Timer: "); draw_text(x + ttw, yy, "(" + mm + ":" + ss + ")"); yy += line_height; }
draw_text(x, yy, "State: "); draw_text(x + ttw, yy, State_string); yy += line_height;

if (Join != undefined) {
  draw_text(x, yy, "Join - Join match with secret: " + Join); 
  yy += line_height;
}

if (Join_requested != undefined) {
  if (is_string(Join_requested)) {
    draw_text(x, yy, Join_requested);
    yy += line_height;
  } else {
    draw_text(x, yy, "Join requested by: (" + Join_requested[0] + ") " + Join_requested[1] + " - Avatar: " + Join_requested[2]);
    yy += line_height;  
    
    var button_widths = AcceptButton.sprite_width + RejectButton.sprite_width + IgnoreButton.sprite_width;
    var padding = 10 * 3;

    var xx = (room_width - (button_widths + padding)) / 2;

    AcceptButton.x = xx;
    AcceptButton.visible = true;
    xx += AcceptButton.sprite_width + 10;
    
    RejectButton.x = xx;
    RejectButton.visible = true;
    xx += RejectButton.sprite_width + 10;
    
    IgnoreButton.x = xx;
    IgnoreButton.visible = true;
    xx += IgnoreButton.sprite_width + 10;
    
    yy += IgnoreButton.sprite_height + 5; 
  }
  
}

if (Spectate_requested != undefined) {
  draw_text(x, yy, "Spectate - Spectate match with secret: " + Spectate_requested);
  yy += line_height;
}

yy += line_height;
yy += line_height;
  
if (Error_msg != undefined) {
  draw_text(x, yy, "ERROR: " + Error_msg);
  yy += line_height;
  
  Details_field.visible = false;
  State_field.visible   = false;
  AcceptButton.visible  = false;
  RejectButton.visible  = false;
  IgnoreButton.visible  = false;
  Pupper_check.visible  = false;
  Timer_check.visible   = false;
  Timer_field.visible   = false;
  Party_check.visible   = false;
} else if (Discord_ready) {
  draw_text(x, yy, "Discord RCP Ready.");
  yy += line_height;  
  yy += line_height;
  
  var xw = string_width("match_secret:  ");
  
  draw_text(x, yy, "party id:     "); draw_text(x + xw, yy, Party_id); yy += line_height;
  draw_text(x, yy, "join secret:  "); draw_text(x + xw, yy, Join_key); yy += line_height;
  draw_text(x, yy, "watch secret: "); draw_text(x + xw, yy, Spectate_key); yy += line_height;
  draw_text(x, yy, "match secret: "); draw_text(x + xw, yy, Match_key); yy += line_height;
  
  Details_field.visible = !Pupper_check.Toggled;
  State_field.visible   = !Pupper_check.Toggled;
  Timer_field.visible   = !Pupper_check.Toggled && Timer_check.Toggled;
  Pupper_check.visible  = true;
  Timer_check.visible   = true;
  Party_check.visible   = true;
 
  var field_height = Party_size_field.image_yscale + 2;
 
  Party_check.x = x;
  Party_check.y = yy + 2;
  
  Party_size_field.visible = Party_check.Toggled;
  Party_max_field.visible = Party_check.Toggled;
  
  if (Party_check.Toggled) {
    var px = x + (Party_check.sprite_width + string_width(Party_check.Label) + 7);
    draw_text(px, yy + 4, "- Size: ");
    px += string_width("- Size: ") + 1;
    
    Party_size_field.x = px;
    Party_size_field.y = yy;
    
    px += Party_size_field.image_xscale + 4;
    draw_text(px, yy + 4, "Max: ");
    px += string_width("Max: ") + 1;
    
    Party_max_field.x = px;
    Party_max_field.y = yy;
  }
  
  yy += field_height;
   
  Timer_check.x = x;
  Timer_check.y = yy + 2;
    
  if (!Pupper_check.Toggled && Timer_check.Toggled) {
    Timer_field.visible = true;
    var timerx = x + (Party_check.sprite_width + string_width(Party_check.Label) + 7);
    draw_text(timerx, yy + 4, "- Time Until: ");
    Timer_field.x = timerx + string_width("- Time Until: ") + 1;
    Timer_field.y = yy;
  } else 
    Timer_field.visible = false;
  
  yy += field_height;
  
  Pupper_check.x = x;
  Pupper_check.y = yy + 2;
  yy += field_height;
  
  if (!Pupper_check.Toggled) {
    var lw = string_width("Details Field: ") + 2;
    field_height = Details_field.image_yscale + 2;
 
    draw_text(x, yy + 4, "Details Field: ");
    Details_field.x = x + lw;
    Details_field.y = yy;
    yy += field_height;
  
    draw_text(x, yy + 4, "Status Field: ");
    State_field.x = x + lw;
    State_field.y = yy;
    yy += field_height;
  }
}