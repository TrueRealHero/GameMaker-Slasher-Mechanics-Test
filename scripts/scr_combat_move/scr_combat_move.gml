function CombatMove(
    _sprite,
    _startup,
    _active,
    _recovery,
    _damage,
    _knockback
)
{
    return {
        sprite: _sprite,

        startup: _startup,
        active: _active,
        recovery: _recovery,

        damage: _damage,
        knockback: _knockback
    };
}