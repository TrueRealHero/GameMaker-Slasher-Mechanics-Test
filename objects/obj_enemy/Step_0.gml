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
// Поэтому враг продолжает падать и сталкиваться с землёй,
// даже когда AI ничего не делает.
scr_enemy_physics(id);

// Если враг не атакует, возвращаем обычную анимацию.
if (ai_state != EnemyAIState.ATTACK && hurt_timer <= 0)
{
    if (hsp != 0)
    {
        sprite_index = sprite_idle;
        image_speed = 1;
    }
    else
    {
        sprite_index = sprite_idle;
        image_speed = 1;
    }
}
