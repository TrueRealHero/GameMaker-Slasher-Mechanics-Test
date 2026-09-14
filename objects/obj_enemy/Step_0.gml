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
    sprite_index = sprite_idle;
    image_speed = 1;
}

// Простейший knockback-заглушка.
if (knockback_speed > 0)
{
    x += knockback_speed;
    knockback_speed = max(0, knockback_speed - 0.5);
}
