if (target != noone && instance_exists(target)) {
    if (target.hp < prev_hp) {
        flash_alpha = 1;
        shake = 5;
    }
    
    target_hp = target.hp;
    target_maxhp = target.maxhp;
    prev_hp = target_hp;
    
    flash_alpha = max(0, flash_alpha - 0.05);
    shake = max(0, shake - 0.5);
} else {
    instance_destroy();
}
