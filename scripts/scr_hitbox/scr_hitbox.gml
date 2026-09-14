/// scr_hitbox
/// Универсальная hitbox атаки.
/// Геометрия берётся из CombatMove.
/// Hitbox существует логически только во время ACTIVE.

function scr_hitbox_get_rect(_attacker, _move)
{
    var _offset_x = _move.hitbox_offset_x * _attacker.facing;
    var _offset_y = _move.hitbox_offset_y;
    var _width = _move.hitbox_width;
    var _height = _move.hitbox_height;

    var _left = _attacker.x + _offset_x - _width * 0.5;
    var _top = _attacker.y + _offset_y - _height * 0.5;
    var _right = _left + _width;
    var _bottom = _top + _height;

    return {
        left: _left,
        top: _top,
        right: _right,
        bottom: _bottom
    };
}

function scr_hitbox_attack(_attacker, _move)
{
    var _rect = scr_hitbox_get_rect(_attacker, _move);

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
        var _target_right = _hurtbox.x + _hurtbox.box_width * 0.5;
        var _target_bottom = _hurtbox.y + _hurtbox.box_height * 0.5;

        if (
            _rect.left < _target_right
            && _rect.right > _target_left
            && _rect.top < _target_bottom
            && _rect.bottom > _target_top
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

function scr_hitbox_debug_draw(_attacker, _move)
{
    var _rect = scr_hitbox_get_rect(_attacker, _move);

    draw_set_alpha(0.45);
    draw_set_color(c_red);
    draw_rectangle(
        _rect.left,
        _rect.top,
        _rect.right,
        _rect.bottom,
        false
    );
    draw_set_alpha(1);
    draw_set_color(c_white);
}
