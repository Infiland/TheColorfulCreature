function controls_key_input(key,variable){
var bruh = key
switch(bruh) {
default: variable = key break;
case("40"): variable = vk_down break;
case("39"): variable = vk_right break;
case("38"): variable = vk_up break;
case("37"): variable = vk_left break;
case("32"): variable = vk_space break;
case("17"): variable = vk_control break;
case("13"): variable = vk_enter break;
case("16"): variable = vk_shift break;
case("9"): variable = vk_tab break;
case("18"): variable = vk_alt break;
case("188"): variable = ord(",") break;
case("190"): variable = ord(".") break;
case("191"): variable = vk_divide break;
case("8"): variable = vk_backspace break;
}
}