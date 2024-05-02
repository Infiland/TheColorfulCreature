function drawquest(yy,quest=0,qid=0){
	
draw_set_halign(fa_center)
	
//Variables
var title = str[quest][0]
var description = str[quest][1]
var current = variable_global_get(str[quest][2]) //Current Progress
var needed = str[quest][3] //Required
var reward = str[quest][4] //Credits Reward
var completed = false //Is the quest completed
var claimed = global.QUEST[qid] //Is the quest claimed
//If quest is completed
if current >= real(needed) { //If requirement is fulfilled, mark quest as complete
	completed = true
	current = real(needed)
}

	//Rectangle Box for Quest
	draw_rectangle_color(100,yy,924,yy+150,c_black,c_black,c_black,c_black,false)
	//If quest is completed, flash green
	if completed = true && claimed = false {
		draw_set_alpha(1+sin(yy+current_time/200))
		draw_rectangle_color(100,yy,924,yy+150,#a6f5a6,#7feb7f,#38e038,#52c452,false)
	}
	draw_set_alpha(1)
	draw_rectangle_color(100,yy,924,yy+150,c_white,c_white,c_white,c_white,true)
	draw_text_color(512,yy+10,title,c_yellow,c_orange,c_yellow,c_orange,1) //Quest Title
	draw_text(512,yy+35,description) //Quest Description
	
	//Progress Bar
	draw_rectangle_color(150,yy+65,874,yy+95,c_green,c_green,c_green,c_green,false)
	//show_debug_message(quest)
	draw_rectangle_color(150,yy+65,150+724*(current/real(needed)),yy+95,c_lime,c_lime,c_lime,c_lime,false)
	draw_set_alpha(1+sin(yy+current_time/200))
	draw_rectangle_color(150,yy+65,150+724*(current/real(needed)),yy+95,#59ff59,#59ff59,#85ff85,#85ff85,false)
	draw_set_alpha(1)
	
	//Click to claim text
	if completed = true {
		if claimed = false {
			draw_text(512,yy+108,"Click to claim the reward!")
		} else {
			draw_text(512,yy+108,"Claimed!")
		}
	}
	
	//Progress Text
	draw_text_color(512,yy+68,string(current) + "/" + needed,c_white,c_ltgray,c_white,c_ltgray,1) 
	draw_set_halign(fa_left)
	
	//Reward
	if claimed = false {
		draw_sprite_ext(s_creditscurrency,0,120,yy+105,2,2,0,c_white,1)
		if global.creditsmultiplier > 1 { draw_set_color(c_yellow) }
		draw_text(195,yy+108,string(floor(real(reward) * global.creditsmultiplier)))
	} else {
		draw_sprite_ext(s_levelhud,0,120,yy+105,0.5,0.5,0,c_white,1)	
	}
	draw_set_color(c_white)
	
	//Click to get reward
	if mouse_x > 150 && mouse_x < 924 && mouse_y > yy && mouse_y < yy+150 && completed = true && claimed = false {
		if mouse_check_button_pressed(mb_left) && alphalerp > 0.5  {
			if completed = true {
			global.QUEST[qid] = 1
			global.totalquests += 1
			audio_play_sound(snd_newhighscore,10,0)
			
			//Anticheat if reward is too high
			if reward > 500+needed {
				global.cheats = 1
			}
			
			global.creditscurrency += floor(real(reward) * global.creditsmultiplier)
			scr_savestats()
		}}
	}
}