function PlayerCreate(){
    //room_speed = 10
     
     ground = layer_tilemap_get_id("Col");
     
     hsp = 0;
     vsp = 0;
     
     jump_speed = -11;
     walkspeed = 4;
     runspeed = 7;
     
     facing = 1;
     grounded = false;
     
     spriteIdle = sIdle;
     spriteRun = sRun;
     spriteJump = sJump;
     
     spriteAttack1 = sAttack1;
     spriteAttack2 = sAttack2;
     spriteAttack3 = sAttack3;
     spriteAttackSp1 = sAttackSpecial1;
     
     // ==========================================
     // GROUND COMBAT
     // ==========================================
     
     ground_attacking = false;
     ground_attack_stage = 0;
     
     // Текущие таймеры
     ground_attack_timer = 0;
     ground_combo_timer = 0;
     
     // Текущая скорость атаки
     ground_attack_speed = 1;
     
     // Ввод следующей атаки
     ground_attack_queued = false;
     
     // Клавиша
     attack_key = ord("K");
     
     
     // ==========================================
     // НАСТРОЙКИ АТАК
     // ==========================================
     
     // Attack 1
     ground_attack1_speed = 1.0;
     ground_attack1_combo_window = 10;
     
     // Attack 2
     ground_attack2_speed = 1.0;
     ground_attack2_combo_window = 15;
     
     // Attack 3
     ground_attack3_speed = 1.0;
     ground_attack3_combo_window = 0;
     
     // ==========================================
     // ATTACK 3 CHARGE
     // ==========================================
     
     ground_charging = false;
     
     ground_charge_timer = 0;
     ground_max_charge = 60;
     
     // Скорость движения во время зарядки
     ground_charge_move_speed = 1;
     
     /// ==========================================
     /// SPECIAL ATTACKS
     /// ==========================================
     
     special_attacking = false;
     
     // Stinger movement
     stinger_speed = 6;
     stinger_duration = 20;
     stinger_timer = 0;
     stinger_direction = 1;
     
     // Double tap
     last_direction = 0;
     last_direction_timer = 0;
     double_tap_window = 10;
     
     // Attack input after double tap
     stinger_ready = false;
     stinger_attack_timer = 0;
     stinger_attack_window = 10;
}