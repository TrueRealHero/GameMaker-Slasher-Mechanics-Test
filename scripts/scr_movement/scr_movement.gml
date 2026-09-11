/// scr_movement
/// Вся базовая логика движения игрока.
/// Вызывается из obj_player: scr_movement(id);

function scr_movement(_player)
{
    scr_movement_horizontal(_player);
    scr_movement_jump(_player);
    scr_movement_gravity(_player);
    scr_movement_vertical_collision(_player);
    scr_movement_animation(_player);
}

/// Горизонтальное движение

function scr_movement_horizontal(_player)
{
    var _input = keyboard_check(ord("D")) - keyboard_check(ord("A"));

    // Скорость зависит от состояния Shift
    var _speed = keyboard_check(vk_shift)
        ? _player.runspeed
        : _player.walkspeed;

    _player.hsp = _input * _speed;

    // Запоминаем направление взгляда
    if (_input != 0)
    {
        _player.facing = sign(_input);
        _player.image_xscale = _player.facing;
    }

    // Двигаемся с проверкой тайлмапа
    scr_movement_move_horizontal(_player);
}

/// Проверяет, есть ли тайл в указанной точке

function scr_movement_solid(_player, _x, _y)
{
    return tilemap_get_at_pixel(_player.ground, _x, _y) != 0;
}

function scr_movement_move_horizontal(_player)
{
    var _amount = abs(_player.hsp);
    var _direction = sign(_player.hsp);

    for (var i = 0; i < _amount; i++)
    {
        var _next_x = _player.x + _direction;

        var _top = _player.bbox_top;
        var _middle = (_player.bbox_top + _player.bbox_bottom) * 0.5;
        var _bottom = _player.bbox_bottom;

        if (
            scr_movement_solid(_player, _next_x, _top) ||
            scr_movement_solid(_player, _next_x, _middle) ||
            scr_movement_solid(_player, _next_x, _bottom)
        )
        {
            _player.hsp = 0;
            break;
        }

        _player.x = _next_x;
    }
}

/// Прыжок

function scr_movement_jump(_player)
{
    if (keyboard_check_pressed(vk_space) && _player.grounded)
    {
        _player.vsp = _player.jump_speed;
        _player.grounded = false;
    }
}

/// Гравитация

function scr_movement_gravity(_player)
{
    _player.vsp += 0.5;

    // Ограничиваем скорость падения
    if (_player.vsp > 12)
    {
        _player.vsp = 12;
    }
}

function scr_movement_vertical_collision(_player)
{
    var _amount = abs(_player.vsp);
    var _direction = sign(_player.vsp);

    _player.grounded = false;

    for (var i = 0; i < _amount; i++)
    {
        var _next_y = _player.y + _direction;

        var _left = _player.bbox_left;
        var _middle = (_player.bbox_left + _player.bbox_right) * 0.5;
        var _right = _player.bbox_right;

        if (
            scr_movement_solid(_player, _left, _next_y) ||
            scr_movement_solid(_player, _middle, _next_y) ||
            scr_movement_solid(_player, _right, _next_y)
        )
        {
            // Если падаем вниз — стоим на земле
            if (_direction > 0)
            {
                _player.grounded = true;
            }

            _player.vsp = 0;
            break;
        }

        _player.y = _next_y;
    }
}

function scr_movement_animation(_player)
{
    if (!_player.grounded)
    {
        _player.sprite_index = _player.spriteJump;

        // Подъём
        if (_player.vsp < -2)
        {
            _player.image_index = 0;
        }
        // Около пика
        else if (_player.vsp <= 2)
        {
            _player.image_index = 1;
        }
        // Падение
        else
        {
            _player.image_index = 2;
        }

        // Не проигрываем анимацию
        _player.image_speed = 0;
    }
    else if (_player.hsp != 0)
    {
        _player.sprite_index = _player.spriteRun;
        _player.image_speed = 1;
    }
    else
    {
        _player.sprite_index = _player.spriteIdle;
        _player.image_speed = 1;
    }
}