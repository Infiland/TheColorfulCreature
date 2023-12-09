window_set_cursor(cr_default)
var i = 0;
for(i=0;i<lvlamount;i++) {
var thing = variable_global_get("CERL" + string(i))
}

if thing = 1 {
for(i=0;i<lvlamount;i++) {
variable_global_set("CERL" + string(i), 0)
}} else {
for(i=0;i<lvlamount;i++) {
variable_global_set("CERL" + string(i), 1)
}	}