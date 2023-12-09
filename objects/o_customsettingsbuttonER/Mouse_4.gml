if lvl != 0 {
if variable_global_get("CERL"+string(lvl)) = 0 {
variable_global_set("CERL"+string(lvl),1)
} else { variable_global_set("CERL"+string(lvl),0) }
}

if mus != 0 {
if variable_global_get("CERM"+string(mus)) = 0 {
variable_global_set("CERM"+string(mus),1)
} else { variable_global_set("CERM"+string(mus),0) }
}