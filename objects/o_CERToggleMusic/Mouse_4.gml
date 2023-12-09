window_set_cursor(cr_default)
var i = 0;
for(i=0;i<musamount;i++) {
var thing = variable_global_get("CERM" + string(i))
}

if thing = 1 {
for(i=0;i<musamount;i++) {
variable_global_set("CERM" + string(i), 0)
}} else {
for(i=0;i<musamount;i++) {
variable_global_set("CERM" + string(i), 1)
}	}