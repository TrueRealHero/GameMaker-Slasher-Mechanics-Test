function scr_input_history_update(_player)
{
    _player.input_frame++;

    // Запоминаем изменение текущего направления.
    // Используем numpad notation:
    // 1 2 3
    // 4 5 6
    // 7 8 9
    // 5 = neutral.
    var _x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    var _direction = 5;

    if (_x != 0 || _y != 0)
    {
        if (_y > 0)
        {
            _direction = (_x < 0) ? 1 : ((_x > 0) ? 3 : 2);
        }
        else if (_y < 0)
        {
            _direction = (_x < 0) ? 7 : ((_x > 0) ? 9 : 8);
        }
        else
        {
            _direction = (_x < 0) ? 4 : 6;
        }
    }

    // Записываем только изменение направления.
    // Поэтому удержание кнопки не создаёт поток одинаковых событий.
    var _last_direction = 5;

    for (var i = array_length(_player.input_history) - 1; i >= 0; i--)
    {
        if (_player.input_history[i].type == 0)
        {
            _last_direction = _player.input_history[i].value;
            break;
        }
    }

    if (_direction != _last_direction)
    {
        scr_input_history_add(_player, 0, _direction);
    }

    // K записываем как отдельное событие.
    if (keyboard_check_pressed(_player.attack_key))
    {
        scr_input_history_add(_player, 1, 0);
    }
}

function scr_input_history_add(_player, _type, _value)
{
    var _event = {
        type: _type,
        value: _value,
        frame: _player.input_frame
    };

    array_push(_player.input_history, _event);

    while (array_length(_player.input_history) > _player.input_history_max)
    {
        array_delete(_player.input_history, 0, 1);
    }
}

function scr_input_history_consume_until(_player, _frame)
{
    var _history = _player.input_history;
    var _new_history = [];

    for (var i = 0; i < array_length(_history); i++)
    {
        if (_history[i].frame > _frame)
        {
            array_push(_new_history, _history[i]);
        }
    }

    _player.input_history = _new_history;
}