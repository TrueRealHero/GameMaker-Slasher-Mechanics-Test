function scr_attack_stinger_get_move(_player)
{
    return CombatMove(
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
}