function scr_attack_stinger_update_input(_player)
{
    var _tap_window = 10;
    var _press_window = 6;

    var _direction = 0;

    if (keyboard_check_pressed(ord("A")))
    {
        _direction = -1;
    }
    else if (keyboard_check_pressed(ord("D")))
    {
        _direction = 1;
    }

    // Если уже распознали двойной тап, ждём K.
    if (_player.stinger_input_window_timer > 0)
    {
        _player.stinger_input_window_timer--;

        // Новое направление отменяет старое окно
        // и становится первым тапом новой последовательности.
        if (_direction != 0)
        {
            _player.stinger_input_window_timer = 0;
            _player.stinger_tap_direction = _direction;
            _player.stinger_double_tap_timer = _tap_window;
        }
        else if (keyboard_check_pressed(_player.attack_key))
        {
            _player.stinger_input_window_timer = 0;

            return true;
        }

        return false;
    }

    // Таймер между первым и вторым тапом.
    if (_player.stinger_double_tap_timer > 0)
    {
        _player.stinger_double_tap_timer--;
    }

    if (_direction != 0)
    {
        // Второй тап в том же направлении.
        if (
            _player.stinger_tap_direction == _direction
            && _player.stinger_double_tap_timer > 0
        )
        {
            _player.stinger_direction = _direction;
            _player.stinger_input_window_timer = _press_window;
            _player.stinger_double_tap_timer = 0;

            // K может быть нажат в тот же кадр, что и второй тап.
            if (keyboard_check_pressed(_player.attack_key))
            {
                _player.stinger_input_window_timer = 0;
                return true;
            }

            return false;
        }

        // Первый тап или новая последовательность.
        _player.stinger_tap_direction = _direction;
        _player.stinger_double_tap_timer = _tap_window;
    }

    return false;
}

function scr_attack_stinger_reset_input(_player)
{
    _player.stinger_tap_direction = 0;
    _player.stinger_double_tap_timer = 0;
    _player.stinger_input_window_timer = 0;
    _player.stinger_direction = 0;
}

function scr_attack_stinger_get_move(_player)
{
    return CombatMove(
        _player.spriteAttackSp1,

        4,  // startup
        3,  // active
        6,  // recovery

        25, // damage
        8,  // knockback

        0,  // combo window start
        0,  // combo window end

        undefined,

        false, // charge enabled
        0,
        1,
        1,

        1, // animation startup frames
        1, // animation active frames
        1  // animation recovery frames
    );
}