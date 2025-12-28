if global.choosesettings != 5 { exit }

global.language = language

switchlang()

if instance_exists(o_animatedtext) {
o_animatedtext.text = loc("CHANGE_LANGUAGES")
}

scr_savesettings()