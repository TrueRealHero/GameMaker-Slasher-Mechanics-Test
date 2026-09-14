/// scr_hurtbox
/// Создание и обновление hurtbox.
/// Hurtbox принадлежит конкретной сущности и следует за ней.

function scr_hurtbox_create(_owner, _offset_x, _offset_y, _width, _height)
{
    var _hurtbox = instance_create_layer(
        _owner.x + _offset_x,
        _owner.y + _offset_y,
        layer_get_name(_owner.layer),
        obj_hurtbox
    );

    _hurtbox.owner = _owner;
    _hurtbox.offset_x = _offset_x;
    _hurtbox.offset_y = _offset_y;
    _hurtbox.box_width = _width;
    _hurtbox.box_height = _height;

    return _hurtbox;
}

function scr_hurtbox_update(_hurtbox)
{
    if (instance_exists(_hurtbox.owner) == false)
    {
        instance_destroy(_hurtbox);
        return;
    }

    _hurtbox.x = _hurtbox.owner.x + _hurtbox.offset_x;
    _hurtbox.y = _hurtbox.owner.y + _hurtbox.offset_y;
}

function scr_hurtbox_receive_damage(_hurtbox, _damage, _knockback, _source)
{
    var _owner = _hurtbox.owner;

    if (instance_exists(_owner) == false || _owner.dead)
    {
        return;
    }

    _owner.hp -= _damage;
    _owner.hurt_timer = 8;
    _owner.hurt_source = _source;
    _owner.knockback_speed = _knockback;

    if (_owner.hp <= 0)
    {
        _owner.hp = 0;
        _owner.dead = true;
    }

    show_debug_message(
        "ENEMY HIT | DAMAGE: "
        + string(_damage)
        + " | HP: "
        + string(_owner.hp)
    );
}
