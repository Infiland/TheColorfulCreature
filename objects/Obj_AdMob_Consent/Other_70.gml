/// @description AdMob event handlers

// We do an early exit if the 'async_load' map doesn't contain a "type" key.
if(!ds_map_exists(async_load, "type"))
	exit;

//show_debug_message("AdMob: " + json_encode(async_load));

switch(async_load[? "type"])
{
	// AdMob_Consent_RequestInfoUpdate succeeded
	case "AdMob_Consent_OnRequestInfoUpdated":
		// At this point the extension succeeded on selecting consent mode.
		// We use this event to query the current consent status, if GDPR consent
		// is required (AdMob_Consent_Status_REQUIRED) then we start loading the consent form.
		if(AdMob_Consent_GetStatus() == AdMob_Consent_Status_REQUIRED)//https://developers.google.com/admob/ump/android/api/reference/com/google/android/ump/ConsentInformation.ConsentStatus.html#REQUIRED
			AdMob_Consent_Load();
		else
			AdMob_Consent_showDebugInfo();
	break
	
	// AdMob_Consent_RequestInfoUpdate failed
	case "AdMob_Consent_OnRequestInfoUpdateFailed":
		// At this point the extension failed to select consent mode.
	break
	
	// AdMob_Consent_Load succeeded
	case "AdMob_Consent_OnLoaded":
		// At this point the consent form loaded successfully.
		// We uses this event to show the consent to the user.
		AdMob_Consent_Show()
	break
	
	// AdMob_Consent_Load failed
	case "AdMob_Consent_OnLoadFailed":
		// At this point there was a problem loading the consent form.
	break
	
	// AdMob_Consent_Show succeeded & user answered
	case "AdMob_Consent_OnShown":
		// At this point the user already saw and answered the consent request so we can
		// process the results.
		AdMob_Consent_showDebugInfo();
	break
	
	case "AdMob_Consent_OnShowFailed":
		// At this point there was a problem showing the consent form.
	break
}
