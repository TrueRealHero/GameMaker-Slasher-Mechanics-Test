// Движение снаряда.
x += direction_x * pspeed;

// Ограничиваем время жизни снаряда.
life_timer--;

if (life_timer <= 0)
{
    instance_destroy();
}