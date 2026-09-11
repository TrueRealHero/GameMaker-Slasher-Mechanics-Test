function CombatMove(
    _sprite,
    _startup,
    _active,
    _recovery,
    _damage,
    _knockback,
    _combo_window_start,
    _combo_window_end,
    _next_move,
    _charge_enabled,
    _charge_max,
    _charge_min_multiplier,
    _charge_max_multiplier,

    _animation_startup_frames,
    _animation_active_frames,
    _animation_recovery_frames
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

        next_move: _next_move,

        charge_enabled: _charge_enabled,
        charge_max: _charge_max,

        charge_min_multiplier: _charge_min_multiplier,
        charge_max_multiplier: _charge_max_multiplier,

        animation_startup_frames: _animation_startup_frames,
        animation_active_frames: _animation_active_frames,
        animation_recovery_frames: _animation_recovery_frames
    };
}