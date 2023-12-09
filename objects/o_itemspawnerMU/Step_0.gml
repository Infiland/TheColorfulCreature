if global.pause = 1 { exit }
timer -= 1 * (60 / global.maxfps)
if timer > 45 {maxtimer -= 0.1 * (60 / global.maxfps) }
if timer < 0 {
instance_create(random_range(130,830),-32,choose(o_gunMU,o_spikesMU,o_movingspikesMU,o_mayoneseMU,o_ketchupMU,o_gravity15MU,o_gravity25MU,o_gravity05MU,o_rocketMU))
if room = r_MUSurvival10 {
repeat (irandom_range(2,7)) {
instance_create(random_range(130,830),780,o_rocketMU)
}
}
timer = maxtimer
}