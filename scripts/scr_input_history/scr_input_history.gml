function scr_input_history_update(_player)
{
    _player.input_frame++;

    // Направления записываем только в момент нажатия.
    // Поэтому удержание A/D не создаёт сотни одинаковых событий.
    if (keyboard_check_pressed(ord("A")))
    {
        scr_input_history_add(_player, 0, -1);
    }
    else if (keyboard_check_pressed(ord("D")))
    {
        scr_input_history_add(_player, 0, 1);
    }

    // Атаку тоже записываем как отдельное событие.
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