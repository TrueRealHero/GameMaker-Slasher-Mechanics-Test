/// scr_enemy_ai
/// Базовый AI врага.
/// IDLE -> CHASE -> ATTACK.
/// Враг преследует игрока по X и может запрыгивать на более высокую платформу.

enum EnemyAIState
{
    IDLE,
    CHASE,
    ATTACK
}

function scr_enemy_ai(_enemy)
{
    if (_enemy.attack_cooldown > 0)
    {
        _enemy.attack_cooldown--;
    }

    if (_enemy.hurt_timer > 0)
    {
        return;
    }

    var _target = _enemy.target;

    if (instance_exists(_target) == false || _target.dead)
    {
        _enemy.target = instance_find(obj_player, 0);
        _target = _enemy.target;
    }

    if (instance_exists(_target) == false)
    {
        _enemy.ai_state = EnemyAIState.IDLE;
        return;
    }

    var _distance_x = abs(_target.x - _enemy.x);
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
            // Если игрок выше и находится достаточно близко,
            // пытаемся запрыгнуть на платформу.
            if (
                _enemy.grounded
                && _distance_y >= _enemy.jump_height_threshold
                && _distance_x <= _enemy.jump_horizontal_threshold
            )
            {
                _enemy.vsp = _enemy.jump_speed;
                _enemy.grounded = false;
            }

            if (_distance_x <= _enemy.attack_range && abs(_distance_y) < _enemy.body_height)
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

            var _direction = sign(_target.x - _enemy.x);

            if (_direction != 0)
            {
                _enemy.facing = _direction;
                _enemy.image_xscale = _enemy.facing;
            }

            _enemy.hsp = _direction * _enemy.move_speed;
        break;

        case EnemyAIState.ATTACK:
            _enemy.hsp = 0;
            scr_enemy_update_attack(_enemy);
        break;
    }
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
    if (_enemy.hsp == 0)
    {
        return;
    }

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
        4,
        3,
        8,
        8,
        5,
        38,
        -27,
        50,
        35,
        0,
        0,
        undefined,
        false,
        0,
        1,
        1,
        1,
        3,
        2
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

    var _ratio = _enemy.move_timer / _phase_duration;
    _ratio = clamp(_ratio, 0, 0.9999);

    _enemy.image_index = _frame_start + floor(_ratio * _frame_count);
    _enemy.image_speed = 0;
}
