image_index = game - 1

switch(image_index) {
default: //Asteroids ++
link = "https://store.steampowered.com/app/2407300/Asteroids/" 
break;
case(1): //Monophobia Echoes
link = "https://infiland.itch.io/monophobia-echoes"
break;
case(2): //Brik Brik
link = "https://play.google.com/store/apps/details?id=com.infiland.brikbrik"
break;
}

draw_self()
//draw_set_font(fnt_multiplayerfont)
//draw_text(x+25,y-20,"NEW GAMES IN\nDEVELOPMENT")