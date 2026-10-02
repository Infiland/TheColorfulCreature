if (!timing_is_tick()) exit;
qa_observe_exit();
global.racescore[multiplayerplayer-1] += global.playersleft - 1
global.playersleft -= 1
instance_destroy()
