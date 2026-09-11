function CombatMove(
    _sprite,
    _startup,
    _active,
    _recovery,
    _damage,
    _knockback,
    _combo_window_start,
    _combo_window_end,
    _next_move
)
{
    return {
        sprite: _sprite,

        startup: _startup,
        active: _active,
        recovery: _recovery,

        damage: _damage,
        knockback: _knockback,

        combo_window_start: _combo_window_start,
        combo_window_end: _combo_window_end,

        next_move: _next_move
    };
}