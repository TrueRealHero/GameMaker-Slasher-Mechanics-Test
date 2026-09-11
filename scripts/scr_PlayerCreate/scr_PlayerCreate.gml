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
     
     // Клавиша
     attack_key = ord("K");
    
    combat_state = CombatState.FREE;
     current_move = undefined;
     move_phase = 0;
     move_timer = 0;
    move_hit_registered = false;
    
    
}