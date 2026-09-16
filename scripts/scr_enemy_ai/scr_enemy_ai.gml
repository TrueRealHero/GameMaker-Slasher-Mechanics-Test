/// scr_enemy_ai
/// Базовый AI врага.
/// IDLE -> CHASE -> ATTACK.
/// Прыжок используется только для преодоления препятствия впереди.

enum EnemyAIState
{
    IDLE,
    CHASE,
    ATTACK
}

function scr_enemy_ai(_enemy)
{
    if (_enemy.attack_cooldown > 0) _enemy.attack_cooldown--;
    if (_enemy.jump_cooldown > 0) _enemy.jump_cooldown--;

    if (_enemy.hurt_timer > 0) return;

    var _target = _enemy.target;

    if (instance_exists(_target) == false || _target.dead)
    {
        _enemy.target = instance_find(obj_player, 0);
        _target = _enemy.target;
    }

    if (instance_exists(_target) == false)
    {
        _enemy.ai_state = EnemyAIState.IDLE;
        _enemy.hsp = 0;
        return;
    }

    var _distance_x = abs(_target.x - _enemy.x);

    switch (_enemy.ai_state)
    {
        case EnemyAIState.IDLE:
            _enemy.hsp = 0;

            if (_distance_x <= _enemy.detection_range)
            {
                _enemy.ai_state = EnemyAIState.CHASE;
            }
        break;

        case EnemyAIState.CHASE:
            var _direction = sign(_target.x - _enemy.x);

            // Не меняем facing, когда X практически совпал.
            // Иначе юнит может визуально флипаться на месте.
            if (_distance_x > 4)
            {
                _enemy.facing = _direction;
                _enemy.image_xscale = _enemy.facing;
            }

            // Атака возможна только если враг находится примерно
            // на одном уровне с игроком.
            var _same_level = abs(_target.y - _enemy.y) <= _enemy.attack_level_tolerance;

            if (_distance_x <= _enemy.attack_range && _same_level)
            {
                _enemy.hsp = 0;

                if (_enemy.attack_cooldown <= 0)
                {
                    scr_enemy_start_attack(_enemy);
                }

                break;
            }

            if (_distance_x > _enemy.detection_range)
            {
                _enemy.hsp = 0;
                _enemy.ai_state = EnemyAIState.IDLE;
                break;
            }

            _enemy.hsp = _direction * _enemy.move_speed;

            // Прыжок не связан просто с координатой Y игрока.
            // Сначала проверяем физическое препятствие перед врагом.
            if (_enemy.grounded && _enemy.jump_cooldown <= 0)
            {
                if (scr_enemy_should_jump(_enemy, _target, _direction))
                {
                    _enemy.vsp = _enemy.jump_speed;
                    _enemy.grounded = false;
                    _enemy.jump_cooldown = 30;
                }
            }
        break;

        case EnemyAIState.ATTACK:
            _enemy.hsp = 0;
            scr_enemy_update_attack(_enemy);
        break;
    }
}

/// Прыжок нужен только для преодоления препятствия.
function scr_enemy_should_jump(_enemy, _target, _direction)
{
    if (_direction == 0) return false;

    var _check_x = _enemy.x + _direction * _enemy.jump_check_distance;
    var _feet_y = _enemy.y - _enemy.body_bottom_offset;

    // Проверяем препятствие на уровне ног.
    var _low = scr_movement_solid(_enemy, _check_x, _feet_y - 8);

    if (!_low) return false;

    // Проверяем, есть ли место выше препятствия.
    var _high = scr_movement_solid(
        _enemy,
        _check_x,
        _feet_y - _enemy.jump_height_threshold
    );

    if (_high) return false;

    // Если игрок выше, убеждаемся, что он действительно находится
    // в направлении движения и недалеко от препятствия.
    var _target_ahead =
        (_target.x - _enemy.x) * _direction > 0 &&
        abs(_target.x - _enemy.x) <= 160;

    var _target_higher =
        _enemy.y - _target.y > 8 &&
        _enemy.y - _target.y <= _enemy.jump_height_threshold;

    return _target_ahead && _target_higher;
}

function scr_enemy_physics(_enemy)
{
    if (_enemy.knockback_speed != 0)
    {
        _enemy.hsp = _enemy.knockback_speed;
        scr_movement_move_horizontal(_enemy);
        _enemy.knockback_speed = approach(_enemy.knockback_speed, 0, 0.5);
    }
    else
    {
        scr_enemy_move_horizontal(_enemy);
    }

    scr_movement_gravity(_enemy);
    scr_movement_vertical_collision(_enemy);
}

function scr_enemy_move_horizontal(_enemy)
{
    if (_enemy.hsp == 0) return;
    scr_movement_move_horizontal(_enemy);
}

function scr_enemy_start_attack(_enemy)
{
    _enemy.ai_state = EnemyAIState.ATTACK;
    _enemy.current_move = scr_enemy_get_attack(_enemy);
    _enemy.move_phase = CombatMovePhase.STARTUP;
    _enemy.move_timer = 0;
    _enemy.move_hit_targets = [];
    _enemy.move_hit_registered = false;

    _enemy.current_damage = _enemy.current_move.damage;
    _enemy.current_knockback = _enemy.current_move.knockback;

    _enemy.hsp = 0;
    _enemy.vsp = 0;

    _enemy.sprite_index = _enemy.current_move.sprite;
    _enemy.image_index = 0;
    _enemy.image_speed = 0;
}

function scr_enemy_get_attack(_enemy)
{
    return CombatMove(
        _enemy.sprite_attack,
        4, 3, 8,
        8, 5,
        38, -27, 50, 35,
        0, 0, undefined,
        false, 0, 1, 1,
        1, 3, 2
    );
}

function scr_enemy_update_attack(_enemy)
{
    var _move = _enemy.current_move;
    _enemy.move_timer++;

    if (_enemy.move_phase == CombatMovePhase.STARTUP)
    {
        scr_enemy_update_animation(_enemy, _move);

        if (_enemy.move_timer >= _move.startup)
        {
            _enemy.move_phase = CombatMovePhase.ACTIVE;
            _enemy.move_timer = 0;
        }
        return;
    }

    if (_enemy.move_phase == CombatMovePhase.ACTIVE)
    {
        scr_enemy_update_animation(_enemy, _move);
        scr_hitbox_attack(_enemy, _move);

        if (_enemy.move_timer >= _move.active)
        {
            _enemy.move_phase = CombatMovePhase.RECOVERY;
            _enemy.move_timer = 0;
        }
        return;
    }

    if (_enemy.move_phase == CombatMovePhase.RECOVERY)
    {
        scr_enemy_update_animation(_enemy, _move);

        if (_enemy.move_timer >= _move.recovery)
        {
            _enemy.current_move = undefined;
            _enemy.move_hit_targets = [];
            _enemy.move_hit_registered = false;
            _enemy.current_damage = 0;
            _enemy.current_knockback = 0;

            _enemy.attack_cooldown = 45;
            _enemy.ai_state = EnemyAIState.CHASE;
            _enemy.move_timer = 0;
            _enemy.sprite_index = _enemy.sprite_idle;
            _enemy.image_index = 0;
            _enemy.image_speed = 1;
        }
    }
}

function scr_enemy_update_animation(_enemy, _move)
{
    var _frame_start = 0;
    var _frame_count = 0;
    var _phase_duration = 0;

    if (_enemy.move_phase == CombatMovePhase.STARTUP)
    {
        _frame_start = 0;
        _frame_count = _move.animation_startup_frames;
        _phase_duration = _move.startup;
    }
    else if (_enemy.move_phase == CombatMovePhase.ACTIVE)
    {
        _frame_start = _move.animation_startup_frames;
        _frame_count = _move.animation_active_frames;
        _phase_duration = _move.active;
    }
    else if (_enemy.move_phase == CombatMovePhase.RECOVERY)
    {
        _frame_start = _move.animation_startup_frames + _move.animation_active_frames;
        _frame_count = _move.animation_recovery_frames;
        _phase_duration = _move.recovery;
    }

    var _ratio = _move_timer_safe(_enemy.move_timer, _phase_duration);
    _enemy.image_index = _frame_start + floor(_ratio * _frame_count);
    _enemy.image_speed = 0;
}

function _move_timer_safe(_timer, _duration)
{
    if (_duration <= 0) return 0;
    return clamp(_timer / _duration, 0, 0.9999);
}
