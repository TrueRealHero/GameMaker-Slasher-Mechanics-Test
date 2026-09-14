// Создаем enums для состояний и фаз атак
enum CombatState
{
    FREE,
    ATTACK
}

enum CombatMovePhase
{
    CHARGE_CHECK,
    CHARGE,
    STARTUP,
    ACTIVE,
    RECOVERY
}

// Создаем комбат систему
function scr_combat(_player)
{
    // Специальные команды распознаём только в FREE.
    // Текущую атаку они не перебивают.
    if (_player.combat_state == CombatState.FREE)
    {
        var _command = scr_input_command_get(_player);
        
        if (_command.type == InputCommand.HADOUKEN)
        {
            // K уже использован как часть специальной команды.
            scr_input_history_consume_until(_player, _command.frame);
            _player.attack_buffer_timer = 0;
            
            scr_fire_ball_create(_player);
            
            show_debug_message("HADOUKEN");
            
            return;
        }

        if (_command.type == InputCommand.STINGER)
        {
            _player.stinger_direction = _command.direction;
            _player.facing = _command.direction;
            _player.image_xscale = _player.facing;

            // Убираем использованные события из истории.
            scr_input_history_consume_until(_player, _command.frame);

            // K уже использован как часть Stinger.
            _player.attack_buffer_timer = 0;

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
    // Нажали K — запоминаем ввод для обычной атаки.
    if (keyboard_check_pressed(_player.attack_key))
    {
        _player.attack_buffer_timer = 6;
    }

    // Уменьшаем время хранения ввода.
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


function scr_combat_start_attack(_player, _move)
{
    _player.current_move = _move;

    _player.combat_state = CombatState.ATTACK;

    if (_move.charge_enabled)
    {
        _player.move_phase = CombatMovePhase.CHARGE_CHECK;
    }
    else
    {
        _player.move_phase = CombatMovePhase.STARTUP;
    }

    _player.move_timer = 0;

    // Список целей очищается для каждой новой атаки.
    _player.move_hit_targets = [];
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

    if (
        keyboard_check(_player.attack_key) && _player.charge_released == false
    )
    {
        _player.charge_timer++;

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

function scr_combat_update_lunge(_player, _move)
{
    if (variable_struct_exists(_move, "lunge_remaining") == false)
    {
        return;
    }

    if (_move.lunge_remaining <= 0)
    {
        return;
    }

    _player.hsp = _player.stinger_direction * _move.lunge_speed;

    scr_movement_move_horizontal(_player);

    _move.lunge_remaining--;
}

function scr_combat_update_move(_player)
{
    var _move = _player.current_move;

    _player.move_timer++;

    if (_player.move_phase == CombatMovePhase.CHARGE_CHECK)
    {
        _player.sprite_index = _move.sprite;
        _player.image_index = 0;
        _player.image_speed = 0;

        if (keyboard_check(_player.attack_key) == false)
        {
            _player.combat_move_speed_multiplier = 1;
            _player.move_phase = CombatMovePhase.STARTUP;
            _player.move_timer = 0;

            return;
        }

        if (_player.move_timer >= 30)
        {
            _player.move_phase = CombatMovePhase.CHARGE;
            _player.move_timer = 0;
            _player.charge_timer = 0;
            _player.charge_released = false;

            _player.combat_move_speed_multiplier = 0.35;

            _player.sprite_index = _move.sprite;
            _player.image_index = 0;
            _player.image_speed = 0;

            show_debug_message( "ATTACK 3 CHARGE STARTED" );
        }

        return;
    }

    if (_player.move_phase == CombatMovePhase.CHARGE)
    {
        _player.combat_move_speed_multiplier = 0.35;

        _player.sprite_index = _move.sprite;
        _player.image_index = 0;
        _player.image_speed = 0;

        if (scr_combat_update_charge(_player, _move))
        {
            _player.combat_move_speed_multiplier = 1;
            _player.move_phase = CombatMovePhase.STARTUP;
            _player.move_timer = 0;
        }

        return;
    }

    if (_player.move_phase == CombatMovePhase.STARTUP)
    {
        scr_combat_update_animation( _player, _move );
        scr_combat_update_lunge( _player, _move );

        if (_player.move_timer >= _move.startup)
        {
            _player.move_phase = CombatMovePhase.ACTIVE;
            _player.move_timer = 0;
        }

        return;
    }

    if (_player.move_phase == CombatMovePhase.ACTIVE)
    {
        scr_combat_update_animation( _player, _move );
        scr_combat_update_lunge( _player, _move );
        scr_combat_process_hitbox( _player, _move );

        if (_player.move_timer >= _move.active)
        {
            _player.move_phase = CombatMovePhase.RECOVERY;
            _player.move_timer = 0;
        }

        return;
    }

    if (_player.move_phase == CombatMovePhase.RECOVERY)
    {
        scr_combat_update_animation( _player, _move );

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

    if (_player.move_phase == CombatMovePhase.STARTUP)
    {
        _frame_start = 0;
        _frame_count = _move.animation_startup_frames;
        _phase_progress = _player.move_timer;
        _phase_duration = _move.startup;
    }
    else if (_player.move_phase == CombatMovePhase.ACTIVE)
    {
        _frame_start = _move.animation_startup_frames;
        _frame_count = _move.animation_active_frames;
        _phase_progress = _player.move_timer;
        _phase_duration = _move.active;
    }
    else if (_player.move_phase == CombatMovePhase.RECOVERY)
    {
        _frame_start = _move.animation_startup_frames + _move.animation_active_frames;
        _frame_count = _move.animation_recovery_frames;
        _phase_progress = _player.move_timer;
        _phase_duration = _move.recovery;
    }

    var _phase_ratio = _phase_progress / _phase_duration;
    _phase_ratio = clamp(_phase_ratio, 0, 0.9999);

    var _local_frame = floor( _phase_ratio * _frame_count );
    var _frame = _frame_start + _local_frame;

    _player.image_index = _frame;
    _player.image_speed = 0;
}

function scr_combat_process_hitbox(_player, _move)
{
    // Hitbox существует только во время ACTIVE.
    // Сама проверка находится в отдельном модуле.
    scr_hitbox_attack(_player, _move);
}

function scr_combat_finish_move(_player)
{
    _player.current_move = undefined;
    _player.combat_state = CombatState.FREE;
    _player.move_phase = CombatMovePhase.STARTUP;
    _player.move_timer = 0;
    _player.move_hit_registered = false;
    _player.move_hit_targets = [];
    _player.charge_timer = 0;
    _player.charge_released = false;
    _player.current_damage = 0;
    _player.current_knockback = 0;
    _player.combat_move_speed_multiplier = 1;
    _player.image_index = 0;
    _player.image_speed = 1;
    _player.sprite_index = _player.spriteIdle;
}
