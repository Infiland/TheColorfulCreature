function setLanguageDependingOnRegion(){

var lang = 0
	switch (os_get_region()) {
	default: lang = 0 break; //EN, US, and default
	case "DE": lang = 1 break; //German
	case "AT": lang = 1 break; //German - Austria
	case "CH": lang = 1 break; //German - Switzerland
	case "FR": lang = 2 break; //French
    case "IT": lang = 3 break; //Italian
	case "ES": lang = 4 break; //Spanish
	case "HU": lang = 5 break; //Hungary
	case "TR": lang = 6 break; //Turkish
	case "BA": lang = 7 break; //Bosnian
	case "HR": lang = 7 break; //Croatian
	case "ME": lang = 7 break; //Montenegro
	case "PT": lang = 8 break; //Portuguese
	case "CZ": lang = 9 break; //Czech
	case "CN": lang = 10 break; //China
	//case "TW": lang = 10 break; //Taiwan
	//case "ZH": lang = 10 break; //China
	case "SI": lang = 11 break; //Slovenia
	case "UA": lang = 12 break; //Ukraine
	case "MK": lang = 15 break; //Macedonia
	case "RS": lang = 16 break; //Serbian
}
return lang;
}