// Обычная отрисовка игрока.
draw_self();

// DEBUG: текущая melee hitbox.
// Геометрия берётся из текущего CombatMove,
// поэтому визуализация всегда совпадает с реальной проверкой.
if (global.debug)
{
    if (combat_state == CombatState.ATTACK && move_phase == CombatMovePhase.ACTIVE)
    {
        scr_hitbox_debug_draw(id, current_move);
    }
}
