if (dead)
{
    instance_destroy();
    exit;
}

// Реакция на попадание.
if (hurt_timer > 0)
{
    hurt_timer--;

    sprite_index = sprite_hurt;
    image_index = 0;
    image_speed = 0;
}
else
{
    // AI управляет состоянием и атакой.
    scr_enemy_ai(id);
}

// Физика работает отдельно от AI.
scr_enemy_physics(id);

// Обычная визуальная анимация врага.
if (hurt_timer <= 0 && ai_state != EnemyAIState.ATTACK)
{
    if (!grounded)
    {
        sprite_index = sprite_jump;
        image_speed = 1;
    }
    else if (hsp != 0)
    {
        sprite_index = sprite_run;
        image_speed = 1;
    }
    else
    {
        sprite_index = sprite_idle;
        image_speed = 1;
    }
}
