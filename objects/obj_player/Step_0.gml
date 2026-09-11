scr_combat(id);

if (combat_state == CombatState.FREE)
{
    scr_movement(id);
}
else if (
    combat_state == CombatState.ATTACK
    && current_move.charge_enabled
    && move_phase == 0
    && charge_released == false
)
{
    scr_movement(id);
}