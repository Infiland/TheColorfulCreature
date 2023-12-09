yscale = 1
onplayer = 0
troopshoot = 0
direction = 270
dir = 270
armoredtrooplimit = 2

if global.hardmode = 0 {
if o_kingboss.hp > 0 { cannontroopspawn = 8 }
if o_kingboss.hp > 30 { cannontroopspawn = 7 }
if o_kingboss.hp > 60 { cannontroopspawn = 6 }
if o_kingboss.hp > 90 { cannontroopspawn = 5 }
if o_kingboss.hp > 120 { cannontroopspawn = 4 }
} else {
if o_kingboss.hp > 0 { cannontroopspawn = 10 }
if o_kingboss.hp > 50 { cannontroopspawn = 8 }
if o_kingboss.hp > 100 { cannontroopspawn = 7 }
if o_kingboss.hp > 150 { cannontroopspawn = 5 }
if o_kingboss.hp > 200 { cannontroopspawn = 4 }	
}