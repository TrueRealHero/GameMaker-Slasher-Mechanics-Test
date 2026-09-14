// DEBUG: постоянная hurtbox владельца.
// Hurtbox существует независимо от того, находится ли владелец
// сейчас в атаке.

draw_set_alpha(0.45);
draw_set_color(c_lime);
draw_rectangle(
    x - box_width * 0.5,
    y - box_height * 0.5,
    x + box_width * 0.5,
    y + box_height * 0.5,
    false
);
draw_set_alpha(1);
draw_set_color(c_white);
