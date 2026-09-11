scr_special_attack(id);
scr_combat(id);

if (!ground_attacking && !special_attacking)
{
    scr_movement(id);
}