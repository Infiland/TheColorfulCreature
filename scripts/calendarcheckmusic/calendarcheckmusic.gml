function calendarcheckmusic(){
audio_stop_all()
switch(global.calendarmonth) {
case(1): audio_play_sound(m_neoncolor,0,1) break;
case(2): audio_play_sound(m_readyornot,0,1) break;
case(3): audio_play_sound(m_ahoy,0,1) break;
}
}