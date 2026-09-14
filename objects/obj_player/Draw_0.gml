// Обычная отрисовка игрока.
draw_self();

// DEBUG: текущая melee hitbox.
// Показываем её только в ACTIVE-фазе, когда combat действительно
// проверяет попадание.
if (combat_state == CombatState.ATTACK && move_phase == CombatMovePhase.ACTIVE)
{
    var _offset_x = 42 * facing;
    var _offset_y = -27;
    var _width = 55;
    var _height = 35;

    var _left = x + _offset_x - _width * 0.5;
    var _top = y + _offset_y - _height * 0.5;
    var _right = _left + _width;
    var _bottom = _top + _height;

    draw_set_alpha(0.45);
    draw_set_color(c_red);
    draw_rectangle(_left, _top, _right, _bottom, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
