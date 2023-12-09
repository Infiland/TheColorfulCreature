/// @description Initialize variables

// Regarding consent request first of all we should select the mode we want to use for.
// You can use debug modes for different geographic locations EEA, NON-EEA, DISABLED.
// You can also use PRODUCTION mode when we are ready to deploy the application.
AdMob_Consent_RequestInfoUpdate(AdMob_Consent_Mode_DEBUG_GEOGRAPHY_EEA);
//AdMob_Consent_RequestInfoUpdate(AdMob_Consent_Mode_DEBUG_GEOGRAPHY_DISABLED)
//AdMob_Consent_RequestInfoUpdate(AdMob_Consent_Mode_DEBUG_GEOGRAPHY_NOT_EEA)
//AdMob_Consent_RequestInfoUpdate(AdMob_Consent_Mode_PRODUCTION)

// This function is here for debug purposes and uses 'AdMob_Consent_GetType' and
// 'AdMob_Consent_GetStatus' to print the current consent Status/Type to the console.
function AdMob_Consent_showDebugInfo()
{
	var consent_type = AdMob_Consent_GetType();
	switch(consent_type)//https://developers.google.com/admob/ump/android/api/reference/com/google/android/ump/ConsentInformation.ConsentType
	{
		// The user gave permission for data to be collected in order to provide personalized ads.
		case AdMob_Consent_Type_PERSONALIZED:
			show_debug_message("GoogleMobilesAds ConsentType: PERSONALIZED")
		break
			
		// The user refused to share data for personalized ads. Ads will be NON PERSONALIZED
		case AdMob_Consent_Type_NON_PERSONALIZED:
			show_debug_message("GoogleMobilesAds ConsentType: NON_PERSONALIZED")
		break			

		// Unable to get the current type of consent provided by the use
		// Note that for EEA users, the type will always be UNKNOWN (known issue) 
		case AdMob_Consent_Type_UNKNOWN:
			show_debug_message("GoogleMobilesAds ConsentType: UNKNOWN")
		break
	}
}