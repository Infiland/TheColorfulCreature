var i = 1,m = 0

for(i = 1;i<=12;i++) {
	if i = 5 { m = 1 }
	if i = 9 { m = 2 }
	var monthbutton = instance_create((-24+i*181)-(m*724),225+m*101,o_monthbuttonC)
	with monthbutton {
	month = i
}
}

//instance_destroy()