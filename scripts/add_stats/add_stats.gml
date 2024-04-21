// Function for increasing statistics and quest statistics
function increase_stat(normalstat,queststat,amm) {
	
	//Normal Stat
	if variable_global_exists(normalstat) {
		var nS = variable_global_get(normalstat)
		variable_global_set(normalstat,nS+amm)
	} else {
		show_debug_message(normalstat + " does not exist!")
	}
	
	//Quest Stat
	if variable_global_exists(queststat) {
		var qS = variable_global_get(queststat)
		variable_global_set(queststat,qS+amm)
	} else {
		show_debug_message(queststat + " does not exist!")
	}
}