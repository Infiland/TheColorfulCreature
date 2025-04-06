if (target != noone && instance_exists(target)) {
    var should_draw = true;
    
    if (variable_instance_exists(target, "state")) {
        if (target.state == 0) {
            should_draw = false;
        }
    }
    
    if (should_draw && target_hp > 0) {
        var current_width = (target_hp / target_maxhp) * bar_width;
        
        var shake_x = bar_x + random_range(-shake, shake);
        var shake_y = bar_y + random_range(-shake, shake);
        
        draw_set_alpha(0.7);
        draw_set_color(c_black);
        draw_rectangle(shake_x - 3, shake_y - 3, shake_x + bar_width + 3, shake_y + bar_height + 3, false);
        draw_set_alpha(1);

        draw_set_color(c_dkgray);
        draw_rectangle(shake_x, shake_y, shake_x + bar_width, shake_y + bar_height, false);
        
        var segment_width = bar_width / bar_segments;
        for (var i = 0; i < bar_segments; i++) {
            if (i * segment_width <= current_width) {
                var seg_fill = min(segment_width, current_width - (i * segment_width));
                
                var hp_percent = target_hp / target_maxhp;
                
                if (variable_instance_exists(id, "custom_colors") && custom_colors == true) {
                    if (hp_percent > 0.66) {
                        draw_set_color(color_high);
                    } else if (hp_percent > 0.33) {
                        draw_set_color(color_med);
                    } else {
                        draw_set_color(color_low);
                    }
                } else {
                    if (hp_percent > 0.66) {
                        var blend_amount = (1 - (hp_percent - 0.66) * 3);
                        draw_set_color(merge_color(c_lime, c_yellow, blend_amount));
                    } else if (hp_percent > 0.33) {
                        var blend_amount = (1 - (hp_percent - 0.33) * 3);
                        draw_set_color(merge_color(c_yellow, c_red, blend_amount));
                    } else {
                        var blend_amount = (1 - hp_percent * 3);
                        draw_set_color(merge_color(c_red, c_maroon, blend_amount));
                    }
                }
                
                draw_rectangle(
                    shake_x + (i * segment_width) + 2, 
                    shake_y + 2, 
                    shake_x + (i * segment_width) + seg_fill - 2, 
                    shake_y + bar_height - 2, 
                    false
                );
            }
        }
        
        if (flash_alpha > 0) {
            draw_set_alpha(flash_alpha);
            draw_set_color(c_white);
            draw_rectangle(shake_x, shake_y, shake_x + bar_width, shake_y + bar_height, false);
            draw_set_alpha(1);
        }
        
        draw_set_color(c_white);
        draw_rectangle(shake_x, shake_y, shake_x + bar_width, shake_y + bar_height, true);
        
        // Draw health text
		/*
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(global.deathfont);
        draw_text_transformed(
            shake_x + bar_width/2, 
            shake_y + bar_height/2, 
            string(ceil(target_hp)) + "/" + string(target_maxhp),
            0.7, 0.7, 0
        );*/
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
