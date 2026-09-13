function scr_input_history_update(_player)
{
    _player.input_frame++;

    // Направления записываем только в момент нажатия.
    // Удержание A/D не создаёт повторных событий.
    if (keyboard_check_pressed(ord("A")))
    {
        scr_input_history_add(_player, 0, -1);
    }
    else if (keyboard_check_pressed(ord("D")))
    {
        scr_input_history_add(_player, 0, 1);
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