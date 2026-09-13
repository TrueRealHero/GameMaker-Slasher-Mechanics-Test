enum InputCommand
{
    NONE,
    STINGER
}

function scr_input_command_get(_player)
{
    var _history = _player.input_history;
    var _count = array_length(_history);

    // Нужно как минимум D + D + K.
    if (_count < 3)
    {
        return InputCommand.NONE;
    }

    var _attack = _history[_count - 1];
    var _direction2 = _history[_count - 2];
    var _direction1 = _history[_count - 3];

    // Последнее событие должно быть K.
    if (_attack.type != 1)
    {
        return InputCommand.NONE;
    }

    // Два предыдущих события — одно и то же направление.
    if (
        _direction1.type != 0
        || _direction2.type != 0
        || _direction1.value != _direction2.value
    )
    {
        return InputCommand.NONE;
    }

    // Два тапа должны находиться в небольшом временном окне.
    var _tap_window = 10;

    if (_direction2.frame - _direction1.frame > _tap_window)
    {
        return InputCommand.NONE;
    }

    // K должен быть нажат вскоре после второго тапа.
    var _press_window = 6;

    if (_attack.frame - _direction2.frame > _press_window)
    {
        return InputCommand.NONE;
    }

    return InputCommand.STINGER;
}