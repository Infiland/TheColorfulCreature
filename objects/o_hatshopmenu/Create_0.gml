selectedhat = 0
RLselectedhat = 0
if platform_mobile() {
selectedhat = -1
RLselectedhat = -1
}
press = 0
holdcooldown = 40
dis = 0
arrowyscale = 1
change = 0

//Hardcoded lol
limithat = global.totalhatsAM-3

ui_arrow_yscale = arrowyscale;
timing_ui_register_target("hat-carousel");
