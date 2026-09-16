// Получение урона временно блокирует управление игроком.
if (hurt_timer > 0)
{
    hurt_timer--;

    // Knockback игрока обрабатывается через ту же низкоуровневую
    // систему движения, что используется другими сущностями.
    hsp = knockback_speed;
    scr_movement_move_horizontal(id);

    knockback_speed = approach(knockback_speed, 0, 0.5);

    sprite_index = sHurt;
    image_index = 0;
    image_speed = 0;

    scr_movement_gravity(id);
    scr_movement_vertical_collision(id);

    exit;
}

scr_input_history_update(id);
scr_combat(id);

if (combat_state == CombatState.FREE)
{
    scr_movement(id);
}
else if (
    combat_state == CombatState.ATTACK
    && current_move.charge_enabled
    && move_phase == CombatMovePhase.CHARGE
    && charge_released == false
)
{
    scr_movement(id);
}
