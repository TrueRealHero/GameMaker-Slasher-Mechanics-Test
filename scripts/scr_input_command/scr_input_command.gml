// Создаем историю инпутов для сложных комманд
enum InputCommand
{
    NONE,
    STINGER,
    HADOUKEN
}

function scr_input_command_get(_player)
{
    var _history = _player.input_history;
    var _count = array_length(_history);

    if (_count < 2)
    {
        return scr_input_command_none();
    }

    // Последнее событие должно быть K.
    var _attack = _history[_count - 1];

    if (_attack.type != 1)
    {
        return scr_input_command_none();
    }

    // Ищем последние три ненейтральных направления перед K.
    // Neutral (5) игнорируется: это позволяет делать команды
    // как слитно, так и с короткими отпусканиями клавиш.
    var _directions = [];

    for (var i = _count - 2; i >= 0; i--)
    {
        if (_history[i].type != 0)
        {
            continue;
        }

        if (_history[i].value == 5)
        {
            continue;
        }

        array_insert(_directions, 0, _history[i]);

        if (array_length(_directions) >= 3)
        {
            break;
        }
    }

    // Сначала проверяем более специфичную команду 236K.
    if (array_length(_directions) >= 3)
    {
        var _d1 = scr_input_command_relative_direction(
            _directions[array_length(_directions) - 3].value,
            _player.facing
        );

        var _d2 = scr_input_command_relative_direction(
            _directions[array_length(_directions) - 2].value,
            _player.facing
        );

        var _d3 = scr_input_command_relative_direction(
            _directions[array_length(_directions) - 1].value,
            _player.facing
        );

        var _hadouken_tap_window = 10;
        var _hadouken_press_window = 8;

        if (
            _d1 == 2
            && _d2 == 3
            && _d3 == 6
            && _directions[array_length(_directions) - 2].frame
                - _directions[array_length(_directions) - 3].frame <= _hadouken_tap_window
            && _directions[array_length(_directions) - 1].frame
                - _directions[array_length(_directions) - 2].frame <= _hadouken_tap_window
            && _attack.frame
                - _directions[array_length(_directions) - 1].frame <= _hadouken_press_window
        )
        {
            return {
                type: InputCommand.HADOUKEN,
                direction: _player.facing,
                frame: _attack.frame
            };
        }
    }

    // Stinger: 66K.
    if (array_length(_directions) >= 2)
    {
        var _s1_event = _directions[array_length(_directions) - 2];
        var _s2_event = _directions[array_length(_directions) - 1];

        var _s1 = scr_input_command_relative_direction(_s1_event.value, _player.facing);
        var _s2 = scr_input_command_relative_direction(_s2_event.value, _player.facing);

        var _stinger_tap_window = 10;
        var _stinger_press_window = 6;

        if (
            _s1 == 6
            && _s2 == 6
            && _s2_event.frame - _s1_event.frame <= _stinger_tap_window
            && _attack.frame - _s2_event.frame <= _stinger_press_window
        )
        {
            return {
                type: InputCommand.STINGER,
                direction: _player.facing,
                frame: _attack.frame
            };
        }
    }

    return scr_input_command_none();
}

function scr_input_command_none()
{
    return {
        type: InputCommand.NONE,
        direction: 0,
        frame: -1
    };
}

function scr_input_command_relative_direction(_direction, _facing)
{
    // При взгляде вправо numpad уже является относительным.
    if (_facing == 1)
    {
        return _direction;
    }

    // При взгляде влево зеркалим горизонтальную ось:
    // 1 <-> 3, 4 <-> 6, 7 <-> 9.
    switch (_direction)
    {
        case 1: return 3;
        case 3: return 1;
        case 4: return 6;
        case 6: return 4;
        case 7: return 9;
        case 9: return 7;
    }

    return _direction;
}