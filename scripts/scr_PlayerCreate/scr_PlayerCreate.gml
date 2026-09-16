function PlayerCreate(){
    ground = layer_tilemap_get_id("Col");

    hsp = 0;
    vsp = 0;

    jump_speed = -11;
    walkspeed = 4;
    runspeed = 7;

    movement_active = true;
    jump_active = true;

    // Физическое тело не зависит от размера sprite.
    body_width = 20;
    body_height = 40;
    body_bottom_offset = 0;

    facing = 1;
    grounded = false;

    spriteIdle = sIdle;
    spriteRun = sRun;
    spriteJump = sJump;

    spriteAttack1 = sAttack1;
    spriteAttack2 = sAttack2;
    spriteAttack3 = sAttack3;
    spriteAttackSp1 = sAttackSpecial1;

    attack_key = ord("K");

    attack1_active = true;
    attack2_active = true;
    attack3_active = true;
    stinger_active = true;
    hadouken_active = true;
    
    combat_state = CombatState.FREE;
    current_move = undefined;
    move_phase = 0;
    move_timer = 0;
    
    move_hit_registered = false;
    move_hit_targets = [];
    attack_buffer_timer = 0;
    
    charge_timer = 0;
    charge_released = false;
    
    current_damage = 0;
    current_knockback = 0;
    
    combat_move_speed_multiplier = 1;

    input_history = [];
    input_history_max = 24;
    input_frame = 0;

    stinger_direction = 0;

    hp = 100;
    dead = false;
    hurt_timer = 0;
    hurt_source = noone;
    knockback_speed = 0;

    hurtbox = scr_hurtbox_create(id, 0, -27, 35, 40);
}