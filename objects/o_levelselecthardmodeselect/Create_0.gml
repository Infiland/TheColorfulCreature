option = "off"
text = "Press H to change to hardmode: " + string(option)
if global.hardmodeunlock < 1 { instance_destroy() }