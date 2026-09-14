/// scr_hitbox
/// Временная hitbox атаки.
/// Hitbox не является отдельным объектом: она существует только во время проверки ACTIVE.

function scr_hitbox_attack(_attacker, _move)
{
    // Положение hitbox относительно игрока.
    var _offset_x = 42 * _attacker.facing;
    var _offset_y = -27;

    // Размер первой тестовой melee hitbox.
    var _width = 55;
    var _height = 35;

    var _left = _attacker.x + _offset_x - _width * 0.5;
    var _top = _attacker.y + _offset_y - _height * 0.5;
    var _right = _left + _width;
    var _bottom = _top + _height;

    var _count = instance_number(obj_hurtbox);

    for (var i = 0; i < _count; i++)
    {
        var _hurtbox = instance_find(obj_hurtbox, i);

        if (instance_exists(_hurtbox) == false)
        {
            continue;
        }

        var _target = _hurtbox.owner;

        if (instance_exists(_target) == false || _target == _attacker)
        {
            continue;
        }

        if (variable_instance_exists(_target, "dead") && _target.dead)
        {
            continue;
        }

        // У каждой атаки пока только одно попадание по конкретному target.
        if (array_contains(_attacker.move_hit_targets, _target))
        {
            continue;
        }

        var _target_left = _hurtbox.x - _hurtbox.box_width * 0.5;
        var _target_top = _hurtbox.y - _hurtbox.box_height * 0.5;
        var _target_right = _target_left + _hurtbox.box_width;
        var _target_bottom = _target_top + _hurtbox.box_height;

        if (
            _left < _target_right
            && _right > _target_left
            && _top < _target_bottom
            && _bottom > _target_top
        )
        {
            scr_hurtbox_receive_damage(
                _hurtbox,
                _attacker.current_damage,
                _attacker.current_knockback * _attacker.facing,
                _attacker
            );

            array_push(_attacker.move_hit_targets, _target);
            _attacker.move_hit_registered = true;
        }
    }
}
