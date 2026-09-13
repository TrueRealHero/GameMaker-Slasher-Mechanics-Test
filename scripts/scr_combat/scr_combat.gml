function scr_combat(_player)
{
    // Stinger проверяется только когда игрок свободен.
    // Во время обычной атаки он не перебивает текущий move.
    if (_player.combat_state == CombatState.FREE)
    {
        if (scr_attack_stinger_update_input(_player))
        {
            scr_combat_start_attack(
                _player,
                scr_attack_stinger_get_move(_player)
            );

            return;
        }
    }

    scr_combat_update_input_buffer(_player);

    switch (_player.combat_state)
    {
        case CombatState.FREE: scr_combat_free(_player);
        break;

        case CombatState.ATTACK: scr_combat_update_move(_player);
        break;
    }
}

function scr_combat_update_input_buffer(_player)
{
    // Нажали K — запоминаем ввод
    if (keyboard_check_pressed(_player.attack_key))
    {
        _player.attack_buffer_timer = 6;
    }

    // Уменьшаем время хранения ввода
    if (_player.attack_buffer_timer > 0)
    {
        _player.attack_buffer_timer--;
    }
}

function scr_combat_free(_player)
{
    if (
        _player.grounded && _player.attack_buffer_timer > 0
    )
    {
        _player.attack_buffer_timer = 0;

        scr_combat_start_attack( _player, scr_combat_get_attack1(_player) );
    }
}

function scr_combat_get_attack1(_player)
{
    return CombatMove( _player.spriteAttack1,

        3,  // startup
        3,  // active
        6,  // recovery

        10, // damage
        3,  // knockback

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

function scr_combat_start_attack(_player, _move)
{
    _player.current_move = _move;

    _player.combat_state = CombatState.ATTACK;

    // Заряжаемый Attack 3 сначала проходит проверку:
    // игрок должен удерживать K достаточно долго,
    // чтобы перейти в настоящий CHARGE.
    if (_move.charge_enabled)
    {
        _player.move_phase = CombatMovePhase.CHARGE_CHECK;
    }
    else
    {
        _player.move_phase = CombatMovePhase.STARTUP;
    }

    _player.move_timer = 0;

    _player.move_hit_registered = false;
    _player.charge_timer = 0;
    _player.charge_released = false;
    
    _player.current_damage = _move.damage;
    _player.current_knockback = _move.knockback;

    _player.hsp = 0;
    _player.vsp = 0;

    _player.sprite_index = _move.sprite;

    _player.image_index = 0;
    _player.image_speed = 0;
}

function scr_combat_update_charge(_player, _move)
{
    if (_move.charge_enabled == false)
    {
        return false;
    }

    // Игрок продолжает удерживать K
    if (
        keyboard_check(_player.attack_key) && _player.charge_released == false
    )
    {
        _player.charge_timer++;

        // Ограничиваем максимальный заряд
        if (_player.charge_timer >= _move.charge_max)
        {
            _player.charge_timer = _move.charge_max;

            _player.charge_released = true;

            scr_combat_apply_charge( _player, _move );

            show_debug_message( "ATTACK 3 MAX CHARGE" );

            return true;
        }

        return false;
    }

    // Кнопку отпустили
    if (_player.charge_released == false)
    {
        _player.charge_released = true;

        scr_combat_apply_charge( _player, _move );

        show_debug_message( "ATTACK 3 RELEASED" );

        return true;
    }

    return false;
}

function scr_combat_apply_charge(_player, _move)
{
    var _charge_ratio = _player.charge_timer / _move.charge_max;

    _charge_ratio = clamp( _charge_ratio, 0, 1 );

    var _multiplier = lerp( _move.charge_min_multiplier, _move.charge_max_multiplier,
            _charge_ratio );

    _player.current_damage = _move.damage * _multiplier;

    _player.current_knockback = _move.knockback * _multiplier;

    show_debug_message(
        "CHARGE RATIO: "
        + string(_charge_ratio)
        + " | DAMAGE: "
        + string(_player.current_damage)
        + " | KNOCKBACK: "
        + string(_player.current_knockback)
    );
}



//////////////////////////////////




function scr_combat_update_move(_player)
{
    var _move = _player.current_move;

    _player.move_timer++;


    // =====================================
    // CHARGE CHECK
    // =====================================

    if (_player.move_phase == CombatMovePhase.CHARGE_CHECK)
    {
        // Тот же самый спрайт, что и у Attack 3.
        // Пока проверяем намерение игрока — показываем первый кадр.
        _player.sprite_index = _move.sprite;
        _player.image_index = 0;
        _player.image_speed = 0;

        // Отпустили K раньше 0.5 секунды:
        // это обычный третий удар без заряда.
        if (keyboard_check(_player.attack_key) == false)
        {
            _player.combat_move_speed_multiplier = 1;
            _player.move_phase = CombatMovePhase.STARTUP;
            _player.move_timer = 0;

            return;
        }

        // 30 кадров при 60 FPS = примерно 0.5 секунды.
        // Если K всё это время удерживается — начинаем настоящий charge.
        if (_player.move_timer >= 30)
        {
            _player.move_phase = CombatMovePhase.CHARGE;
            _player.move_timer = 0;
            _player.charge_timer = 0;
            _player.charge_released = false;

            _player.combat_move_speed_multiplier = 0.35;

            // Charge использует тот же Attack 3 sprite.
            _player.sprite_index = _move.sprite;
            _player.image_index = 0;
            _player.image_speed = 0;

            show_debug_message( "ATTACK 3 CHARGE STARTED" );
        }

        return;
    }


    // =====================================
    // CHARGE
    // =====================================

    if (_player.move_phase == CombatMovePhase.CHARGE)
    {
        _player.combat_move_speed_multiplier = 0.35;

        // Charge использует тот же спрайт Attack 3.
        _player.sprite_index = _move.sprite;
        _player.image_index = 0;
        _player.image_speed = 0;

        if (scr_combat_update_charge(_player, _move))
        {
            _player.combat_move_speed_multiplier = 1;

            // Charge завершён.
            // Переходим в startup обычной боевой временной шкалы.
            _player.move_phase = CombatMovePhase.STARTUP;

            _player.move_timer = 0;
        }

        return;
    }


    // =====================================
    // STARTUP
    // =====================================

    if (_player.move_phase == CombatMovePhase.STARTUP)
    {
        scr_combat_update_animation( _player, _move );

        if (_player.move_timer >= _move.startup)
        {
            _player.move_phase = CombatMovePhase.ACTIVE;

            _player.move_timer = 0;
        }

        return;
    }


    // =====================================
    // ACTIVE
    // =====================================

    if (_player.move_phase == CombatMovePhase.ACTIVE)
    {
        scr_combat_update_animation( _player, _move );

        scr_combat_process_hitbox( _player, _move );

        if (_player.move_timer >= _move.active)
        {
            _player.move_phase = CombatMovePhase.RECOVERY;
            _player.move_timer = 0;
        }

        return;
    }


    // =====================================
    // RECOVERY
    // =====================================

    if (_player.move_phase == CombatMovePhase.RECOVERY)
    {
        scr_combat_update_animation( _player, _move );

        // Combo window
        if (
            _player.move_timer >= _move.combo_window_start
            && _player.move_timer <= _move.combo_window_end
        )
        {
            if (
                _player.attack_buffer_timer > 0
                && is_undefined(_move.next_move) == false
            )
            {
                _player.attack_buffer_timer = 0;

                var _next_move = _move.next_move(_player);

                scr_combat_start_attack( _player, _next_move );

                return;
            }
        }

        if (_player.move_timer >= _move.recovery)
        {
            scr_combat_finish_move(_player);
        }

        return;
    }
}

function scr_combat_update_animation(_player, _move)
{
    var _frame_start = 0;
    var _frame_count = 0;
    var _phase_progress = 0;
    var _phase_duration = 0;


    // =====================================
    // STARTUP
    // =====================================

    if (_player.move_phase == CombatMovePhase.STARTUP)
    {
        _frame_start = 0;
        _frame_count = _move.animation_startup_frames;

        _phase_progress = _player.move_timer;
        _phase_duration = _move.startup;
    }


    // =====================================
    // ACTIVE
    // =====================================

    else if (_player.move_phase == CombatMovePhase.ACTIVE)
    {
        _frame_start = _move.animation_startup_frames;

        _frame_count = _move.animation_active_frames;

        _phase_progress = _player.move_timer;

        _phase_duration = _move.active;
    }

    // =====================================
    // RECOVERY
    // =====================================

    else if (_player.move_phase == CombatMovePhase.RECOVERY)
    {
        _frame_start = _move.animation_startup_frames + _move.animation_active_frames;

        _frame_count = _move.animation_recovery_frames;

        _phase_progress = _player.move_timer;

        _phase_duration = _move.recovery;
    }


    // =====================================
    // CALCULATE FRAME
    // =====================================

    var _phase_ratio = _phase_progress / _phase_duration;

    _phase_ratio = clamp(_phase_ratio, 0, 0.9999);

    var _local_frame = floor( _phase_ratio * _frame_count );

    var _frame = _frame_start + _local_frame;


    _player.image_index = _frame;
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

    _player.combat_state = CombatState.FREE;

    _player.move_phase = CombatMovePhase.STARTUP;
    _player.move_timer = 0;

    _player.move_hit_registered = false;

    _player.charge_timer = 0;
    _player.charge_released = false;

    _player.current_damage = 0;
    _player.current_knockback = 0;

    _player.combat_move_speed_multiplier = 1;

    _player.image_index = 0;
    _player.image_speed = 1;

    _player.sprite_index =
    _player.spriteIdle;
}