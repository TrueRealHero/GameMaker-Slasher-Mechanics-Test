draw_self();

if (global.debug)
{
    // =========================
    // AI debug
    // =========================

    var _state_name = "IDLE";

    switch (ai_state)
    {
        case EnemyAIState.IDLE:
            _state_name = "IDLE";
        break;

        case EnemyAIState.CHASE:
            _state_name = "CHASE";
        break;

        case EnemyAIState.ATTACK:
            _state_name = "ATTACK";
        break;
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text(x - 45, y - 90, _state_name);

    // Current attack hitbox.
    if (ai_state == EnemyAIState.ATTACK && current_move != undefined)
    {
        if (move_phase == CombatMovePhase.ACTIVE)
        {
            var _hitbox_left = x + (current_move.hitbox_offset_x * facing) - current_move.hitbox_width / 2;
            var _hitbox_top = y + current_move.hitbox_offset_y - current_move.hitbox_height / 2;
            var _hitbox_right = _hitbox_left + current_move.hitbox_width;
            var _hitbox_bottom = _hitbox_top + current_move.hitbox_height;

            draw_set_alpha(0.35);
            draw_rectangle(
                _hitbox_left,
                _hitbox_top,
                _hitbox_right,
                _hitbox_bottom,
                false
            );
            draw_set_alpha(1);
        }
    }

    // Detection range.
    draw_set_alpha(0.15);
    draw_ellipse(
        x - detection_range,
        y - detection_range,
        x + detection_range,
        y + detection_range,
        false
    );
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
