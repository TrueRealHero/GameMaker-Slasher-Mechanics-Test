/// scr_movement
/// Общая физика и движение сущностей.
/// Collision body не зависит от sprite bbox.

function scr_movement(_player)
{
    var _input = scr_movement_input(_player);

    if (_player.movement_active)
    {
        scr_movement_horizontal(_player, _input);

        if (_player.jump_active)
        {
            scr_movement_jump(_player, _input);
        }
    }

    scr_movement_gravity(_player);
    scr_movement_vertical_collision(_player);
    scr_movement_animation(_player);
}

function scr_movement_input(_player)
{
    return {
        horizontal: keyboard_check(ord("D")) - keyboard_check(ord("A")),
        jump: keyboard_check_pressed(vk_space)
    };
}

function scr_movement_horizontal(_player, _input)
{
    var _horizontal = _input.horizontal;
    var _speed = _player.walkspeed * _player.combat_move_speed_multiplier;

    _player.hsp = _horizontal * _speed;

    if (_horizontal != 0)
    {
        _player.facing = sign(_horizontal);
        _player.image_xscale = _player.facing;
    }

    scr_movement_move_horizontal(_player);
}

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

        // Нижняя точка тела находится на 1 пиксель выше самой точки ног.
        // Это предотвращает ситуацию, когда сущность, стоящая на полу,
        // считается уже находящейся внутри collision tile.
        var _top = _player.y - _player.body_height;
        var _middle = _player.y - (_player.body_height * 0.5);
        var _bottom = _player.y - _player.body_bottom_offset - 1;

        if (
            scr_movement_solid(_player, _next_x - _player.body_width * 0.5, _top) ||
            scr_movement_solid(_player, _next_x + _player.body_width * 0.5, _top) ||
            scr_movement_solid(_player, _next_x - _player.body_width * 0.5, _middle) ||
            scr_movement_solid(_player, _next_x + _player.body_width * 0.5, _middle) ||
            scr_movement_solid(_player, _next_x - _player.body_width * 0.5, _bottom) ||
            scr_movement_solid(_player, _next_x + _player.body_width * 0.5, _bottom)
        )
        {
            _player.hsp = 0;
            break;
        }

        _player.x = _next_x;
    }
}

function scr_movement_jump(_player, _input)
{
    if (_input.jump && _player.grounded)
    {
        _player.vsp = _player.jump_speed;
        _player.grounded = false;
    }
}

function scr_movement_gravity(_player)
{
    _player.vsp += 0.5;

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

        var _left = _player.x - _player.body_width * 0.5;
        var _middle = _player.x;
        var _right = _player.x + _player.body_width * 0.5;

        // При движении вниз проверяем ноги.
        // При движении вверх проверяем голову.
        var _check_y;

        if (_direction > 0)
        {
            _check_y = _next_y - _player.body_bottom_offset;
        }
        else
        {
            _check_y = _next_y - _player.body_height;
        }

        if (
            scr_movement_solid(_player, _left, _check_y) ||
            scr_movement_solid(_player, _middle, _check_y) ||
            scr_movement_solid(_player, _right, _check_y)
        )
        {
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

function scr_movement_initialize_grounded(_player)
{
    var _feet_y = _player.y - _player.body_bottom_offset;

    _player.grounded =
        scr_movement_solid(_player, _player.x, _feet_y + 1) ||
        scr_movement_solid(_player, _player.x - _player.body_width * 0.5, _feet_y + 1) ||
        scr_movement_solid(_player, _player.x + _player.body_width * 0.5, _feet_y + 1);
}

function scr_movement_animation(_player)
{
    if (!_player.grounded)
    {
        _player.sprite_index = _player.spriteJump;

        if (_player.vsp < -2)
        {
            _player.image_index = 0;
        }
        else if (_player.vsp <= 2)
        {
            _player.image_index = 1;
        }
        else
        {
            _player.image_index = 2;
        }

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