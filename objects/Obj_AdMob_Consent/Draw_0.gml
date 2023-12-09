/// @description Draw debug information
/*

// This is for demo purposes and only draws debug information to the screen

var status = ""
// The function 'AdMob_Consent_GetStatus' allows the developer to know if the
// GDPR consent request is required or not or if the user already answered to the
// consent request (OBTAINED).
switch(AdMob_Consent_GetStatus())
{
	case AdMob_Consent_Status_UNKNOWN: status = "UNKNOWN"; break;
	case AdMob_Consent_Status_NOT_REQUIRED: status = "NOT_REQUIRED"; break;
	case AdMob_Consent_Status_REQUIRED: status = "REQUIRED"; break;
	case AdMob_Consent_Status_OBTAINED: status = "OBTAINED"; break;
}

var type = ""

// The function 'AdMob_Consent_GetType' allows the developer to know what was the
// type of consent given by the user. Can the ads be personalized (allowed) or not (rejected).
switch(AdMob_Consent_GetType())
{
	case AdMob_Consent_Type_UNKNOWN: type = "UNKNOWN"; break;
	case AdMob_Consent_Type_NON_PERSONALIZED: type = "NON_PERSONALIZED"; break;
	case AdMob_Consent_Type_PERSONALIZED: type = "PERSONALIZED"; break;
}

//draw_set_font(Font_YoYo_20);
draw_set_valign(fa_top);
draw_set_halign(fa_left);

draw_text(x,y,"Consent Status: " + status);
draw_text(x,y+30,"Consent Type: " + type);

// The function 'AdMob_Consent_IsFormAvailable()' will return either true or false depending
// on whether there is a consent form available or not on this device.
if(AdMob_Consent_IsFormAvailable())
	draw_text(x,y+60,"Consent available");
else
	draw_text(x,y+60,"Consent unavailable");

