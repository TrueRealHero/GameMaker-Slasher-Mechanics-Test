function scr_attack_stinger_get_move(_player)
{
    var _move = CombatMove(
        _player.spriteAttackSp1,

        4,  // startup
        3,  // active
        6,  // recovery

        25, // damage
        8,  // knockback

        42, // hitbox offset x
        -27, // hitbox offset y
        55, // hitbox width
        35, // hitbox height

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
    // Они не относятся к геометрии hitbox.
    _move.lunge_speed = 10;
    _move.lunge_duration = 7;
    _move.lunge_remaining = _move.lunge_duration;

    return _move;
}


function scr_combat_get_attack1(_player)
{
    return CombatMove( _player.spriteAttack1,

        3,  // startup
        3,  // active
        6,  // recovery

        10, // damage
        3,  // knockback

        42, // hitbox offset x
        -27, // hitbox offset y
        55, // hitbox width
        35, // hitbox height

        2,  // combo window start
        6,  // combo window end

        scr_combat_get_attack2,

        false, // charge enabled
        0,      // charge max
        1,
        1,
        2, // animation startup frames
        2, // animation active frames
        2  // animation recovery frames
    );
}

function scr_combat_get_attack2(_player)
{
    return CombatMove(_player.spriteAttack2,

        3,  // startup
        3,  // active
        6,  // recovery

        12, // damage
        4,  // knockback

        42, // hitbox offset x
        -27, // hitbox offset y
        55, // hitbox width
        35, // hitbox height

        2,  // combo window start
        6,  // combo window end

        scr_combat_get_attack3,

        false, // charge enabled
        0,      // charge max
        1,
        1,
        1, 3, 2
    );
}

function scr_combat_get_attack3(_player)
{
    return CombatMove(_player.spriteAttack3,

        3,  // startup
        3,  // active
        6,  // recovery

        20, // damage
        7,  // knockback

        42, // hitbox offset x
        -27, // hitbox offset y
        55, // hitbox width
        35, // hitbox height

        0,  // combo window start
        0,  // combo window end

        undefined,

        true, // charge enabled
        30,    // maximum charge
        1.0,
        2.0,
        2, 4, 2
    );
}