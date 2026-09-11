function scr_special_attack(_player)
{
    // Уже выполняется Stinger
    if (_player.special_attacking)
    {
        scr_special_update_stinger(_player);
        return;
    }

    // Проверяем ввод Stinger
    scr_special_check_double_tap(_player);
}

function scr_special_check_double_tap(_player)
{
    // Stinger можно начать только на земле
    if (_player.ground_attacking || !_player.grounded)
    {
        return;
    }

    // =========================================
    // ОКНО ПОСЛЕ ДВОЙНОГО НАЖАТИЯ
    // =========================================

    if (_player.stinger_ready)
    {
        _player.stinger_attack_timer--;

        // Нажали K — запускаем Stinger
        if (keyboard_check_pressed(_player.attack_key))
        {
            scr_special_start_stinger(
                _player,
                _player.last_direction
            );

            _player.stinger_ready = false;
            _player.stinger_attack_timer = 0;
            _player.last_direction = 0;
            _player.last_direction_timer = 0;

            return;
        }

        // Время нажатия K закончилось
        if (_player.stinger_attack_timer <= 0)
        {
            _player.stinger_ready = false;
            _player.last_direction = 0;
            _player.last_direction_timer = 0;
        }

        return;
    }

    // =========================================
    // ОКНО МЕЖДУ ПЕРВЫМ И ВТОРЫМ НАЖАТИЕМ
    // =========================================

    if (_player.last_direction_timer > 0)
    {
        _player.last_direction_timer--;
    }
    else
    {
        _player.last_direction = 0;
    }

    // Первое / второе D
    if (keyboard_check_pressed(ord("D")))
    {
        scr_special_direction_pressed(_player, 1);
    }

    // Первое / второе A
    if (keyboard_check_pressed(ord("A")))
    {
        scr_special_direction_pressed(_player, -1);
    }
}

function scr_special_direction_pressed(_player, _direction)
{
    // Второе нажатие того же направления
    if (
        _player.last_direction == _direction
        && _player.last_direction_timer > 0
    )
    {
        // Двойное нажатие выполнено.
        // Теперь ждём K.
        _player.stinger_ready = true;

        _player.stinger_attack_timer =
            _player.stinger_attack_window;

        return;
    }

    // Первое нажатие
    _player.last_direction = _direction;

    _player.last_direction_timer =
        _player.double_tap_window;

    _player.stinger_ready = false;
}



function scr_special_start_stinger(_player, _direction)
{
    _player.special_attacking = true;

    _player.stinger_timer = 0;
    _player.stinger_direction = _direction;

    _player.hsp = 0;
    _player.vsp = 0;

    // Переключаемся на спрайт Stinger
    _player.sprite_index =
        _player.spriteAttackSp1;

    // Начинаем с первого кадра
    _player.image_index = 0;
    _player.image_speed = 0;

    // Направление персонажа
    _player.facing = _direction;
    _player.image_xscale = _direction;
}

function scr_special_update_stinger(_player)
{
    _player.stinger_timer++;

    // =========================================
    // ДВИЖЕНИЕ
    // =========================================

    _player.hsp =
        _player.stinger_direction
        * _player.stinger_speed;

    scr_movement_move_horizontal(_player);


    // =========================================
    // АНИМАЦИЯ
    // =========================================

    var _frames =
        sprite_get_number(_player.spriteAttackSp1);

    var _frame =
        floor(
            (_player.stinger_timer
            / _player.stinger_duration)
            * _frames
        );

    _player.image_index =
        clamp(
            _frame,
            0,
            _frames - 1
        );

    _player.image_speed = 0;


    // =========================================
    // КОНЕЦ STINGER
    // =========================================

    if (_player.stinger_timer >= _player.stinger_duration)
    {
        scr_special_finish_stinger(_player);
    }
}


function scr_special_finish_stinger(_player)
{
    _player.special_attacking = false;

    _player.stinger_timer = 0;
    _player.hsp = 0;

    _player.image_index = 0;
    _player.image_speed = 1;

    _player.sprite_index =
        _player.spriteIdle;
}
