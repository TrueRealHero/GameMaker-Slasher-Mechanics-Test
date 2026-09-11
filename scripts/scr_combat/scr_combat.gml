/// scr_combat
/// Вся логика боевой системы игрока

function scr_combat(_player)
{
    // Пока выполняется специальная атака,
    // обычный combat ничего не делает.
    if (_player.special_attacking)
    {
        return;
    }

    if (!_player.ground_attacking)
    {
        if (
            _player.grounded
            && keyboard_check_pressed(_player.attack_key)
        )
        {
            scr_combat_start_ground_attack(_player, 1);
        }

        return;
    }

    _player.hsp = 0;
    _player.vsp = 0;

    scr_combat_update_ground_attack(_player);
}

function scr_combat_start_ground_attack(_player, _stage)
{
    _player.ground_attacking = true;
    _player.ground_attack_stage = _stage;

    _player.ground_attack_timer = 0;
    _player.ground_combo_timer = 0;
    _player.ground_attack_queued = false;

    _player.ground_charging = false;
    _player.ground_charge_timer = 0;

    _player.hsp = 0;
    _player.vsp = 0;


    switch (_stage)
    {
        case 1:
            _player.sprite_index = _player.spriteAttack1;
            _player.ground_attack_speed = _player.ground_attack1_speed;
        break;

        case 2:
            _player.sprite_index = _player.spriteAttack2;
            _player.ground_attack_speed = _player.ground_attack2_speed;
        break;

        case 3:
            _player.sprite_index = _player.spriteAttack3;
            _player.ground_attack_speed = _player.ground_attack3_speed;

            // Если при переходе на Attack 3
            // K уже зажата — начинаем зарядку
            if (keyboard_check(_player.attack_key))
            {
                _player.ground_charging = true;
                _player.ground_charge_timer = 0;

                _player.image_index = 0;
                _player.image_speed = 0;

                return;
            }
        break;
    }


    _player.image_index = 0;
    _player.image_speed = 0;
}

function scr_combat_update_ground_attack(_player)
{
    var _frames =
        sprite_get_number(_player.sprite_index);


    // ==========================================
   // ATTACK 3 — CHARGING
   // ==========================================
   
   if (
       _player.ground_attack_stage == 3 && _player.ground_charging
   )
   {
       // ----------------------------------
       // ДВИЖЕНИЕ ВО ВРЕМЯ ЗАРЯДКИ
       // ----------------------------------
   
       var _input = keyboard_check(ord("D")) - keyboard_check(ord("A"));
   
       _player.hsp = _input * _player.ground_charge_move_speed;
   
       // Направление взгляда
       if (_input != 0)
       {
           _player.facing = sign(_input);
           _player.image_xscale = _player.facing;
       }
   
       // Перемещение
       scr_movement_move_horizontal(_player);
    
       // ----------------------------------
       // ЗАРЯД
       // ----------------------------------
   
       _player.ground_charge_timer++;
   
       // ----------------------------------
       // ДОСТИГЛИ МАКСИМАЛЬНОГО ЗАРЯДА
       // ----------------------------------
   
       if (
           _player.ground_charge_timer >= _player.ground_max_charge
       )
       {
           _player.ground_charging = false;
   
           _player.ground_attack_timer = 0;
   
           _player.image_index = 0;
           _player.image_speed = 0;
   
           return;
       }
   
   
       // ----------------------------------
       // ИГРОК ОТПУСТИЛ K
       // ----------------------------------
   
       if (!keyboard_check(_player.attack_key))
       {
           _player.ground_charging = false;
   
           _player.ground_attack_timer = 0;
   
           _player.image_index = 0;
           _player.image_speed = 0;
   
           return;
       }
   
       return;
   }


    // ==========================================
    // ФАЗА 1 — АНИМАЦИЯ АТАКИ
    // ==========================================

    if (_player.ground_attack_timer < _frames)
    {
        _player.ground_attack_timer += _player.ground_attack_speed;

        _player.image_index = floor(_player.ground_attack_timer);

        _player.image_index = clamp( _player.image_index, 0, _frames - 1 );

        return;
    }


    // ==========================================
    // ФАЗА 2 — COMBO WINDOW
    // ==========================================

    _player.ground_combo_timer++;

    var _window = 0;


    switch (_player.ground_attack_stage)
    {
        case 1: _window = _player.ground_attack1_combo_window;
        break;

        case 2: _window = _player.ground_attack2_combo_window;
        break;

        case 3: _window = _player.ground_attack3_combo_window;
        break;
    }


    // ==========================================
    // INPUT NEXT ATTACK
    // ==========================================

    if (
        _window > 0 && keyboard_check_pressed(_player.attack_key)
    )
    {
        _player.ground_attack_queued = true;
    }


    // ==========================================
    // ПЕРЕХОД
    // ==========================================

    if (_player.ground_attack_queued)
    {
        if (_player.ground_attack_stage < 3)
        {
            scr_combat_start_ground_attack(
                _player,
                _player.ground_attack_stage + 1
            );

            return;
        }
    }


    // ==========================================
    // WINDOW ENDED
    // ==========================================

    if (_player.ground_combo_timer >= _window)
    {
        scr_combat_finish_ground_attack(_player);
    }
}


function scr_combat_finish_ground_attack(_player)
{
    _player.ground_attacking = false;

    _player.ground_attack_stage = 0;

    _player.ground_attack_timer = 0;
    _player.ground_combo_timer = 0;

    _player.ground_attack_queued = false;

    _player.image_index = 0;
    _player.image_speed = 1;

    _player.sprite_index = _player.spriteIdle;
}