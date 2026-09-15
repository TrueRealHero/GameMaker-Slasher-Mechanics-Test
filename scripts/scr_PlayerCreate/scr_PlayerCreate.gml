function PlayerCreate(){
    //room_speed = 10
     
    ground = layer_tilemap_get_id("Col");
     
    hsp = 0;
    vsp = 0;
     
    jump_speed = -11;
    walkspeed = 4;
    runspeed = 7;

    // Movement features
    // Главный переключатель пользовательского управления движением.
    movement_active = true;

    // Отдельный переключатель прыжка.
    // Позже сюда можно будет добавлять другие механики:
    // dash_active, roll_active и т.д.
    jump_active = true;
     
    facing = 1;
    grounded = false;
    
    spriteIdle = sIdle;
    spriteRun = sRun;
    spriteJump = sJump;
     
    spriteAttack1 = sAttack1;
    spriteAttack2 = sAttack2;
    spriteAttack3 = sAttack3;
    spriteAttackSp1 = sAttackSpecial1;
     
    // Клавиша
    attack_key = ord("K");
    
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

    // Input History
    input_history = [];
    input_history_max = 24;
    input_frame = 0;

    stinger_direction = 0;
}