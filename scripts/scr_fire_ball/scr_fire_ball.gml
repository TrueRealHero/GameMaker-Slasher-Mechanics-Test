/// scr_fire_ball
/// Логика самого снаряда и его создание.

function scr_fire_ball_create(_player)
{
    var _spawn_x = _player.x + (_player.facing * 20);
    var _spawn_y = _player.y - 8;

    var _fire_ball = instance_create_layer(
        _spawn_x,
        _spawn_y,
        layer_get_name(_player.layer),
        obj_fire_ball
    );

    _fire_ball.direction_x = _player.facing;
    _fire_ball.image_xscale = _player.facing; 
    _fire_ball.pspeed = 7;
    _fire_ball.damage = 20;
    _fire_ball.life_timer = 120;

    return _fire_ball;
}

function scr_fire_ball_update(_fire_ball)
{
    _fire_ball.x += _fire_ball.direction_x * _fire_ball.pspeed;

    _fire_ball.life_timer--;

    // Пока hitbox системы нет, просто удаляем снаряд
    // после заданного времени жизни.
    if (_fire_ball.life_timer <= 0)
    {
        instance_destroy();
    }
}