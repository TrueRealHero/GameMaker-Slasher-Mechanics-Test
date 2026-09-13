function scr_attack_stinger_get_move(_player)
{
    var _move = CombatMove(
        _player.spriteAttackSp1,

        4,  // startup
        3,  // active
        6,  // recovery

        25, // damage
        8,  // knockback

        0,  // combo window start
        0,  // combo window end

        undefined,

        false, // charge enabled
        0,
        1,
        1,

        1, // animation startup frames
        1, // animation active frames
        1  // animation recovery frames
    );

    // Дополнительные параметры именно Stinger.
    // Они не нужны обычным атакам, поэтому не добавляем их в CombatMove.
    _move.lunge_speed = 10;
    _move.lunge_duration = 7;
    _move.lunge_remaining = _move.lunge_duration;

    return _move;
}