if !instance_exists(popup) { exit }
var p = popup

switch (role) {
case 0:
	if is_callable(p.cb_ok) { p.cb_ok() }
	break
case 1:
	if is_callable(p.cb_yes) { p.cb_yes() }
	break
case 2:
	if is_callable(p.cb_no) { p.cb_no() }
	break
}

instance_destroy(p)

