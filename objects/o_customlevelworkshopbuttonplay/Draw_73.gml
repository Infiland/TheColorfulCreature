y = lerp(y,ystart - global.customlevelsscroll,0.1 * (60 / global.maxfps))
//var owner = steam_get_user_persona_name(mOwner)
//var directory = global.workshopfolder + "\\"
if y < -90 {
exit;
}
if y > 900 {
exit;
}

if mPubFileId = 0 {
image_blend = c_red	
} else { image_blend = c_white }

//draw_self()
draw_rectangle_color(room_width/2-200,y,room_width/2+200,y+90,c_black,$1d1d1d,c_black,$1d1d1d,false)
draw_rectangle_color(room_width/2-200,y,room_width/2+200,y+90,c_white,c_white,c_white,c_white,true)
draw_set_color(c_white)
draw_set_font(global.deathfont)

draw_set_halign(fa_center)
if mBanned = false {
draw_text_ext(room_width/2,y+2,string(mTitle),20,300)
//draw_text(x+5,y+22,"Made by: " + string(mName))
draw_text(room_width/2,y+42,loc(653) +" " + string(ownername))
draw_text_scribble(room_width/2,y+62,"[s_likeemote]" + string(mLikes) + "  [s_dislikeemote]" + string(mDislikes))
} else {
draw_text(room_width/2,y+7,string(mTitle))
draw_set_color(c_red)
draw_text(room_width/2,y+32,loc(654))
}

if mFeatured = true {
draw_sprite(s_featuredstar,0,x-100,y)	
}

draw_set_color(c_white)

//Medals
var dmedal = requiredtime

var gmedal = dmedal * 1.1
var smedal = gmedal * 1.2
var bmedal = smedal * 1.3
var spr_num = 3

if time < bmedal { spr_num = 0 }
if time < smedal { spr_num = 1 }
if time < gmedal { spr_num = 2 }
if time < dmedal { spr_num = 3 }

	if time < bmedal { 
	 draw_sprite_ext(s_medals,spr_num,x+250,y+35,0.07,0.07,0,c_white,1)
	 draw_text(x+250,y+10,string(time))
 }
 
 //Difficulty
 var diffspr = noone
  var sprnum = 0
 for(var i=0;i<difficulty;i++) {
	 switch(difficulty) {
	case(1): diffspr = s_playerwhite break; 
	case(2): diffspr = s_playerblue break; 
	case(3): diffspr = s_playergreen break; 
	case(4): diffspr = s_playeryellow break; 
	case(5): diffspr = s_playerred break; 
	case(6): diffspr = s_playerdead 
	draw_set_color(c_red) 
	sprnum = 5
	break; 
	 }
	 
    draw_sprite_ext(diffspr,sprnum,x-(95-(i*25)),y+65,0.7,0.7,0,c_white,1)
 }
 
 if difficulty = 0 {
	 draw_text_transformed(x-55,y+70,loc(655),0.6,0.6,0)
 } else {
	 draw_text_transformed(x-50,y+42,loc(656),0.8,0.8,0)
 }
 
 draw_set_color(c_white)
 
 
 //draw_text(x,y,time)
  //draw_text(x,y+30,requiredtime)



//draw_text(x+5,y+72,"id: " + string(mPubFileId))


/*directory = string_replace_all(directory,"\\","/")
draw_text(32,650,"Directory: " + string(directory))
if directory_exists(directory) {
draw_text(32,700,"yes")
} else {
draw_text(32,700,"no")	
}

//draw_text(32,650,mPath)
//draw_text(32,670,mPubFileId)