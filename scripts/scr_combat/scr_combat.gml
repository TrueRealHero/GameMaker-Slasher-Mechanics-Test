function scr_combat(_player)
{
    switch (_player.combat_state)
    {
        case CombatState.FREE:
            scr_combat_free(_player);
        break;

        case CombatState.ATTACK:
            scr_combat_update_move(_player);
        break;
    }
}

// Послание для ChatGPT: Little Red Hood

function scr_combat_free(_player)
{
    if (
        _player.grounded
        && keyboard_check_pressed(_player.attack_key)
    )
    {
        scr_combat_start_attack(
            _player,
            scr_combat_get_attack1(_player)
        );
    }
}

function scr_combat_get_attack1(_player)
{
    return CombatMove(
        _player.spriteAttack1,

        3,  // startup
        3,  // active
        6,  // recovery

        10, // damage
        3   // knockback
    );
}

function scr_combat_start_attack(_player, _move)
{
    _player.current_move = _move;

    _player.combat_state =
        CombatState.ATTACK;

    _player.move_phase = 0;
    _player.move_timer = 0;

    _player.move_hit_registered = false;

    _player.hsp = 0;
    _player.vsp = 0;

    _player.sprite_index =
        _move.sprite;

    _player.image_index = 0;
    _player.image_speed = 0;
}

function scr_combat_update_move(_player)
{
    var _move = _player.current_move;

    _player.move_timer++;

    // =====================================
    // STARTUP
    // =====================================

    if (_player.move_phase == 0)
    {
        scr_combat_update_animation(
            _player,
            _move
        );

        if (_player.move_timer >= _move.startup)
        {
            _player.move_phase = 1;
            _player.move_timer = 0;
        }

        return;
    }


    // =====================================
    // ACTIVE
    // =====================================

    if (_player.move_phase == 1)
    {
        scr_combat_update_animation(
            _player,
            _move
        );

        scr_combat_process_hitbox(
            _player,
            _move
        );

        if (_player.move_timer >= _move.active)
        {
            _player.move_phase = 2;
            _player.move_timer = 0;
        }

        return;
    }


    // =====================================
    // RECOVERY
    // =====================================

    if (_player.move_phase == 2)
    {
        scr_combat_update_animation(
            _player,
            _move
        );

        if (_player.move_timer >= _move.recovery)
        {
            scr_combat_finish_move(_player);
        }

        return;
    }
}

function scr_combat_update_animation(_player, _move)
{
    var _total_frames =
        _move.startup
        + _move.active
        + _move.recovery;

    var _sprite_frames =
        sprite_get_number(_move.sprite);

    var _progress = 0;

    if (_player.move_phase == 0)
    {
        // Startup
        _progress = _player.move_timer;
    }
    else if (_player.move_phase == 1)
    {
        // Active
        _progress =
            _move.startup
            + _player.move_timer;
    }
    else
    {
        // Recovery
        _progress =
            _move.startup
            + _move.active
            + _player.move_timer;
    }

    var _frame =
        floor(
            (_progress / _total_frames)
            * _sprite_frames
        );

    _player.image_index =
        clamp(
            _frame,
            0,
            _sprite_frames - 1
        );

    _player.image_speed = 0;
}

function scr_combat_process_hitbox(_player, _move)
{
    // =====================================
    // FUTURE HITBOX SYSTEM
    // =====================================
    //
    // Здесь позже будет:
    //
    // 1. Создание / активация hitbox
    // 2. Поиск hurtbox
    // 3. Проверка столкновения
    // 4. Передача damage
    // 5. Knockback
    // 6. Hitstun
    // 7. Launch
    //
    // Пока enemy/hurtbox системы нет.
    // Поэтому только заглушка.
    //

    if (_player.move_hit_registered)
    {
        return;
    }

    // FUTURE:
    // var _target = collision...
    //
    // if (_target != noone)
    // {
    //     scr_combat_apply_hit(...);
    //     _player.move_hit_registered = true;
    // }
}

function scr_combat_finish_move(_player)
{
    _player.current_move = undefined;

    _player.combat_state =
        CombatState.FREE;

    _player.move_phase = 0;
    _player.move_timer = 0;

    _player.move_hit_registered = false;

    _player.image_index = 0;
    _player.image_speed = 1;

    _player.sprite_index =
        _player.spriteIdle;
}

