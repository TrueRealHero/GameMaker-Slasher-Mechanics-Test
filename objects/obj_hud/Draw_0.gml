// HUD is drawn in room space, but anchored to the active camera.
var _camera = view_camera[0];
var _view_x = camera_get_view_x(_camera);
var _view_y = camera_get_view_y(_camera);

var _x = _view_x + hud_margin;
var _y = _view_y + hud_margin;

var _player_hp = 0;
var _player_max_hp = 100;

if (instance_exists(obj_player))
{
    _player_hp = max(0, obj_player.hp);
}

// Player HP bar.
draw_set_alpha(0.8);
draw_set_color(c_black);
draw_rectangle(
    _x,
    _y,
    _x + hud_bar_width,
    _y + hud_bar_height,
    false
);

draw_set_color(c_white);
draw_rectangle(
    _x,
    _y,
    _x + hud_bar_width * clamp(_player_hp / _player_max_hp, 0, 1),
    _y + hud_bar_height,
    true
);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_x, _y + hud_bar_height + 4, "PLAYER HP: " + string(_player_hp) + " / " + string(_player_max_hp));

// Current enemy HP.
var _enemy = noone;
var _enemy_count = instance_number(obj_enemy);

if (_enemy_count > 0)
{
    _enemy = instance_find(obj_enemy, 0);
}

if (instance_exists(_enemy))
{
    var _enemy_hp = max(0, _enemy.hp);
    var _enemy_max_hp = 200;
    var _enemy_y = _y + 58;

    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(
        _x,
        _enemy_y,
        _x + hud_bar_width,
        _enemy_y + hud_bar_height,
        false
    );

    draw_set_color(c_white);
    draw_rectangle(
        _x,
        _enemy_y,
        _x + hud_bar_width * clamp(_enemy_hp / _enemy_max_hp, 0, 1),
        _enemy_y + hud_bar_height,
        true
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_text(
        _x,
        _enemy_y + hud_bar_height + 4,
        "ENEMY HP: " + string(_enemy_hp) + " / " + string(_enemy_max_hp)
    );
}

// Debug status.
draw_text(
    _x,
    _y + 116,
    "DEBUG: " + string(global.debug ? "ON" : "OFF") + "  [F1]"
);

draw_set_alpha(1);
draw_set_color(c_white);
