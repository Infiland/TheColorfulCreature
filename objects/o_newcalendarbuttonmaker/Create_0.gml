var i,w;

for(w = 0;w<=0;w++) {
for(i = 0;i<=6;i++) {
var level = instance_create(40+i*117,280+w*128,o_newcalendarlevel)
with level {
text = "Day\n" + string((i + 1)+7*w)
day = 1+(i+(7*w))
week = w+1
}
}}

instance_destroy()