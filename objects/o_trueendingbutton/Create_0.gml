/// @description Variables
declarecustombutton()
image_xscale = 20
image_yscale = 10
xscale = 0.5
yscale = 0.5
width = 3

if global.hardmodeunlock = 0 {
text = "???"
}
if global.hardmodeunlock = 1 {
text = "Ending"
}
if global.hardmodeunlock > 1 {
text = "True Ending"
}