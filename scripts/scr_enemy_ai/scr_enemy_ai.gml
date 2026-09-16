/// scr_enemy_ai
/// Базовый AI врага.
/// IDLE -> CHASE -> ATTACK.
/// Прыжок используется для перехода между уровнями платформ.

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

    var _dx = _target.x - _enemy.x;
    var _distance_x = abs(_dx);
    var _direction = sign(_dx);
    var _distance_y = _enemy.y - _target.y;

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
            // Если X почти совпал, сохраняем прежнее направление.
            // Это предотвращает флип на месте, когда игрок находится сверху/снизу.
            if (_distance_x > 4)
            {
                _enemy.facing = _direction;
                _enemy.image_xscale = _enemy.facing;
            }

            var _same_level = abs(_distance_y) <= _enemy.attack_level_tolerance;

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

            // Основная цель CHASE — двигаться к игроку по X.
            // Прыжок является отдельным решением навигации.
            _enemy.hsp = _direction * _enemy.move_speed;

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

/// Определяет, нужен ли прыжок для продолжения преследования.
///
/// Важный принцип:
/// разница Y сама по себе не является причиной прыжка.
/// Мы прыгаем только когда перед врагом обнаружено препятствие,
/// которое можно потенциально преодолеть прыжком.
function scr_enemy_should_jump(_enemy, _target, _direction)
{
    if (_direction == 0) return false;

    var _body_half_width = _enemy.body_width * 0.5;
    var _feet_y = _enemy.y - _enemy.body_bottom_offset;

    // Проверяем несколько точек перед телом, чтобы маленькое препятствие
    // не терялось из-за одного единственного sample point.
    var _check_x_near = _enemy.x + _direction * (_body_half_width + 3);
    var _check_x_far = _enemy.x + _direction * (_body_half_width + _enemy.jump_check_distance);

    var _obstacle_near =
        scr_movement_solid(_enemy, _check_x_near, _feet_y - 8) ||
        scr_movement_solid(_enemy, _check_x_near, _feet_y - 16);

    var _obstacle_far =
        scr_movement_solid(_enemy, _check_x_far, _feet_y - 8) ||
        scr_movement_solid(_enemy, _check_x_far, _feet_y - 16);

    if (!_obstacle_near && !_obstacle_far)
    {
        return false;
    }

    // Проверяем, что над препятствием есть пространство для тела врага.
    var _clear_x = _check_x_near;
    var _clear_y = _feet_y - _enemy.jump_height_threshold;

    var _space_clear =
        !scr_movement_solid(_enemy, _clear_x, _clear_y) &&
        !scr_movement_solid(_enemy, _clear_x, _clear_y - _enemy.body_height * 0.5);

    if (!_space_clear)
    {
        return false;
    }

    // Нам нужен игрок, находящийся за препятствием или на верхнем уровне.
    // Если игрок просто подпрыгнул рядом на той же поверхности,
    // враг не должен повторять его прыжок.
    var _target_ahead = _dx_to_target(_enemy, _target) * _direction > 0;
    var _target_close = abs(_target.x - _enemy.x) <= _enemy.jump_target_distance;
    var _target_higher = _distance_y_to_target(_enemy, _target) > 8;

    return _target_ahead && _target_close && _target_higher;
}

function _dx_to_target(_enemy, _target)
{
    return _target.x - _enemy.x;
}

function _distance_y_to_target(_enemy, _target)
{
    return _enemy.y - _target.y;
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
